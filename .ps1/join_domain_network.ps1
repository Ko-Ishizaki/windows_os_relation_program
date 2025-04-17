$ComputerName = $env:COMPUTERNAME
Write-Host "現在のPC名: $ComputerName"

$ComputerInfo = Get-CimInstance -ClassName Win32_ComputerSystem
$DomainName = $ComputerInfo.Domain

if (-not [string]::IsNullOrEmpty($DomainName)) {
    Write-Host "このPCは既にドメイン '$DomainName' に参加しています。処理を終了します。"
    exit
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "ドメインに参加するには管理者権限が必要です。管理者として再起動します。"
    Start-Process -FilePath $PSCommand -Verb RunAs -ArgumentList $MyInvocation.Line
    exit
}

Write-Host "このPCはドメインに参加していません。"
$ConfirmJoin = Read-Host "ドメインに参加しますか？ (yes/no)"

if ($ConfirmJoin -ceq "yes" -or $ConfirmJoin -ceq "y") {
    $TargetDomainName = Read-Host "参加させるドメイン名を入力してください"
    $Credential = Get-Credential -Message "ドメインに参加させるユーザー名とパスワードを入力してください"

    try {
        Add-Computer -DomainName $TargetDomainName -Credential $Credential -Restart -ErrorAction Stop
        Write-Host "PCをドメイン '$TargetDomainName' に参加させました。再起動します。"
    }
    catch {
        Write-Error "ドメインへの参加に失敗しました: $($_.Exception.Message)"
        Write-Error "エラーの詳細: $_"
    }
} else {
    Write-Host "ドメインへの参加をキャンセルしました。"
}
