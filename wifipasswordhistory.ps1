function get-wifipasswordhistory{
    $nopasswd= @()
    $yespasswd= @()
    Clear-Host

    $ssids= netsh wlan show profile * | select-string "SSID name" | findstr /r [a-z0-9]
    
    if (!$ssids){
        clear-host
        write-host "Nothing to show"
    
        pause
        break
    }

    $ssids= $ssids.split(":") | select-string -NotMatch "name" | findstr /r [a-z0-9]
    $ssids= $ssids | % {$_-replace '"',''}
    $ssids= $ssids.trimstart()

    foreach ($ssid in $ssids){
        $password= netsh wlan show profile $ssid key=clear | findstr "Key Content"
    
        if (!$password){
            $password= "No Password"
        }
        
        $password= $password.split(":") | select-string -NotMatch "Key Content" | select-string -NotMatch "Key Index" -ErrorAction SilentlyContinue | findstr /r [a-z0-9]
                    
        if ($password -eq " 1"){
            $password= "No Password"
        }
        $passwd= "$ssid -- $password" | findstr /r [a-z0-9]
        $yespasswd+= $passwd | select-string -NotMatch "No Password"
        $nopasswd+= $passwd | select-string "No Password"
    }

    $yespasswd
    $nopasswd
}
get-wifipasswordhistory
pause
