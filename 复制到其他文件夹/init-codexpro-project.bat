@echo off
setlocal
set "SCRIPT=%~dp0init-codexpro-project.ps1"
set "INIT_ROOT=%~dp0"

if not exist "%SCRIPT%" (
  echo Missing init-codexpro-project.ps1 next to this bat file.
  echo Please copy both init-codexpro-project.bat and init-codexpro-project.ps1 into the project folder.
  echo.
  pause
  exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand JABzAD0AJABlAG4AdgA6AFMAQwBSAEkAUABUAAoAJABjAG8AZABlAD0AWwBTAHkAcwB0AGUAbQAuAEkATwAuAEYAaQBsAGUAXQA6ADoAUgBlAGEAZABBAGwAbABUAGUAeAB0ACgAJABzACwAWwBTAHkAcwB0AGUAbQAuAFQAZQB4AHQALgBFAG4AYwBvAGQAaQBuAGcAXQA6ADoAVQBUAEYAOAApAAoASQBuAHYAbwBrAGUALQBFAHgAcAByAGUAcwBzAGkAbwBuACAAJABjAG8AZABlAA==
echo.
pause
