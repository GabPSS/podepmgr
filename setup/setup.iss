[Setup]
AppName=DevBox
AppVersion=0.1.0
DefaultDirName=D:\bin\devbox
AllowRootDirectory=yes
DisableWelcomePage=no
DirExistsWarning=no
Uninstallable=no
CreateUninstallRegKey=no
InfoBeforeFile=info.txt
PrivilegesRequired=lowest

[Files]
Source: "..\bin\devbox.exe"; DestDir: "{app}"
Source: "initsetup.bat"; DestDir: "{app}"

[Run]
Filename: "{app}\initsetup.bat"; Description: "Initialize DevBox"