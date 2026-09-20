@echo off
chcp 936 >nul
setlocal enabledelayedexpansion
title GTA4 汉化补完补丁 v1.0 安装
echo ============================================================
echo   GTA4 简中补丁之补丁（含AI翻译）v1.0  安装程序
echo   内容：专有名词 + 1611 条整句补译 + 字库扩充 + 地图区名修复
echo   前提：已安装原汉化补丁 2024-09-13 版；不修改 GTA4.CHS.asi
echo   支持自动定位游戏目录，无需把本文件夹放进游戏目录
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
rem ---- 检测原汉化补丁：认游戏目录 plugins\GTA4.CHS.asi（原补丁实际安装位置），兼容根目录 ----
if exist "!GAME!\plugins\GTA4.CHS.asi" goto orig_ok
if exist "!GAME!\GTA4.CHS.asi" goto orig_ok
echo [错误] 未检测到原汉化补丁：游戏目录及其 plugins 子目录都缺少 GTA4.CHS.asi。
echo        本补丁是补丁的补丁，必须先安装原汉化补丁
echo        2024-09-13 版，无名汉化组立项、GTA4 贴吧吧友接手完成。
echo.
echo        原汉化补丁获取链接：
echo        GitHub：https://github.com/ckeleshi/GTA4.CHS
echo        官　网：https://b9348.pages.dev/
echo.
pause
exit /b 1
:orig_ok
echo [信息] 已检测到原汉化补丁。
echo.
rem ---- 防呆：包被解压进游戏目录本身时，源=目标，copy 会报“文件无法自身复制” ----
for %%I in ("%PKG%.") do set "PKGN=%%~fI"
for %%I in ("!GAME!.") do set "GAMEN=%%~fI"
if /i "!PKGN!"=="!GAMEN!" (
  echo [错误] 检测到补丁包被解压进了游戏目录本身（安装.bat 与 GTAIV.exe 在同一个目录）。
  echo        这样“复制到游戏目录”就变成了复制到自己，永远装不上；
  echo        而且这种情况下运行 卸载.bat 会把补丁还原掉。
  echo.
  echo        解决办法：
  echo        1. 把补丁 zip 重新解压到一个【独立文件夹】（例如桌面新建一个）；
  echo        2. 双击那个文件夹里的 安装.bat —— 它会自动找到游戏目录，不需要放进游戏目录。
  echo.
  pause
  exit /b 1
)
set "REL=plugins\GTA4.CHS\char_table.dat"
set "BAK=_ORIGINAL_char_table.dat"
call :one
set "REL=update\pc\textures\fonts.wtd"
set "BAK=_ORIGINAL_fonts_pc.wtd"
call :one
set "REL=update\TLAD\pc\textures\fonts.wtd"
set "BAK=_ORIGINAL_fonts_tlad.wtd"
call :one
set "REL=update\TBoGT\pc\textures\fonts.wtd"
set "BAK=_ORIGINAL_fonts_tbogt.wtd"
call :one
set "REL=update\common\text\american.gxt"
set "BAK=_ORIGINAL_american.gxt"
call :one
set "REL=update\TLAD\common\text\american.gxt"
set "BAK=_ORIGINAL_american_tlad.gxt"
call :one
set "REL=update\TBoGT\common\text\american.gxt"
set "BAK=_ORIGINAL_american_tbogt.gxt"
call :one
attrib -r "!GAME!\plugins\mapfix.asi" >nul 2>nul
copy /y "%PKG%plugins\mapfix.asi" "!GAME!\plugins\mapfix.asi" >nul
if errorlevel 1 (echo [失败] plugins\mapfix.asi —— 系统返回： & copy /y "%PKG%plugins\mapfix.asi" "!GAME!\plugins\mapfix.asi" & set /a FAILED+=1) else (echo [成功] plugins\mapfix.asi)
echo.
if not "!FAILED!"=="0" (
  echo [错误] 有 !FAILED! 个文件写入失败，补丁未完整安装！
  echo        常见原因：
  echo        1. 游戏或 Steam 正在运行：请全部关闭后重新运行本程序；
  echo        2. 目标文件只读 / 被云盘同步占用：右键游戏目录属性，取消只读；
  echo        3. 权限不足：右键本安装.bat，选择“以管理员身份运行”；
  echo        4. 杀毒软件拦截：查看杀软日志，把游戏目录加入白名单后重试。
  echo        诊断信息——游戏目录：!GAME!
  pause
  exit /b 1
)
echo [完成] 全部文件安装成功，启动游戏即可。
echo        如需还原，双击本文件夹里的 卸载.bat。
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

:one
if not exist "!GAME!\%REL%" echo [错误] 游戏目录缺少 %REL% ，原汉化补丁可能不完整。 & pause & exit 1
if exist "%PKG%%BAK%" goto one_copy
copy /y "!GAME!\%REL%" "%PKG%%BAK%" >nul && echo [备份] %BAK%
:one_copy
attrib -r "!GAME!\%REL%" >nul 2>nul
copy /y "%PKG%%REL%" "!GAME!\%REL%" >nul
if errorlevel 1 (echo [失败] %REL% —— 系统返回： & copy /y "%PKG%%REL%" "!GAME!\%REL%" & set /a FAILED+=1) else (echo [成功] %REL%)
exit /b 0
