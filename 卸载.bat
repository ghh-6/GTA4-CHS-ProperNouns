@echo off
chcp 936 >nul
setlocal enabledelayedexpansion
title GTA4 汉化补完补丁 v1.0 卸载
echo ============================================================
echo   GTA4 简中补丁之补丁 v1.0  卸载程序
echo   功能：把 7 个文件还原为原汉化补丁版本，并删除 mapfix.asi
echo ============================================================
echo.
set "PKG=%~dp0"
set "FAILED=0"
rem ---- 自动定位游戏本体（以 GTAIV.exe 为准）----
set "GAME="
set "CAND=%PKG%.."
call :trygame
set "CAND=%PKG%..\..\GTAIV"
call :trygame
set "CAND=%PKG%..\..\..\GTAIV"
call :trygame
if not defined GAME (
  if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set "REGK=HKLM\SOFTWARE\WOW6432Node\Rockstar Games\Grand Theft Auto IV") else (set "REGK=HKLM\SOFTWARE\Rockstar Games\Grand Theft Auto IV")
  for /f "skip=2 tokens=2*" %%a in ('reg query "!REGK!" /v InstallFolder 2^>nul') do set "CAND=%%b"
  if defined CAND call :trygame
)
if not defined GAME for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Valve\Steam" /v SteamPath 2^>nul') do set "STEAM=%%b"
if not defined GAME if not defined STEAM set "STEAM=C:\Program Files (x86)\Steam"
if not defined GAME (
  set "STEAM=!STEAM:/=\!"
  call :trysteam "!STEAM!"
  set "VDF=!STEAM!\steamapps\libraryfolders.vdf"
  if exist "!VDF!" for /f "tokens=2" %%p in ('findstr /c:"path" "!VDF!"') do call :trylib %%p
)
if not defined GAME (
  echo [错误] 未能自动定位游戏本体（找不到 GTAIV.exe）。
  echo        解决办法任选其一：
  echo        1. 把本文件夹放进 GTA4 游戏目录，GTAIV.exe 旁边，再运行；
  echo        2. 先用 Steam 启动过一次游戏，让注册表留下路径，再运行。
  echo.
  pause
  exit /b 1
)
echo [信息] 游戏目录：!GAME!
echo.
set "REL=plugins\GTA4.CHS\char_table.dat"
set "BAK=_ORIGINAL_char_table.dat"
call :back
set "REL=update\pc\textures\fonts.wtd"
set "BAK=_ORIGINAL_fonts_pc.wtd"
call :back
set "REL=update\TLAD\pc\textures\fonts.wtd"
set "BAK=_ORIGINAL_fonts_tlad.wtd"
call :back
set "REL=update\TBoGT\pc\textures\fonts.wtd"
set "BAK=_ORIGINAL_fonts_tbogt.wtd"
call :back
set "REL=update\common\text\american.gxt"
set "BAK=_ORIGINAL_american.gxt"
call :back
set "REL=update\TLAD\common\text\american.gxt"
set "BAK=_ORIGINAL_american_tlad.gxt"
call :back
set "REL=update\TBoGT\common\text\american.gxt"
set "BAK=_ORIGINAL_american_tbogt.gxt"
call :back
if exist "!GAME!\plugins\mapfix.asi" (del /f /q "!GAME!\plugins\mapfix.asi" && echo [成功] 已删除 plugins\mapfix.asi || (echo [失败] 删除 plugins\mapfix.asi 失败 & set /a FAILED+=1))
echo.
if not "!FAILED!"=="0" (
  echo [错误] 有 !FAILED! 个文件还原失败（常见原因：游戏/Steam 正在运行、文件只读、权限不足、杀软拦截）。
  echo        请关闭游戏与 Steam 后，右键本卸载.bat 选择“以管理员身份运行”再试。
  pause
  exit /b 1
)
echo [完成] 已还原为原汉化补丁，专有名词恢复英文。
pause
exit /b 0

:trysteam
set "CAND=%~1\steamapps\common\Grand Theft Auto IV\GTAIV"
call :trygame
exit /b 0

:trylib
set "LIB=%~1"
set "LIB=!LIB:\\=\!"
call :trysteam "!LIB!"
exit /b 0

:trygame
if defined GAME exit /b 0
if exist "%CAND%\GTAIV.exe" set "GAME=%CAND%" & exit /b 0
if exist "%CAND%\GTAIV\GTAIV.exe" set "GAME=%CAND%\GTAIV"
exit /b 0

:back
if not exist "%PKG%%BAK%" echo [错误] 找不到备份 %BAK% ，请勿删除补丁文件夹里的 _ORIGINAL_ 文件。 & pause & exit 1
attrib -r "!GAME!\%REL%" >nul 2>nul
copy /y "%PKG%%BAK%" "!GAME!\%REL%" >nul
if errorlevel 1 (echo [失败] %REL% —— 系统返回： & copy /y "%PKG%%BAK%" "!GAME!\%REL%" & set /a FAILED+=1) else (echo [还原] %REL%)
exit /b 0
