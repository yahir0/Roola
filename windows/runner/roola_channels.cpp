// iphlpapi（GetIfTable2）は winsock2 を windows.h より先に読む必要がある。
// roola_channels.h 経由で windows.h が入る前にここで読み込む。
#include <winsock2.h>
#include <ws2ipdef.h>
#include <iphlpapi.h>

#include "roola_channels.h"

#include <flutter/method_channel.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <psapi.h>
#include <shellapi.h>
#include <tlhelp32.h>
#include <windows.h>
#include <pdh.h>
#include <winternl.h>

#include <memory>
#include <string>
#include <vector>

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

static std::wstring Utf8ToWide(const std::string& s) {
  if (s.empty()) return {};
  int len = MultiByteToWideChar(CP_UTF8, 0, s.c_str(), -1, nullptr, 0);
  std::wstring result(len, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, s.c_str(), -1, result.data(), len);
  return result;
}

// ---------------------------------------------------------------------------
// roola/trash — SHFileOperationW + FOF_ALLOWUNDO (Task 4.3)
// ---------------------------------------------------------------------------

static void SetupTrashChannel(flutter::FlutterEngine* engine) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      engine->messenger(), "roola/trash",
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() != "moveToTrash") {
          result->NotImplemented();
          return;
        }
        const auto* args =
            std::get_if<flutter::EncodableMap>(call.arguments());
        if (!args) {
          result->Error("INVALID_ARGUMENT", "Expected map argument");
          return;
        }
        auto it = args->find(flutter::EncodableValue("path"));
        if (it == args->end()) {
          result->Error("INVALID_ARGUMENT", "Missing 'path' argument");
          return;
        }
        const auto* path_str = std::get_if<std::string>(&it->second);
        if (!path_str) {
          result->Error("INVALID_ARGUMENT", "'path' must be a string");
          return;
        }

        // SHFileOperationW requires a double-null-terminated wide string.
        std::wstring wpath = Utf8ToWide(*path_str);
        wpath.push_back(L'\0');  // second null terminator

        SHFILEOPSTRUCTW op = {};
        op.wFunc = FO_DELETE;
        op.pFrom = wpath.c_str();
        op.fFlags =
            FOF_ALLOWUNDO | FOF_NOCONFIRMATION | FOF_NOERRORUI | FOF_SILENT;

        int ret = SHFileOperationW(&op);
        if (ret != 0 || op.fAnyOperationsAborted) {
          result->Error("TRASH_FAILED",
                        "SHFileOperationW failed: " + std::to_string(ret));
        } else {
          result->Success();
        }
      });

  // Transfer ownership to a static so the channel lives for the app lifetime.
  static auto s_trash_channel = std::move(channel);
}

// ---------------------------------------------------------------------------
// roola/system/metrics — GlobalMemoryStatusEx + GetSystemTimes (Task 4.8)
// ---------------------------------------------------------------------------

static ULONGLONG FileTimeToUll(const FILETIME& ft) {
  return (static_cast<ULONGLONG>(ft.dwHighDateTime) << 32) |
         ft.dwLowDateTime;
}

struct CpuSnapshot {
  ULONGLONG idle = 0;
  ULONGLONG kernel = 0;  // includes idle
  ULONGLONG user = 0;
};

static CpuSnapshot g_last_cpu{};

static double CalculateCpuPercent() {
  FILETIME idle_ft, kernel_ft, user_ft;
  if (!GetSystemTimes(&idle_ft, &kernel_ft, &user_ft)) return 0.0;

  CpuSnapshot cur{FileTimeToUll(idle_ft), FileTimeToUll(kernel_ft),
                  FileTimeToUll(user_ft)};

  auto d_idle = cur.idle - g_last_cpu.idle;
  auto d_kernel = cur.kernel - g_last_cpu.kernel;
  auto d_user = cur.user - g_last_cpu.user;
  g_last_cpu = cur;

  auto total = d_kernel + d_user;
  if (total == 0) return 0.0;
  // kernel already includes idle time.
  auto busy = total - d_idle;
  return static_cast<double>(busy) * 100.0 / static_cast<double>(total);
}

// ---------------------------------------------------------------------------
// roola/system/metrics getSystemSnapshot — アクティビティタブ（ADR-0067）
//
// 状態を持たず累積値だけを返す。差分・レート計算は Dart 側が行う。取得できない
// 項目はキーを含めない（Windows ではロードアベレージを返さない）。
// ---------------------------------------------------------------------------

// NtQuerySystemInformation は ntdll.lib を静的リンクせず GetProcAddress で引く。
using NtQuerySystemInformationFn = NTSTATUS(WINAPI*)(
    SYSTEM_INFORMATION_CLASS, PVOID, ULONG, PULONG);

// コアごとの累積時間（100ns 単位）を [user, system, idle, nice] で返す。
// KernelTime は idle を含むため system = kernel - idle。nice は Windows に無く 0。
static bool AppendPerCoreTicks(flutter::EncodableMap& map) {
  static auto query = reinterpret_cast<NtQuerySystemInformationFn>(
      GetProcAddress(GetModuleHandleW(L"ntdll.dll"), "NtQuerySystemInformation"));
  if (!query) return false;
  SYSTEM_INFO sys_info;
  GetSystemInfo(&sys_info);
  std::vector<SYSTEM_PROCESSOR_PERFORMANCE_INFORMATION> cores(
      sys_info.dwNumberOfProcessors);
  ULONG returned = 0;
  if (query(SystemProcessorPerformanceInformation, cores.data(),
            static_cast<ULONG>(cores.size() *
                               sizeof(SYSTEM_PROCESSOR_PERFORMANCE_INFORMATION)),
            &returned) != 0) {
    return false;
  }
  cores.resize(returned / sizeof(SYSTEM_PROCESSOR_PERFORMANCE_INFORMATION));
  flutter::EncodableList list;
  for (const auto& core : cores) {
    const int64_t idle = core.IdleTime.QuadPart;
    const int64_t system = core.KernelTime.QuadPart - idle;
    list.push_back(flutter::EncodableValue(flutter::EncodableList{
        flutter::EncodableValue(static_cast<int64_t>(core.UserTime.QuadPart)),
        flutter::EncodableValue(system),
        flutter::EncodableValue(idle),
        flutter::EncodableValue(static_cast<int64_t>(0)),
    }));
  }
  map[flutter::EncodableValue("cpuTicks")] = flutter::EncodableValue(list);
  return true;
}

// ディスク読み書きの累積バイト。PDH の BULK_COUNT カウンタは生値
// （PdhGetRawCounterValue の FirstValue）が累積バイト数になる。
static bool AppendDiskTotals(flutter::EncodableMap& map) {
  static PDH_HQUERY query = nullptr;
  static PDH_HCOUNTER read_counter = nullptr;
  static PDH_HCOUNTER write_counter = nullptr;
  if (!query) {
    if (PdhOpenQueryW(nullptr, 0, &query) != ERROR_SUCCESS) {
      query = nullptr;
      return false;
    }
    if (PdhAddEnglishCounterW(query, L"\\PhysicalDisk(_Total)\\Disk Read Bytes/sec",
                              0, &read_counter) != ERROR_SUCCESS ||
        PdhAddEnglishCounterW(query, L"\\PhysicalDisk(_Total)\\Disk Write Bytes/sec",
                              0, &write_counter) != ERROR_SUCCESS) {
      PdhCloseQuery(query);
      query = nullptr;
      return false;
    }
  }
  if (PdhCollectQueryData(query) != ERROR_SUCCESS) return false;
  PDH_RAW_COUNTER read_raw{};
  PDH_RAW_COUNTER write_raw{};
  if (PdhGetRawCounterValue(read_counter, nullptr, &read_raw) != ERROR_SUCCESS ||
      PdhGetRawCounterValue(write_counter, nullptr, &write_raw) != ERROR_SUCCESS) {
    return false;
  }
  map[flutter::EncodableValue("diskReadBytes")] =
      flutter::EncodableValue(static_cast<int64_t>(read_raw.FirstValue));
  map[flutter::EncodableValue("diskWriteBytes")] =
      flutter::EncodableValue(static_cast<int64_t>(write_raw.FirstValue));
  return true;
}

// 物理ネットワークアダプタ（有線 / 無線のハードウェア IF）ごとの累積バイト。
// 仮想アダプタ（VPN・Hyper-V 等）は物理 IF と二重計上になるため除外する。
static flutter::EncodableList NetworkInterfaces() {
  flutter::EncodableList list;
  PMIB_IF_TABLE2 table = nullptr;
  if (GetIfTable2(&table) != NO_ERROR || !table) return list;
  for (ULONG i = 0; i < table->NumEntries; ++i) {
    const MIB_IF_ROW2& row = table->Table[i];
    const bool physical_type =
        row.Type == IF_TYPE_ETHERNET_CSMACD || row.Type == IF_TYPE_IEEE80211;
    if (!physical_type || !row.InterfaceAndOperStatusFlags.HardwareInterface ||
        row.InterfaceAndOperStatusFlags.FilterInterface) {
      continue;
    }
    list.push_back(flutter::EncodableValue(flutter::EncodableMap{
        {flutter::EncodableValue("name"),
         flutter::EncodableValue(std::to_string(row.InterfaceLuid.Value))},
        {flutter::EncodableValue("rx"),
         flutter::EncodableValue(static_cast<int64_t>(row.InOctets))},
        {flutter::EncodableValue("tx"),
         flutter::EncodableValue(static_cast<int64_t>(row.OutOctets))},
    }));
  }
  FreeMibTable(table);
  return list;
}

static flutter::EncodableValue SystemSnapshot() {
  flutter::EncodableMap map;
  AppendPerCoreTicks(map);

  MEMORYSTATUSEX mem = {};
  mem.dwLength = sizeof(mem);
  if (GlobalMemoryStatusEx(&mem)) {
    const int64_t phys_total = static_cast<int64_t>(mem.ullTotalPhys);
    const int64_t phys_used = phys_total - static_cast<int64_t>(mem.ullAvailPhys);
    map[flutter::EncodableValue("memoryTotal")] = flutter::EncodableValue(phys_total);
    map[flutter::EncodableValue("memoryUsed")] = flutter::EncodableValue(phys_used);
    // コミット上限 − 物理 = ページファイル容量。コミット使用量 − 物理使用量を
    // ページファイル使用量の近似とする。
    const int64_t swap_total =
        static_cast<int64_t>(mem.ullTotalPageFile) - phys_total;
    const int64_t commit_used = static_cast<int64_t>(mem.ullTotalPageFile) -
                                static_cast<int64_t>(mem.ullAvailPageFile);
    if (swap_total > 0) {
      int64_t swap_used = commit_used - phys_used;
      if (swap_used < 0) swap_used = 0;
      if (swap_used > swap_total) swap_used = swap_total;
      map[flutter::EncodableValue("swapTotal")] = flutter::EncodableValue(swap_total);
      map[flutter::EncodableValue("swapUsed")] = flutter::EncodableValue(swap_used);
    }
  }

  AppendDiskTotals(map);
  map[flutter::EncodableValue("netInterfaces")] =
      flutter::EncodableValue(NetworkInterfaces());
  map[flutter::EncodableValue("uptimeSeconds")] =
      flutter::EncodableValue(static_cast<int64_t>(GetTickCount64() / 1000));
  return flutter::EncodableValue(map);
}

static void SetupSystemMetricsChannel(flutter::FlutterEngine* engine) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      engine->messenger(), "roola/system/metrics",
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "getSystemMetrics") {
          // CPU
          double cpu = CalculateCpuPercent();

          // Memory
          MEMORYSTATUSEX mem = {};
          mem.dwLength = sizeof(mem);
          int64_t used = 0, total = 0;
          if (GlobalMemoryStatusEx(&mem)) {
            total = static_cast<int64_t>(mem.ullTotalPhys);
            used = total - static_cast<int64_t>(mem.ullAvailPhys);
          }

          flutter::EncodableMap map{
              {flutter::EncodableValue("cpu"),
               flutter::EncodableValue(cpu)},
              {flutter::EncodableValue("memoryUsed"),
               flutter::EncodableValue(used)},
              {flutter::EncodableValue("memoryTotal"),
               flutter::EncodableValue(total)},
          };
          result->Success(flutter::EncodableValue(map));

        } else if (call.method_name() == "getSystemSnapshot") {
          result->Success(SystemSnapshot());

        } else if (call.method_name() == "getTopProcesses") {
          flutter::EncodableList list;

          HANDLE snap =
              CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
          if (snap != INVALID_HANDLE_VALUE) {
            PROCESSENTRY32W pe = {};
            pe.dwSize = sizeof(pe);
            if (Process32FirstW(snap, &pe)) {
              do {
                // Get memory usage via PROCESS_MEMORY_COUNTERS
                HANDLE ph = OpenProcess(
                    PROCESS_QUERY_LIMITED_INFORMATION | PROCESS_VM_READ,
                    FALSE, pe.th32ProcessID);
                int64_t mem_bytes = 0;
                if (ph) {
                  PROCESS_MEMORY_COUNTERS pmc = {};
                  pmc.cb = sizeof(pmc);
                  if (GetProcessMemoryInfo(ph, &pmc, sizeof(pmc))) {
                    mem_bytes = static_cast<int64_t>(pmc.WorkingSetSize);
                  }
                  CloseHandle(ph);
                }

                // Convert process name to UTF-8
                int name_len = WideCharToMultiByte(
                    CP_UTF8, 0, pe.szExeFile, -1, nullptr, 0, nullptr, nullptr);
                std::string name(name_len, '\0');
                WideCharToMultiByte(CP_UTF8, 0, pe.szExeFile, -1,
                                    name.data(), name_len, nullptr, nullptr);
                if (!name.empty() && name.back() == '\0') name.pop_back();

                flutter::EncodableMap proc{
                    {flutter::EncodableValue("pid"),
                     flutter::EncodableValue(
                         static_cast<int32_t>(pe.th32ProcessID))},
                    {flutter::EncodableValue("name"),
                     flutter::EncodableValue(name)},
                    {flutter::EncodableValue("cpu"),
                     flutter::EncodableValue(0.0)},
                    {flutter::EncodableValue("memoryBytes"),
                     flutter::EncodableValue(mem_bytes)},
                };
                list.push_back(flutter::EncodableValue(proc));
              } while (Process32NextW(snap, &pe));
            }
            CloseHandle(snap);
          }
          result->Success(flutter::EncodableValue(list));

        } else {
          result->NotImplemented();
        }
      });

  static auto s_metrics_channel = std::move(channel);
}

// ---------------------------------------------------------------------------
// roola/updater — WinSparkle 手動チェックトリガ（ADR-0043 Windows 版）
//
// WinSparkle 統合（Phase B）が完了するまでは no-op で Success を返す。
// Phase B では ROOLA_WINSPARKLE を定義し、WinSparkle.h をインクルードして
// win_sparkle_check_update_with_ui() を呼ぶ。
// ---------------------------------------------------------------------------

#ifdef ROOLA_WINSPARKLE
#include <winsparkle.h>
#endif

static void SetupUpdaterChannel(flutter::FlutterEngine* engine) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      engine->messenger(), "roola/updater",
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() != "checkForUpdates") {
          result->NotImplemented();
          return;
        }
#ifdef ROOLA_WINSPARKLE
        win_sparkle_check_update_with_ui();
#endif
        result->Success();
      });

  static auto s_updater_channel = std::move(channel);
}

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

void SetupRoolaChannels(flutter::FlutterEngine* engine) {
  SetupTrashChannel(engine);
  SetupSystemMetricsChannel(engine);
  SetupUpdaterChannel(engine);
}
