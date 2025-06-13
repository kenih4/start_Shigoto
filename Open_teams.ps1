Add-Type @"
using System;
using System.Runtime.InteropServices;

public class WinAPI {
    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

# Teams�̃v���Z�X�擾
$proc = Get-Process -Name "ms-teams" -ErrorAction SilentlyContinue

if (-not $proc) {
    Write-Output "ms-teams.exe ���N�����Ă��Ȃ��̂ŁA�N�����܂�..."
    Start-Process "ms-teams:"
    Start-Sleep -Seconds 10  # �N���Ɏ��Ԃ������邽�ߑҋ@�i�K�v�ɉ����Ē����j
    # �Ď擾
    $proc = Get-Process -Name "ms-teams" -ErrorAction SilentlyContinue
}else {
    Write-Output "ms-teams.exe �͂��łɋN�����Ă��܂��B"
}   



$proc = Get-Process -Name "ms-teams" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 }

Write-Output "proc =  [ $proc ]"

if ($proc) {
    foreach ($p in $proc) {
        Write-Output "Debug $p"

        $hwnd = $p.MainWindowHandle

        # �E�B���h�E��\���iSW_RESTORE = 9�j
        [WinAPI]::ShowWindowAsync($hwnd, 3) #�ő剻���ĕ\��

        # �őO�ʂɎ����Ă���
        [WinAPI]::SetForegroundWindow($hwnd)

        Write-Output "ms-teams �E�B���h�E��O�ʂɕ\�����܂����B"
    }
} else {
    Write-Output "ms-teams.exe �̓E�B���h�E�������Ă��܂���B"
    Start-Process "ms-teams"
}





# Open Channel [���~�[�e�B���O]
Start-Process "https://teams.microsoft.com/l/channel/19%3Ab75283a8ac374119b1507a1e076cc817%40thread.tacv2/%E6%9C%9D%E3%83%9F%E3%83%BC%E3%83%86%E3%82%A3%E3%83%B3%E3%82%B0%EF%BC%88%E5%8A%A0%E9%80%9F%E5%99%A8%EF%BC%89?groupId=5dbfd7f4-6b93-4638-b960-fec23213fc2a&tenantId=b1ce6928-6dd8-436d-9cc8-427132b02adf"




$proc = Get-Process -Name "ms-teams" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 }

Write-Output "proc =  [ $proc ]"
if ($proc) {
    foreach ($p in $proc) {
        Write-Output "Debug $p"

        $hwnd = $p.MainWindowHandle

        # �E�B���h�E��\���iSW_RESTORE = 9�j
        [WinAPI]::ShowWindowAsync($hwnd, 3) #�ő剻���ĕ\��

        # �őO�ʂɎ����Ă���
        [WinAPI]::SetForegroundWindow($hwnd)

        Write-Output "ms-teams �E�B���h�E��O�ʂɕ\�����܂����B"
    }
}



<#
# ���C���E�B���h�E�������Ă���v���Z�X�����ɍi��
$visibleProc = $proc | Where-Object { $_.MainWindowHandle -ne 0 }
if ($visibleProc) {
    foreach ($p in $visibleProc) {
        $hwnd = $p.MainWindowHandle
        # �E�B���h�E�����i�ŏ�������Ă���ꍇ�j
        [WinAPI]::ShowWindowAsync($hwnd, 9)
        # �őO�ʂɕ\��
        [WinAPI]::SetForegroundWindow($hwnd)
        Write-Output "ms-teams �̃E�B���h�E���őO�ʂɕ\�����܂����B"
    }
} else {
    Write-Output "ms-teams.exe �͂܂��E�B���h�E��\�����Ă��Ȃ��悤�ł��B"
}#>