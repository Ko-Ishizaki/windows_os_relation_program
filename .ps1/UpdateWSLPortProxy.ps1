# 管理者で再起動（※普段はコメントアウトでOK）
<#
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
#>

# ログファイル設定（※普段はコメントアウトでOK）
# $logPath = "$env:USERPROFILE\wsl_portproxy_log.txt"
# "=== 実行開始: $(Get-Date) ===" | Out-File $logPath -Append

try {
    $listenPort = 2222
    $listenAddress = "127.0.0.1"
    $connectPort = 22

    # ==== WSL IP取得 ====
    $wslIp = wsl hostname -I | ForEach-Object { $_.Trim().Split(" ")[0] }
    # "取得したWSL IP: $wslIp" | Out-File $logPath -Append

    if (-not $wslIp) {
        # "エラー: WSL IPを取得できませんでした。" | Out-File $logPath -Append
        exit
    }

    netsh interface portproxy delete v4tov4 listenport=$listenPort listenaddress=$listenAddress | Out-Null
    # "既存ポートプロキシ削除" | Out-File $logPath -Append #（※普段はコメントアウトでOK）

    netsh interface portproxy add v4tov4 listenport=$listenPort listenaddress=$listenAddress connectport=$connectPort connectaddress=$wslIp | Out-Null
    # "新規ポートプロキシ追加: ${listenAddress}:${listenPort} -> ${wslIp}:${connectPort}" | Out-File $logPath -Append #（※普段はコメントアウトでOK）

    # ==== ポップアップ通知 ====
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show("WSL IPを $wslIp に更新しました。", "WSLポートフォワード更新", 'OK', 'Info')

} catch {
    # "エラー: $_" | Out-File $logPath -Append #（※普段はコメントアウトでOK）
}
