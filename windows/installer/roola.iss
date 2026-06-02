; Roola Windows Installer Script
; Usage: iscc roola.iss /DMyAppVersion=X.Y.Z
;
; Output: ..\..\..\..\build\RoolaSetup-X.Y.Z.exe

#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif

#define MyAppName      "Roola"
#define MyAppPublisher "Yahiro"
#define MyAppURL       "https://yahiro.tech"
#define MyAppExeName   "roola.exe"
#define MyAppDataDir   "tech.yahiro.Roola"

[Setup]
AppId={{71C602CD-F8D8-4A6E-BB8E-2EE81F4BB60C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
; per-user install — no UAC prompt required
DefaultDirName={localappdata}\{#MyAppName}
DefaultGroupName={#MyAppName}
PrivilegesRequired=lowest
DisableProgramGroupPage=yes
OutputDir=..\..\build
OutputBaseFilename=RoolaSetup-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
LicenseFile=license.rtf

[Languages]
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Flutter Windows ビルド成果物を再帰コピー
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// アンインストール完了後、ユーザーデータの削除可否をユーザーに確認する。
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  UserDataPath: string;
  MsgResult: Integer;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    UserDataPath := ExpandConstant('{userappdata}\{#MyAppDataDir}');
    if DirExists(UserDataPath) then
    begin
      MsgResult := MsgBox(
        '設定・履歴などのユーザーデータを削除しますか？' + Chr(13) + Chr(10) +
        '削除すると元に戻すことはできません。' + Chr(13) + Chr(10) + Chr(13) + Chr(10) +
        '削除するデータ: ' + UserDataPath,
        mbConfirmation, MB_YESNO or MB_DEFBUTTON2
      );
      if MsgResult = IDYES then
        DelTree(UserDataPath, True, True, True);
    end;
  end;
end;
