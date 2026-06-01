#include "roola_channels.h"

#include <flutter/method_channel.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <psapi.h>
#include <shellapi.h>
#include <tlhelp32.h>
#include <windows.h>

#include <memory>
#include <string>

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
// Public entry point
// ---------------------------------------------------------------------------

void SetupRoolaChannels(flutter::FlutterEngine* engine) {
  SetupTrashChannel(engine);
  SetupSystemMetricsChannel(engine);
}
