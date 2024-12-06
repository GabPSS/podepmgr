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

[Components]
Name: core; Description: "Podepmgr"; Types: full compact custom; Flags: fixed

[Tasks]
Name: driveicon; Description: "Assign drive name and icon";
Name: firstinit; Description: "Initialize podepmgr drive";

[Files]
Source: "..\bin\podepmgr.exe"; DestDir: "{app}\bin\podepmgr"; Components: core
Source: "initsetup.bat"; DestDir: "{app}\bin\podepmgr"; Tasks: firstinit
Source: "podepmgr.ico"; DestDir: "{app}\bin\podepmgr"; Tasks: driveicon
Source: "autorun.inf"; DestDir: "{app}"; Tasks: driveicon

[Run]
Filename: "{app}\bin\podepmgr\initsetup.bat"; Description: "Initialize podepmgr"; Tasks: firstinit