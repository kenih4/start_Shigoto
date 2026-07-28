rem @echo off
rem	START "" "%TARGET_DIR%"

echo %%0 = %0
echo %%1 = %1
echo %%2 = %2
echo %%3 = %3

set yyyy=%date:~0,4%
set mm=%date:~5,2%
set dd=%date:~8,2%


echo %yyyy%
echo %mm%


rem	TEST----------------------------------------------------------------------------------
echo 現在のカレントフォルダは: %CD%
rem	----------------------------------------------------------------------------------

copy \\saclaoprfs01.spring8.or.jp\log_note\SACLA\operation_log\%yyyy%\%mm%\%yyyy%_%mm%.xlsm C:\Users\kenic\Documents\operation_log_NEW\SACLA\%yyyy%_%mm%_SACLA.xlsm
copy \\saclaoprfs01.spring8.or.jp\log_note\SCSs\operation_log\%yyyy%\%mm%\%yyyy%_%mm%_SCSS.xlsm C:\Users\kenic\Documents\operation_log_NEW\SCSS\%yyyy%_%mm%_SCSS.xlsm
copy \\saclaoprfs01.spring8.or.jp\log_note\SP8\operation_log\%yyyy%\%mm%\%yyyy%_%mm%.xlsm C:\Users\kenic\Documents\operation_log_NEW\SP8\%yyyy%_%mm%_SP8.xlsm

rem pause
set /p dummy=続行するには Enter を押してください...












start C:\Users\kenic\Documents\operation_log_NEW\SACLA\%yyyy%_%mm%_SACLA.xlsm
rem timeout /t -1
set /p dummy=続行するには Enter を押してください...

start C:\Users\kenic\Documents\operation_log_NEW\SCSS\%yyyy%_%mm%_SCSS.xlsm
rem timeout /t -1
set /p dummy=続行するには Enter を押してください...

start C:\Users\kenic\Documents\operation_log_NEW\SP8\%yyyy%_%mm%_SP8.xlsm


rem set /p dummy=続行するには Enter を押してください...

exit /b 0

pause