[Setup]
AppName=DevBox
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
Name: core; Description: "DevBox Manager"; Types: full compact custom; Flags: fixed

[Tasks]
Name: driveicon; Description: "Assign drive name and icon";
Name: firstinit; Description: "Initialize DevBox drive";

[Files]
Source: "..\bin\devbox.exe"; DestDir: "{app}\bin\devbox"; Components: core
Source: "initsetup.bat"; DestDir: "{app}\bin\devbox"; Tasks: firstinit
Source: "dboxlogo.ico"; DestDir: "{app}\bin\devbox"; Tasks: driveicon
Source: "autorun.inf"; DestDir: "{app}"; Tasks: driveicon

[Run]
Filename: "{app}\bin\devbox\initsetup.bat"; Description: "Initialize DevBox"; Tasks: firstinit