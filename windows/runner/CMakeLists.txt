cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "roola_channels.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
# Roola custom channels: shell file ops, memory, process snapshot
target_link_libraries(${BINARY_NAME} PRIVATE "shell32.lib" "psapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# WinSparkle 自動アップデート（ADR-0059）。
# windows/third_party/winsparkle/ に DLL/ヘッダを配置した場合のみ有効化。
# CI は release-windows.yml でダウンロードする。ローカルは docs/release.md 参照。
set(WINSPARKLE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/winsparkle")
if(EXISTS "${WINSPARKLE_DIR}/include/winsparkle.h")
  target_include_directories(${BINARY_NAME} PRIVATE "${WINSPARKLE_DIR}/include")
  target_link_libraries(${BINARY_NAME} PRIVATE
      "${WINSPARKLE_DIR}/x64/Release/WinSparkle.lib")
  target_compile_definitions(${BINARY_NAME} PRIVATE "ROOLA_WINSPARKLE")
  message(STATUS "WinSparkle found — auto-update enabled")
else()
  message(STATUS "WinSparkle not found — auto-update disabled (Phase A)")
endif()

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)
