rem @echo off
rem	START "" "%TARGET_DIR%"


set yyyy=%date:~0,4%
set mm=%date:~5,2%
set dd=%date:~8,2%




echo %yyyy%
echo %mm%


rem	TEST----------------------------------------------------------------------------------
rem	----------------------------------------------------------------------------------





start /b /max code C:\Users\kenic\Dropbox\gitdir\hikitsugi


timeout 7








rem	http://saclaopr19.spring8.or.jp/~logsearch/viewer/?SCSS/operation_log/2021/10/2021_10_02_shift3.htm
copy \\saclaoprfs01.spring8.or.jp\log_note\SACLA\operation_log\%yyyy%\%mm%\%yyyy%_%mm%.xlsm C:\Users\kenic\Documents\operation_log_NEW\SACLA
copy \\saclaoprfs01.spring8.or.jp\log_note\SCSs\operation_log\%yyyy%\%mm%\%yyyy%_%mm%_SCSS.xlsm C:\Users\kenic\Documents\operation_log_NEW\SCSS
copy \\saclaoprfs01.spring8.or.jp\log_note\SP8\operation_log\%yyyy%\%mm%\%yyyy%_%mm%.xlsm C:\Users\kenic\Documents\operation_log_NEW\SP8\%yyyy%_%mm%_SP8.xlsm


start C:\Users\kenic\Documents\operation_log_NEW\SACLA\%yyyy%_%mm%.xlsm
rem timeout /t -1
set /p dummy=���s����ɂ� Enter �������Ă�������...

start C:\Users\kenic\Documents\operation_log_NEW\SCSS\%yyyy%_%mm%_SCSS.xlsm
rem timeout /t -1
set /p dummy=���s����ɂ� Enter �������Ă�������...

start C:\Users\kenic\Documents\operation_log_NEW\SP8\%yyyy%_%mm%_SP8.xlsm



rem	C:\me\bin\open_note.exe SACLA 0
rem	timeout 50
rem	C:\me\bin\open_note.exe SCSS 0
rem	timeout 10
rem	C:\me\bin\open_note.exe SP8 0


timeout 60
call C:\me\open_web\open_web.bat








rem start /b C:\me\bin\login_by_ChromeDriver_auto_update_chrmedriver.exe kenichi ribsgroup



timeout 600

copy \\saclaopr18.spring8.or.jp\common\�V�t�g\2025�N�x\2025�N�x�V�t�g�\.xlsm C:\Users\kenic\Dropbox
if %ERRORLEVEL% neq 0 (
    echo "Fail"
    exit /b %ERRORLEVEL%
) else (
    echo "OK"
)


xcopy /E /I \\saclaopr18.spring8.or.jp\common\�^�]�󋵏W�v\�ŐV C:\Users\kenic\Documents\BU\�^�]�W�v�̃o�b�N�A�b�v\�ŐV_%yyyy%_%mm%_%dd%
if %ERRORLEVEL% neq 0 (
    echo "Fail"
    exit /b %ERRORLEVEL%
) else (
    echo "OK"
)
exit /b 0






rem "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe"




set /p dummy=���s����ɂ� Enter �������Ă�������...




