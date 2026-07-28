

# ポイント
#   -Month は "7" のように1桁で指定しても、スクリプト内で自動的に "07" に変換されます。
#   コピー先のフォルダー（operation_log_NEW\<種類>）が存在しない場合は、スクリプトが自動でフォルダーを作成してからコピーします。

# 日本語（全角文字）を含むPowerShellスクリプトを保存する際は、文字コードを 「BOM付きUTF-8」 または 「Shift-JIS」 にする必要があります。

param (
    [Parameter(Mandatory=$true)]
    [string]$Type,

    [Parameter(Mandatory=$true)]
    [string]$Year,

    [Parameter(Mandatory=$true)]
    [string]$Month
)

# 1桁の月（例: 7）が指定された場合、2桁（例: 07）に自動で変換する
if ($Month.Length -eq 1) {
    $Month = "0" + $Month
}

# コピー元・コピー先のパスを設定
$SourcePath = "\\saclaoprfs01.spring8.or.jp\log_note\$Type\operation_log\$Year\$Month\${Year}_${Month}.xlsm"
$SourcePath_2 = "\\saclaoprfs01.spring8.or.jp\log_note\$Type\operation_log\$Year\$Month\${Year}_${Month}_${Type}.xlsm"
$DestFolder = "C:\Users\kenic\Documents\operation_log_NEW\$Type"
$DestPath   = "$DestFolder\${Year}_${Month}_${Type}.xlsm"

Write-Host "----------------------------------------"
Write-Host "コピー元: $SourcePath または $SourcePath_2"
Write-Host "コピー先: $DestPath"
Write-Host "----------------------------------------"

# コピー先のフォルダーが存在しない場合は作成する
if (-not (Test-Path $DestFolder)) {
    New-Item -ItemType Directory -Path $DestFolder | Out-Null
    Write-Host "コピー先フォルダーを作成しました。"
}


# サーバー上のファイルが存在するか確認
if (Test-Path $SourcePath) {
    $SourcePath_Exist = $SourcePath
}
elseif (Test-Path $SourcePath_2) {
    $SourcePath_Exist = $SourcePath_2
}
else {
    $SourcePath_Exist = $null
}


if ($null -ne $SourcePath_Exist) {
    try {
        # ファイルをコピー
        Copy-Item -Path $SourcePath_Exist -Destination $DestPath -Force -ErrorAction Stop #-ErrorAction Stop を付けると、非終端エラーが 終端エラー（例外）として throw されるようになります。
        Write-Host "ファイルのコピーが成功しました。" -ForegroundColor Green
        
        # コピーしたエクセルファイルを開く
        Write-Host "エクセルを開いています..."
        Invoke-Item -Path $DestPath
        exit
    }
    catch {
        Write-Error "エラーが発生しました: $_"
    }
} else {
    Write-Warning "指定されたサーバー上のファイルが見つかりません。パスを確認してください。"
}

