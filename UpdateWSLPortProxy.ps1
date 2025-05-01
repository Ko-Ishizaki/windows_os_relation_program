# （管理者昇格チェックはコメントアウト）
<#
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
#>

$listenPort = 2222
$listenAddress = "127.0.0.1"
$connectPort = 22

$wslIp = wsl hostname -I | ForEach-Object { $_.Trim().Split(" ")[0] }

if (-not $wslIp) {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show("WSL IPの取得に失敗しました。WSLが起動していますか？", "WSL接続エラー", 'OK', 'Error')
    exit
}

netsh interface portproxy delete v4tov4 listenport=$listenPort listenaddress=$listenAddress | Out-Null
netsh interface portproxy add v4tov4 listenport=$listenPort listenaddress=$listenAddress connectport=$connectPort connectaddress=$wslIp | Out-Null

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show("WSL IPを $wslIp に更新しました。", "WSLポートフォワード更新", 'OK', 'Info')
