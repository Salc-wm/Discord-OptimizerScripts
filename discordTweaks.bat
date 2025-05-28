@echo off
setlocal

rem — Debug wrapper: send all stderr to debug file —
set "logfile=%~dp0discord_optimizer_debug.txt"

echo. >> "%LOGFILE%"
echo ============================================================================== >> "%LOGFILE%"
echo Log iniciado em: %DATE% %TIME% >> "%LOGFILE%"
echo ============================================================================== >> "%LOGFILE%"
echo. >> "%LOGFILE%"


call :main 2> "%LOGFILE%"
call :cleanup_and_exit 0

:: original script created by > rifteyy << https://github.com/rifteyy/discordoptimizer/tree/main
:: New/Modified -> Calixto|Salc << ?


:main
  title Discord Optimizer
  setlocal EnableDelayedExpansion

  set "keepLanguageEN=en-US" & set "keepLanguagePT=pt-BR"
  set "text= Please choose a version to optimize: "

  chcp 65001 > nul
  setlocal enabledelayedexpansion

  for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
      set ESC=%%b
  )

  cd /d "!appdata!"
  set /a startver=0

    call :logo
        echo !text!

        set "C1=!ESC![38;2;114;137;218m"
        set "BRK=%C1%[!ESC![0m"
        set "SEP=%C1%]!ESC![0m"

        for /f "delims=" %%a in ('dir /b "Discord*"') do (
            set /a startver+=1
            set "version[!startver!]=%%a"

            call echo !BRK! !startver! !SEP! %%a    !BRK! Any !SEP! Exit
            echo.
        )

        <nul set /p="!C1!Number: !ESC![0m"
        set /p "vernum="

        goto :menu

:menu
    set "dir=!localappdata!\!version[%vernum%]!"
    title Optimizing version: !version[%vernum%]!

    if not "!vernum!"=="1" exit

    cls
    call :logo

    set "BRK=!ESC![38;2;114;137;218m[!ESC![0m"
    set "SEP=!ESC![38;2;114;137;218m]!ESC![0m"

    echo.
    echo.
    echo !BRK! 1 !SEP! Debloat                                             !BRK! 2 !SEP! Clear unused languages
    echo.
    echo !BRK! 3 !SEP! Clear log, old installations, crash reports         !BRK! 4 !SEP! Optimize priority
    echo.
    echo !BRK! 5 !SEP! Clear old application versions                      !BRK! 6 !SEP! Clear cache
    echo.
    echo !BRK! 7 !SEP! Disable Start-Up run                                !BRK! 8 !SEP! Restart !version[%vernum%]!
    echo.
    echo !BRK! 0 !SEP! Exit

    set /p "num=!ESC![30m!ESC![0mNumber: !ESC![38;2;114;137;218m"
    if "!num!"=="0" exit

    echo.
    goto action_%num%

    :action_0
        call :cleanup_and_exit 0

    :action_1
        call :debloat !version[%vernum%]!
        goto :eof

    :action_2
        call :languages !version[%vernum%]!
        goto :eof

    :action_3
        call :log !version[%vernum%]!
        goto :eof

    :action_4
        goto :optpriority

    :action_5
        call :oldapp !version[%vernum%]!
        goto :eof

    :action_6
        call :cache !version[%vernum%]!
        goto :eof

    :action_7
        reg.exe delete "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "!version[%vernum%]!" /f >nul 2>nul
        echo Discord no longer starts on startup.

        goto :eof

    :action_8
        taskkill /F /IM "!version[%vernum%]!.exe" >nul 2>nul
        "!localappdata!\!version[%vernum%]!\Update.exe" --processStart !version[%vernum%]!.exe

        echo Discord restarting!
        goto :eof

    goto :menu

:: —————————————————————————————
:debloat
    2>nul >nul taskkill.exe /F /IM "%~1.exe"
    cd /d "!dir!"

    for /f "delims=" %%a in ('dir /b "!dir!\app-*"') do (
    	call :clearver "%%~a"
    )

    exit /b 0

:clearver
    set "appnum=%~1"
    set "overall_errorlevel=0"

    if "!appnum!"=="" (
        echo Error: The 'appnum' argument was not supplied.
        endlocal

        exit /b 1
    )

    set "module_dir=!dir!\!appnum!\modules"

    if exist "!module_dir!" (
        pushd "!module_dir!"

        echo Processing directory: !cd:%USERPROFILE%\=!
        if errorlevel 1 (
            echo Error: Failed to switch to directory "!module_dir!".
            set "overall_errorlevel=1"
            REM popd is not needed here, as pushd failed.

            goto :cleanup
        )

        for /d %%a in (*) do (
            set "folder=%%a"  REM 'folder' is defined in each iteration
            echo(!folder! | findstr /b /i /c:"discord_desktop_core-" /c:"discord_modules-" /c:"discord_utils-" /c:"discord_voice-" >nul

            if errorlevel 1 (
                echo Deleting: !folder!
                rd /s /q "!folder!" >nul 2>nul

                if errorlevel 1 (
                    echo Warning: Failed to delete "!folder!". It may be in use or access is denied.
                    REM You may want to set "overall_errorlevel=1" here if a deletion failure is critical.
                )
            ) else echo Keeping: !folder!
        )

        popd
    ) else (
        echo Info: Module directory "!module_dir!" not found for app !appnum!.
        REM Depending on your logic, this may or may not be an error.
        REM set "overall_errorlevel=1" if it is considered an error.
    )

:cleanup
    endlocal REM Restores the environment prior to 'setlocal' at the start of the subroutine
    exit /b %overall_errorlevel%


:languages
    for /f "delims=" %%a in ('dir /b "!dir!\app-*"') do (
	    call :clearlang "%%~a"
        exit /b 1
    )

:clearlang
    set "locales_dir=!dir!\%~1\locales"
    echo [INFO] Analyzing the directory: "!locales_dir:%USERPROFILE%\=!"

    if not exist "!locales_dir!\" (
        echo [ERROR] Directory not found. Operation cancelled.
        exit /b 1
    )

    :: cd "!dir!\%~1\locales"
    cd /d "!locales_dir!

    echo [INFO] Directory found. Starting language file cleanup...
    set "file_to_keep_1=!keepLanguageEN!.pak"
    set "file_to_keep_2=!keepLanguagePT!.pak"
    echo [INFO] Languages that will be KEPT: !file_to_keep_1! e !file_to_keep_2! !keepLanguageEN!
    echo.

    set "deleted_count=0"
    echo [ACTION] Removing other language files (.pak)...

    for /f "delims=" %%a in ('dir /b *.pak') do (
        :: if /i not "%%a"=="!keepLanguageEN!.pak" if /i not "%%a"=="!keepLanguagePT!.pak" del /f /q "%%a" >nul 2>nul
        if /i not "%%a"=="!file_to_keep_1!" if /i not "%%a"=="!file_to_keep_2!" (
            echo   -> Removing: "%%a"
            del /f /q "%%a"

            set /a "deleted_count+=1"
        )
    )

    echo.
    echo [DONE] Cleaning completed successfully.
    echo [SUMMARY] Total language files removed:: !deleted_count!

    exit /b 0

:log
    call :safe_del "!dir!\*.log" "1/4 - Main directory logs"
    call :safe_del "!dir!\packages\*.nupkg" "2/4 - Packages .nupkg"
    call :safe_del "!appdata!\%~1\*.log" "3/4 - AppData Logs"
    call :safe_del "!appdata!\%~1\crashpad\reports\*.dmp" "4/4 - Crash reports (.dmp)"

    echo.
    exit /b 0

    :safe_del <file> <descript>
        set "target=%~1"
        set "desc=%~2"

        echo.

        set "root=!appdata!"
        set "rootlocal=!localappdata!"

        echo(!target! | find /i "!root!" >nul && set "relpath=!target:%root%\=!"
        echo(!target! | find /i "!rootlocal!" >nul && set "relpath=!target:%rootlocal%\=!"

        if not defined relpath set "relpath=!target!"
        echo [%desc%] Deleting files in: !relpath!

        del /f /q /s "%target%" 2> "%temp%\_del_err.log"

        set "foundErr="
        for /f "usebackq delims=" %%E in ("%temp%\_del_err.log") do (
            set "errmsg=%%E"
            set "foundErr=1"

            call :analyze_error "!errmsg!"
        )

        if not defined foundErr echo   All files deleted successfully.
        del "%temp%\_del_err.log" >nul 2>nul

        exit /b
    :analyze_error
        set "line=%~1"
        echo %line% | find /i "Could Not Find" >nul

        if %errorlevel%==0 (
            echo   No files found.
            exit /b
        )

        echo %line% | find /i "being used by another process" >nul
        if %errorlevel%==0 (
            echo   File in use by another process. Ignored.
            exit /b
        )

        echo   Unknown error: %line%
        exit /b

:priority
    set "appName=%~1.exe"
    set "regPath=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%appName%\PerfOptions"

    reg add "%regPath%" /v "CpuPriorityClass" /t REG_DWORD /d 3 /f

    echo High Definition Priority for Discord!
    call :cleanup_and_exit 0

:oldapp
    set "critical_error=0"

    if /i not "%~1"=="discord" (
        echo ERROR: This optimization can only be used with "discord". You provided: "%~1".
        set "critical_error=1"

        goto :oldapp_cleanup
    )

    set "target_app_name=%~1"
    set "base_dir=%LOCALAPPDATA%\!target_app_name!"

    ::set "dir=!localappdata!\%~1"
    ::cd /d "!dir!"

    REM Change to the target directory
    pushd "!base_dir!"
    if errorlevel 1 (
        echo ERROR: Failed to change directory to "!base_dir!". Check if the path is correct.
        set "critical_error=1"
        goto :oldapp_cleanup
    )

    echo INFO: Successfully changed to directory: !CD:%USERPROFILE%\=!
    echo INFO: Scanning for app-* directories in !CD:%USERPROFILE%\=!...
    for /d %%a in ("!dir!\app-*") do (
        ::set "ver=%%~na"
        ::setlocal EnableDelayedExpansion
        ::set "ver=!ver:app-=!"
        set "folder_name=%%~nxa"  REM %%~nxa gets name and extension (which is empty for folders)
                                  REM %%~na would also work if there are no dots in the folder name itself besides versioning.
        set "version_string=!folder_name:app-=!"

        echo.
        for /f "tokens=1 delims=." %%v in ("!version_string!") do (
            if not %%v==1 (
                ::echo INFO: Found old version directory: "%%a" (Version: !version_string!)
                echo INFO: Deleting "%%a"...

                rd /s /q "%%a" >nul 2>nul
                if errorlevel 1 (
                    echo WARNING: Failed to delete directory "%%a". It might be in use or access denied.
                ) else echo INFO: Successfully deleted "%%a". )
            ) else echo INFO: Keeping current version directory: "%%a" (Version: !version_string!) )
        )
    )

    popd
    echo.
    echo INFO: Finished processing. Returned to original directory.

:oldapp_cleanup
    REM If a critical error occurred (like wrong argument or failed cd), pause for the user.
    if "!critical_error!"=="1" pause

    REM End the local environment, restoring previous variable values and delayed expansion state.
    endlocal

    REM Exit the subroutine, returning 0 for success or 1 for critical error.
    exit /b %critical_error%


:cache
    echo [INFO] Starting cache clearing for %~1...
    echo.

    echo [ACTION] Accessing directory: !appdata:%USERPROFILE%\=!\%~1
    cd "!appdata!\%~1"
    if errorlevel 1 (
        echo [ERROR] Unable to access directory !appdata:%USERPROFILE%\=!\%~1. Check the application name.
        echo.
        exit /b 1
    )

    echo [ACTION] Trying to close the process: %~1.exe
    2>nul >nul taskkill.exe /F /IM "%~1.exe"
    if errorlevel 128 echo [AVISO] Process %~1.exe not found or cannot be closed. It may already be closed.
    else echo [OK] Process %~1.exe closed (or was not running).

    echo.

    echo [ACTION] Clearing cache folders...
    for %%a in ("Cache" "GPUCache") do (
        if exist "%%a" (
            echo [ACTION] Clearing content from: %%a\*
            2>nul >nul del /f /s /q "%%a\*"

            echo.
            echo [OK] %%a content cleared.
        ) else echo [WARNING] Folder %%a not found.

    if exist "Code Cache" (
        echo [ACTION] Clearing content from: Code Cache\*
        2>nul >nul del /f /s /q "Code Cache\*"
        echo [OK] Clear Code Cache Contents.
    ) else echo [WARNING] Code Cache folder not found.

    exit /b 0


:logo
    call :echo-align center "!ESC![0mgithub.com/Salc-wm" -24
    echo.
    for %%a in (
"  ██████╗ ██╗███████╗ ██████╗ ██████╗ ██████╗ ██████╗ "
"  ██╔══██╗██║██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔══██╗"
"  ██║  ██║██║███████╗██║     ██║   ██║██████╔╝██║  ██║"
"  ██║  ██║██║╚════██║██║     ██║   ██║██╔══██╗██║  ██║"
"  ██████╔╝██║███████║╚██████╗╚██████╔╝██║  ██║██████╔╝"
"  ╚═════╝ ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ "
    ) do call :echo-align center "!ESC![38;2;114;137;218m%%~a!ESC![0m" 0
    call :echo-align center "Optimizer" -30
    echo.

    exit /b 0

:optpriority
    cls
    call :logo
    echo.
    echo.

    tasklist /fi "ImageName eq !version[%vernum%]!.exe" /fo csv 2>NUL | find /I "!version[%vernum%]!.exe">NUL
    if "%ERRORLEVEL%"=="1" (
	    echo ERROR: Please launch !version[%vernum%]! to tweak priority.
    	pause
    	goto :menu
    )

    set "C1=!ESC![38;2;114;137;218m"
    set "BRK=%C1%[!ESC![0m"
    set "SEP=%C1%]!ESC![0m"

    echo.
    echo %BRK% 1 %SEP% Lower Discord Usage (Ideal for gaming with Discord in background)
    echo.
    echo %BRK% 2 %SEP% Higher Discord usage (Ideal for calling, better voice, faster response)
    echo.
    echo %BRK% 3 %SEP% Reset usage to normal
    echo.
    echo %BRK% 4 %SEP% Back to menu
    echo.

    set /p "num=!ESC![30m!ESC![0mNumber: !ESC![38;2;114;137;218m"
    set "exe=!version[%vernum%]!.exe"

    if "!num!"=="1" (
        set "regval=1"
        set "prio=64"
    ) else if "!num!"=="2" (
        set "regval=3"
        set "prio=128"
    ) else if "!num!"=="3" (
        set "regval=2"
        set "prio=32"
    ) else if "4" goto :menu

    if defined regval (
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\!exe!\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d !regval! /f >nul 2>nul
        wmic process where name="!exe!" CALL setpriority "!prio!" >nul 2>nul
    )

    goto :optpriority

:cleanup_and_exit
    endlocal
    exit /b %1

echo. & pause >nul
goto :eof

:: By hXR16F << https://github.com/hXR16F/echo-align/tree/main
:echo-align <align> <text> <size>
	setlocal EnableDelayedExpansion
	(set^ tmp=%~2)

	if defined tmp (
		set "len=1"
		for %%p in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
			if "!tmp:~%%p,1!" neq "" (
				set /a "len+=%%p"
				set "tmp=!tmp:~%%p!"
			)
		)
	) else set len=0

	for /f "skip=4 tokens=2 delims=:" %%i in ('mode con') do (
		set /a cols=%%i
		goto loop_end
	)

	:loop_end
    	if /i "%1" equ "center" (
    		set /a offsetnum=^(%cols% / 2^) - ^(%len% / 2 - %3^)
    		set "offset="
    		for /l %%i in (1 1 !offsetnum!) do set "offset=!offset! "
    	)
        ::else if /i "%1" equ "right" (
    	::	set /a offsetnum=^(%cols% - %len%^)
    	::	set "offset="
    	::	for /l %%i in (1 1 !offsetnum!) do set "offset=!offset! "
    	::)

    	echo %offset%%~2
    	endlocal

	exit /b

