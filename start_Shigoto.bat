rem @echo off
rem	START "" "%TARGET_DIR%"


set yyyy=%date:~0,4%
set mm=%date:~5,2%
set dd=%date:~8,2%


echo %yyyy%
echo %mm%


rem	TEST----------------------------------------------------------------------------------
echo 現在のカレントフォルダは: %CD%
rem	----------------------------------------------------------------------------------

start /b /max code C:\Users\kenic\Dropbox\gitdir\hikitsugi
 
powershell -ExecutionPolicy Bypass -NoProfile -File "C:\Users\kenic\Dropbox\gitdir\start_Shigoto\Open_teams.ps1"
set /p dummy=続行するには Enter を押してください...

python C:\Users\kenic\Dropbox\gitdir\CopyAndOpenExcel\download_LOGNOTE_GUI.py SACLA %yyyy% %mm% true
set /p dummy=続行するには Enter を押してください...
python C:\Users\kenic\Dropbox\gitdir\CopyAndOpenExcel\download_LOGNOTE_GUI.py SCSS %yyyy% %mm% true
set /p dummy=続行するには Enter を押してください...
python C:\Users\kenic\Dropbox\gitdir\CopyAndOpenExcel\download_LOGNOTE_GUI.py SP8 %yyyy% %mm% true


rem~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GOTO SKIP

rem	http://saclaopr19.spring8.or.jp/~logsearch/viewer/?SCSS/operation_log/2021/10/2021_10_02_shift3.htm
copy \\saclaoprfs01.spring8.or.jp\log_note\SACLA\operation_log\%yyyy%\%mm%\%yyyy%_%mm%.xlsm C:\Users\kenic\Documents\operation_log_NEW\SACLA\%yyyy%_%mm%_SACLA.xlsm
copy \\saclaoprfs01.spring8.or.jp\log_note\SCSs\operation_log\%yyyy%\%mm%\%yyyy%_%mm%_SCSS.xlsm C:\Users\kenic\Documents\operation_log_NEW\SCSS\%yyyy%_%mm%_SCSS.xlsm
copy \\saclaoprfs01.spring8.or.jp\log_note\SP8\operation_log\%yyyy%\%mm%\%yyyy%_%mm%.xlsm C:\Users\kenic\Documents\operation_log_NEW\SP8\%yyyy%_%mm%_SP8.xlsm

rem pause
set /p dummy=続行するには Enter を押してください...



rem C:\Users\kenic\OneDrive\Desktop\hikitsugi.lnk










start C:\Users\kenic\Documents\operation_log_NEW\SACLA\%yyyy%_%mm%_SACLA.xlsm
rem timeout /t -1
set /p dummy=続行するには Enter を押してください...

start C:\Users\kenic\Documents\operation_log_NEW\SCSS\%yyyy%_%mm%_SCSS.xlsm
rem timeout /t -1
set /p dummy=続行するには Enter を押してください...

start C:\Users\kenic\Documents\operation_log_NEW\SP8\%yyyy%_%mm%_SP8.xlsm



rem	C:\me\bin\open_note.exe SACLA 0
rem	timeout 50
rem	C:\me\bin\open_note.exe SCSS 0
rem	timeout 10
rem	C:\me\bin\open_note.exe SP8 0
rem~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:SKIP

timeout 60
call C:\me\open_web\open_web.bat

timeout 10


rem python C:\Users\kenic\Dropbox\gitdir\open_chrome_bookmarks\open_chrome_bookmarks.py     mdaq_loader.html
rem cd /d "C:\Users\kenic\Dropbox\gitdir\open_chrome_bookmarks"
rem start "" python -m http.server 8080
rem timeout /t 5 >nul
rem start "" http://localhost:8080/mdaq_loader.html
rem pause






rem start /b C:\me\bin\login_by_ChromeDriver_auto_update_chrmedriver.exe kenichi ribsgroup



rem timeout 600

copy \\saclaopr18.spring8.or.jp\common\シフト\2026年度\2026年度シフト表.xlsm C:\Users\kenic\Dropbox
if %ERRORLEVEL% neq 0 (
    echo "Fail"
    exit /b %ERRORLEVEL%
) else (
    echo "OK"
)


xcopy /E /I \\saclaopr18.spring8.or.jp\common\運転状況集計\最新 D:\BU\運転集計のバックアップ\最新_%yyyy%_%mm%_%dd%
if %ERRORLEVEL% neq 0 (
    echo "Fail"
    exit /b %ERRORLEVEL%
) else (
    echo "OK"
)







rem "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe"

rem ディスプレイの画面をオフにする時間を１分にする
powershell -ExecutionPolicy Bypass -NoProfile -File "C:\Users\kenic\Dropbox\gitdir\start_Shigoto\SetScreenTimeout.ps1"


rem ntfy-autostartのタスクが存在するか確認
rem 管理者　powershell -ExecutionPolicy Bypass -File C:\Users\kenic\Dropbox\gitdir\setup-ntfy\setup-ntfy.ps1
powershell -ExecutionPolicy Bypass Get-ScheduledTask -TaskName "ntfy-autostart"
rem powershell -ExecutionPolicy Bypass C:\Users\kenic\Dropbox\gitdir\setup-ntfy\notify.ps1 -Message "start_Shigoto.bat: ntfy-autostartのタスクが存在するか確認"

python C:\Users\kenic\Dropbox\gitdir\Oto_New\oto_monitor_gui.pyw

rem set /p dummy=続行するには Enter を押してください...

exit /b 0

pause