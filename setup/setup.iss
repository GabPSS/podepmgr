[Setup]
AppName=Podepmgr
AppVersion=0.1.0
DefaultDirName=D:\
AllowRootDirectory=yes
DisableWelcomePage=no
DirExistsWarning=no
Uninstallable=no
CreateUninstallRegKey=no
InfoBeforeFile=info.txt
PrivilegesRequired=lowest

[Tasks]
Name: driveicon; Description: "Assign drive name and icon";

[Files]
Source: "..\bin\podepmgr.exe"; DestDir: "{app}\bin\podepmgr"
Source: "podepmgr.ico"; DestDir: "{app}\bin\podepmgr"; Tasks: driveicon
Source: "autorun.inf"; DestDir: "{app}"; Tasks: driveicon

[Run]
Filename: "{app}\bin\podepmgr\podepmgr.exe"; Parameters: "init"; WorkingDir: "{app}"; Description: "Initialize podepmgr drive"; Flags: postinstall