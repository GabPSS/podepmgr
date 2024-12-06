@echo off
echo Building release...
cd ..
dart compile exe .\bin\podepmgr.dart
iscc "setup\setup.iss"
echo Done.