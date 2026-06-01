



#PS C:\Users\kenic\Dropbox\gitdir\test> powercfg /getactivescheme 
#電源設定の GUID: fb5220ff-7e1a-47aa-9a42-50ffbf45c673  (HP Optimized (Modern Standby))

# 電源設定のGUIDを取得し、必要な部分だけを抽出
$PowerPlan = (powercfg /getactivescheme) -replace '電源設定の GUID:\s+([a-f0-9\-]+)\s+\(.*\)', '$1'
Write-Host "Debug"
Write-Output $PowerPlan

# 画面をオフにする時間を1分（60秒）に設定
# 電源に接続しているとき
powercfg /change monitor-timeout-ac 1

# バッテリ駆動のとき
powercfg /change monitor-timeout-dc 1

Write-Host "Debug"
#powercfg /query $PowerPlan
