# 日本人プログラマーで、日本人の環境で働く場合は絶対実行しておいたほうがいいPowerShellスクリプト

$currentLocale = Get-WinSystemLocale
$currentLocaleName = $currentLocale.Name

$utf8Setting = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "ACP"
$useUtf8 = ($utf8Setting.ACP -eq "65001") # 65001 = UTF-8

$localeIsJapanese = ($currentLocaleName -eq "ja-JP")
$utf8IsOff = (-not $useUtf8)

Write-Host "現在のシステムロケール: $currentLocaleName"
Write-Host "ワールドワイド言語サポート（UTF-8）: $($useUtf8 -replace $true, 'ON' -replace $false, 'OFF')"
Write-Host ""

if ($localeIsJapanese -and $utf8IsOff) {
    Write-Host "✅ 現在の設定は条件を満たしています。"
    Read-Host "`n何かキーを押すと終了します..."
    exit
} else {
    Write-Host "⚠️ 現在の設定は次の条件を満たしていません："
    if (-not $localeIsJapanese) {
        Write-Host "- システムロケールが 'ja-JP' ではありません（現在: $currentLocaleName）"
    }
    if (-not $utf8IsOff) {
        Write-Host "- UTF-8 設定が ON になっています"
    }

    $answer = Read-Host "設定を変更しますか？ (Y/n)"
    if ($answer -eq '' -or $answer -match '^[Yy]$') {
        Write-Host "`n設定を変更中..."

        Set-WinSystemLocale -SystemLocale "ja-JP"

        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "ACP" -Value "932"

        Write-Host "✅ 設定を変更しました。再起動が必要です。"
    } else {
        Write-Host "❌ 設定は変更されませんでした。"
    }

    Read-Host "`n何かキーを押すと終了します..."
}
