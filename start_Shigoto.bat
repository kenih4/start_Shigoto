rem 2024/5/20 SHIFT-JIS

rem	SET TARGET_DIR=\\saclaopr18.spring8.or.jp\common\ V t g\2020 N x\   p  \
rem	NET USE %TARGET_DIR% ses@sacla5712 /USER:sesoper
rem	START "" "%TARGET_DIR%"


rem	start \\saclaopr18.spring8.or.jp\common\ V t g\2020 N x\   p  \   p     ??? .xlsx

rem	start \\saclaopr18.spring8.or.jp\common\ V t g\2020 N x\   p  \SACLA_L2 ? .xlsx
rem	start \\saclaopr18.spring8.or.jp\common\ V t g\2020 N x\      Z p  - ?  ?  V [ g.xlsx
rem	pause



start /b /max code C:\Users\kenichi\Dropbox\gitdir\hikitsugi


set yyyy=%date:~0,4%
set mm=%date:~5,2%
set dd=%date:~8,2%




echo %yyyy%
echo %mm%

rem	http://saclaopr19.spring8.or.jp/~logsearch/viewer/?SCSS/operation_log/2021/10/2021_10_02_shift3.htm
copy \\saclaoprfs01.spring8.or.jp\log_note\SACLA\operation_log\%yyyy%\%mm%\%yyyy%_%mm%.xlsm C:\Users\kenichi\Documents\operation_log\SACLA
start C:\Users\kenichi\Documents\operation_log\SACLA\%yyyy%_%mm%.xlsm
timeout 50

copy \\saclaoprfs01.spring8.or.jp\log_note\SCSS\operation_log\%yyyy%\%mm%\%yyyy%_%mm%_SCSS.xlsm C:\Users\kenichi\Documents\operation_log\SCSS
start C:\Users\kenichi\Documents\operation_log\SCSS\%yyyy%_%mm%_SCSS.xlsm
timeout 50

copy \\saclaoprfs01.spring8.or.jp\log_note\SP8\operation_log\%yyyy%\%mm%\%yyyy%_%mm%.xlsm C:\Users\kenichi\Documents\operation_log\SP8\%yyyy%_%mm%_SP8.xlsm
start C:\Users\kenichi\Documents\operation_log\SP8\%yyyy%_%mm%_SP8.xlsm
timeout 50

rem	C:\me\bin\open_note.exe SACLA 0
rem	timeout 50
rem	C:\me\bin\open_note.exe SCSS 0
rem	timeout 10
rem	C:\me\bin\open_note.exe SP8 0


timeout 1
call C:\me\open_web\open_web.bat
timeout 1



copy \\saclaopr18.spring8.or.jp\common\シフト\2024年度\2024年度シフト表.xlsm C:\Users\kenichi\Dropbox
pause


start C:\me\bin\login_by_ChromeDriver_auto_update_chrmedriver.exe kenichi ribsgroup
rem	pause