#
# Roola 系アプリ共通のアクティビティモニタ（計測のネイティブ実装 / ADR-0069）。
#
Pod::Spec.new do |s|
  s.name             = 'roola_activity'
  s.version          = '1.0.0'
  s.summary          = 'System metrics for Roola and Roola Monitor.'
  s.description      = <<-DESC
CPU / memory / disk / network metrics for the Roola activity dashboard.
                       DESC
  s.homepage         = 'https://github.com/yahir0/Roola'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'Yahiro'

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.frameworks = 'IOKit'

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
