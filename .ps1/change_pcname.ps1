# �Ǘ��҂��ǂ����̃`�F�b�N
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "���̃X�N���v�g�͊Ǘ��Ҍ������K�v�ł��B�Ǘ��҂Ƃ��čċN�����܂��B"
    
    $scriptPath = $MyInvocation.MyCommand.Definition
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# ���݂̃R���s���[�^�[���̎擾�ƕ\��
$currentName = $env:COMPUTERNAME
Write-Host "���݂̃R���s���[�^�[���́u$currentName�v�ł��B"

# �ύX���邩�m�F
$confirm = Read-Host "�R���s���[�^�[����ύX���܂����H�iY/n�j"

if ($confirm -ne 'Y' -and $confirm -ne 'y' -and $confirm -ne '') {
    Write-Host "�ύX�͍s���܂���ł����B�I�����܂��B"
    exit
}

# �V�������O�̓���
$newName = Read-Host "�V�����R���s���[�^�[������͂��Ă�������"

# ���͂��󂩂ǂ����`�F�b�N
if ([string]::IsNullOrWhiteSpace($newName)) {
    Write-Host "�������͂���Ȃ��������߁A�R���s���[�^�[���͕ύX����܂���B�I�����܂��B"
    exit
}

# ���O��ύX���鏈��
try {
    Rename-Computer -NewName $newName -Force
    Write-Host "�R���s���[�^�[�����u$newName�v�ɕύX���܂����B"
    
    # �ċN���̊m�F
    $reboot = Read-Host "�ύX�𔽉f����ɂ͍ċN�����K�v�ł��B�������ċN�����܂����H�iY/n�j"
    if ($reboot -eq 'Y' -or $reboot -eq 'y' -or $reboot -eq '') {
        Write-Host "�ċN�����܂�..."
        Restart-Computer
    } else {
        Write-Host "�ċN���͌�ōs���Ă��������B�I�����܂��B"
    }

} catch {
    Write-Host "�R���s���[�^�[���̕ύX�Ɏ��s���܂����F $_"
}
