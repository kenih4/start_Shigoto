@echo off
rem メモ帳で開くと文字化けしてしまうので注意
rem 2024/5/20 SHIFT-JIS

rem	SET TARGET_DIR=\\saclaopr18.spring8.or.jp\common\ V t g\2020 N x\   p  \
rem	NET USE %TARGET_DIR% ses@sacla5712 /USER:sesoper
rem	START "" "%TARGET_DIR%"


set yyyy=%date:~0,4%
set mm=%date:~5,2%
set dd=%date:~8,2%




echo %yyyy%
echo %mm%


rem	TEST----------------------------------------------------------------------------------
rem	----------------------------------------------------------------------------------





start /b /max code C:\Users\kenichi\Dropbox\gitdir\hikitsugi


timeout 5








rem	http://saclaopr19.spring8.or.jp/~logsearch/viewer/?SCSS/operation_log/2021/10/2021_10_02_shift3.htm
copy \\saclaoprfs01.spring8.or.jp\log_note\SACLA\operation_log\%yyyy%\%mm%\%yyyy%_%mm%.xlsm C:\Users\kenichi\Documents\operation_log_NEW\SACLA
start C:\Users\kenichi\Documents\operation_log_NEW\SACLA\%yyyy%_%mm%.xlsm
timeout 50
rem pause

copy \\saclaoprfs01.spring8.or.jp\log_note\SCSs\operation_log\%yyyy%\%mm%\%yyyy%_%mm%_SCSS.xlsm C:\Users\kenichi\Documents\operation_log_NEW\SCSS
start C:\Users\kenichi\Documents\operation_log_NEW\SCSS\%yyyy%_%mm%_SCSS.xlsm
timeout 50

copy \\saclaoprfs01.spring8.or.jp\log_note\SP8\operation_log\%yyyy%\%mm%\%yyyy%_%mm%.xlsm C:\Users\kenichi\Documents\operation_log_NEW\SP8\%yyyy%_%mm%_SP8.xlsm
start C:\Users\kenichi\Documents\operation_log_NEW\SP8\%yyyy%_%mm%_SP8.xlsm
timeout 50

rem	C:\me\bin\open_note.exe SACLA 0
rem	timeout 50
rem	C:\me\bin\open_note.exe SCSS 0
rem	timeout 10
rem	C:\me\bin\open_note.exe SP8 0


timeout 60
call C:\me\open_web\open_web.bat








rem start /b C:\me\bin\login_by_ChromeDriver_auto_update_chrmedriver.exe kenichi ribsgroup



timeout 600

copy \\saclaopr18.spring8.or.jp\common\シフト\2024年度\2024年度シフト表.xlsm C:\Users\kenichi\Dropbox
if %ERRORLEVEL% neq 0 (
    echo エラー: ファイルのコピーに失敗しました。
    rem エラーログを記録する場合などの処理を追加
    exit /b %ERRORLEVEL%
) else (
    echo ファイルのコピーが成功しました。
)




rem Xcopyコマンドを使うときに、｢ファイル名ですか、またはディレクトリ名ですか｣と聞かれたときに「ディレクトリ名」で自動処理する方法ためにecho D
echo D | xcopy /e /y \\saclaopr18.spring8.or.jp\common\運転状況集計\最新 C:\Users\kenichi\Documents\BU\運転集計のバックアップ\最新_%yyyy%_%mm%_%dd%
if %ERRORLEVEL% neq 0 (
    echo エラー: ファイルのコピーに失敗しました。
    rem エラーログを記録する場合などの処理を追加
    exit /b %ERRORLEVEL%
) else (
    echo ファイルのコピーが成功しました。
)





"C:\Program Files (x86)\Dropbox\Client\Dropbox.exe"




pause




