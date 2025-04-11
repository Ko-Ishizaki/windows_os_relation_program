# 管理者権限チェック
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "このスクリプトは管理者権限が必要です。自動で再実行します..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Show-Spinner {
    param(
        [string]$Message = "処理中...",
        [int]$Duration = 10
    )
    $spinner = "/-\|"
    for ($i = 0; $i -lt ($Duration * 4); $i++) {
        $char = $spinner[$i % $spinner.Length]
        Write-Host -NoNewline "`r$Message $char"
        Start-Sleep -Milliseconds 250
    }
    Write-Host "`r$Message 完了。"
}

# モジュール確認
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "PSWindowsUpdate モジュールをインストールします..." -ForegroundColor Yellow
    Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
}
Import-Module PSWindowsUpdate

# スキャン開始
Write-Host "Windows Update のスキャンを開始します..." -ForegroundColor Cyan
Start-Job -ScriptBlock {
    Get-WindowsUpdate -MicrosoftUpdate -IgnoreUserInput -AcceptAll -ErrorAction SilentlyContinue
} -Name UpdateScan

Show-Spinner -Message "スキャン中..." -Duration 20

# スキャン結果取得
$job = Get-Job -Name UpdateScan
$updates = Receive-Job -Job $job
Remove-Job -Job $job

if ($updates.Count -gt 0) {
    Write-Host "アップデートが見つかりました：" -ForegroundColor Green
    foreach ($update in $updates) {
        Write-Host " - $($update.Title)"
    }

    Write-Host "ダウンロードを開始します..." -ForegroundColor Cyan
    $updates | Download-WindowsUpdate -AcceptAll -IgnoreReboot

    Write-Host "ダウンロード完了。" -ForegroundColor Green
} else {
    Write-Host "アップデートは見つかりませんでした。" -ForegroundColor Gray
}
