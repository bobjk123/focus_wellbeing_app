#include "flutter_window.h"

#include <windows.h>

#include <optional>
#include <vector>

#include "flutter/generated_plugin_registrant.h"

namespace {

std::string WideToUtf8(const std::wstring& wide) {
  if (wide.empty()) return "";
  int size_needed = WideCharToMultiByte(CP_UTF8, 0, wide.data(),
                                        static_cast<int>(wide.size()), nullptr,
                                        0, nullptr, nullptr);
  if (size_needed <= 0) return "";
  std::string result(size_needed, 0);
  WideCharToMultiByte(CP_UTF8, 0, wide.data(), static_cast<int>(wide.size()),
                      &result[0], size_needed, nullptr, nullptr);
  return result;
}

std::string GetForegroundProcessExeName() {
  HWND hwnd = GetForegroundWindow();
  if (!hwnd) return "";

  DWORD pid = 0;
  GetWindowThreadProcessId(hwnd, &pid);
  if (pid == 0) return "";

  HANDLE process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
  if (!process) return "";

  wchar_t buffer[MAX_PATH];
  DWORD size = MAX_PATH;
  std::string exe_name;
  if (QueryFullProcessImageNameW(process, 0, buffer, &size)) {
    std::wstring full_path(buffer, size);
    size_t pos = full_path.find_last_of(L"\\/");
    std::wstring file_name =
        (pos == std::wstring::npos) ? full_path : full_path.substr(pos + 1);
    exe_name = WideToUtf8(file_name);
  }
  CloseHandle(process);
  return exe_name;
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  last_sample_time_ = std::chrono::steady_clock::now();
  last_foreground_exe_ = GetForegroundProcessExeName();
  usage_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(),
          "com.wellbeing.focus_wellbeing_app/usage_stats",
          &flutter::StandardMethodCodec::GetInstance());

  usage_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() == "hasUsagePermission") {
          result->Success(flutter::EncodableValue(true));
          return;
        }
        if (call.method_name() == "openUsageAccessSettings") {
          result->Success();
          return;
        }
        if (call.method_name() == "getTodayUsageStats") {
          auto now = std::chrono::steady_clock::now();
          auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(
                             now - last_sample_time_)
                             .count();
          if (!last_foreground_exe_.empty() && elapsed > 0) {
            active_app_seconds_[last_foreground_exe_] += elapsed;
          }
          last_foreground_exe_ = GetForegroundProcessExeName();
          last_sample_time_ = now;

          flutter::EncodableList list;
          for (const auto& entry : active_app_seconds_) {
            int64_t minutes = entry.second / 60;
            if (minutes <= 0) continue;
            std::string display_name = entry.first;
            size_t dot_pos = display_name.rfind('.');
            if (dot_pos != std::string::npos) {
              display_name = display_name.substr(0, dot_pos);
            }
            flutter::EncodableMap map;
            map[flutter::EncodableValue("packageName")] =
                flutter::EncodableValue(entry.first);
            map[flutter::EncodableValue("appName")] =
                flutter::EncodableValue(display_name);
            map[flutter::EncodableValue("usageMinutes")] =
                flutter::EncodableValue(static_cast<int>(minutes));
            list.push_back(flutter::EncodableValue(map));
          }
          result->Success(flutter::EncodableValue(list));
          return;
        }
        result->NotImplemented();
      });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
