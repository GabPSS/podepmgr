@echo off
echo Building release...
cd ..
dart compile exe .\bin\devbox.dart
iscc "setup\setup.iss"
echo Done.