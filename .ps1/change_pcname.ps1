# 管理者かどうかのチェック
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "このスクリプトは管理者権限が必要です。管理者として再起動します。"
    
    $scriptPath = $MyInvocation.MyCommand.Definition
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# 現在のコンピューター名の取得と表示
$currentName = $env:COMPUTERNAME
Write-Host "現在のコンピューター名は「$currentName」です。"

# 変更するか確認
$confirm = Read-Host "コンピューター名を変更しますか？（Y/n）"

if ($confirm -ne 'Y' -and $confirm -ne 'y' -and $confirm -ne '') {
    Write-Host "変更は行われませんでした。終了します。"
    exit
}

# 新しい名前の入力
$newName = Read-Host "新しいコンピューター名を入力してください"

# 入力が空かどうかチェック
if ([string]::IsNullOrWhiteSpace($newName)) {
    Write-Host "何も入力されなかったため、コンピューター名は変更されません。終了します。"
    exit
}

# 名前を変更する処理
try {
    Rename-Computer -NewName $newName -Force
    Write-Host "コンピューター名を「$newName」に変更しました。"
    
    # 再起動の確認
    $reboot = Read-Host "変更を反映するには再起動が必要です。今すぐ再起動しますか？（Y/n）"
    if ($reboot -eq 'Y' -or $reboot -eq 'y' -or $reboot -eq '') {
        Write-Host "再起動します..."
        Restart-Computer
    } else {
        Write-Host "再起動は後で行ってください。終了します。"
    }

} catch {
    Write-Host "コンピューター名の変更に失敗しました： $_"
}
