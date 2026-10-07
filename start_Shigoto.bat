rem @echo off
rem	START "" "%TARGET_DIR%"


set yyyy=%date:~0,4%
set mm=%date:~5,2%
set dd=%date:~8,2%


echo %yyyy%
echo %mm%


rem	TEST----------------------------------------------------------------------------------
echo 現在のカレントフォルダは: %CD%

pause
rem	----------------------------------------------------------------------------------

start /b /max code C:\Users\kenic\Dropbox\gitdir\hikitsugi
 
powershell -ExecutionPolicy Bypass -NoProfile -File "C:\Users\kenic\Dropbox\gitdir\start_Shigoto\Open_teams.ps1"
set /p dummy=続行するには Enter を押してください...

python C:\Users\kenic\Dropbox\gitdir\CopyAndOpenExcel\download_LOGNOTE_GUI.py SP8 %yyyy% %mm% true
set /p dummy=続行するには Enter を押してください...
python C:\Users\kenic\Dropbox\gitdir\CopyAndOpenExcel\download_LOGNOTE_GUI.py SACLA %yyyy% %mm% true
set /p dummy=続行するには Enter を押してください...
python C:\Users\kenic\Dropbox\gitdir\CopyAndOpenExcel\download_LOGNOTE_GUI.py SCSS %yyyy% %mm% true


set /p dummy=続行するには Enter を押してください...

rem フルパスで実行しつつ作業ディレクトリを指定:
cd /d C:\me\open_web
call C:\me\open_web\open_web.bat

rem ChromeのBookmark"流行り"を開く
rem python C:\Users\kenic\Dropbox\gitdir\open_chrome_bookmarks\open_chrome_bookmarks.py     mdaq_loader.html



rem cd /d "C:\Users\kenic\Dropbox\gitdir\open_chrome_bookmarks"
rem start "" python -m http.server 8080
rem timeout /t 5 >nul
rem start "" http://localhost:8080/mdaq_loader.html
rem pause


rem サーバー接続
start "" C:\Users\kenic\Dropbox\gitdir\Startup\server_login.bat

rem 2026年度シフト表.xlsmをDropboxにコピーする  
copy \\saclaopr18.spring8.or.jp\common\シフト\2026年度\2026年度シフト表.xlsm C:\Users\kenic\Dropbox
if %ERRORLEVEL% neq 0 (
    echo "Fail"
    exit /b %ERRORLEVEL%
) else (
    echo "OK"
)

rem 運転集計のバックアップをDropboxにコピーする
xcopy /E /I \\saclaopr18.spring8.or.jp\common\運転状況集計\最新\SACLA D:\BU\運転集計のバックアップ\最新\SACLA_%yyyy%_%mm%_%dd%
if %ERRORLEVEL% neq 0 (
    echo "Fail"
    exit /b %ERRORLEVEL%
) else (
    echo "OK"
)




rem ディスプレイの画面をオフにする時間を１分にする
powershell -ExecutionPolicy Bypass -NoProfile -File "C:\Users\kenic\Dropbox\gitdir\start_Shigoto\SetScreenTimeout.ps1"

rem WifiのホットスポットをONにする
powershell -ExecutionPolicy Bypass -NoProfile -File "C:\Users\kenic\Dropbox\gitdir\setup-ntfy\hotspot-wifi.ps1"

rem PC起動時に自動で実行するタスク(ntfy-autostart)が存在するか確認
rem powershell -ExecutionPolicy Bypass Get-ScheduledTask -TaskName "hotspot-wifi-autostart"

rem Oto Monitor GUIを起動する
python C:\Users\kenic\Dropbox\gitdir\Oto_New\oto_monitor_gui.pyw

rem Activeメール受信スクリプト起動
start C:\Users\kenic\AppData\Local\Programs\Python\Python313\python.exe C:\Users\kenic\Dropbox\gitdir\check_latest_mail_IMAP4\check_latest_mail_IMAP4.py kenichi ribsgroup


exit /b 0

pause