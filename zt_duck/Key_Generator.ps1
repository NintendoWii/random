function Encrypt-String {
    param (
        [string]$plainText,
        [string]$keyBase64,
        [string]$ivBase64
    )
    
    $aes= [System.Security.Cryptography.Aes]::Create()
    $aes.Key= [Convert]::FromBase64String($keyBase64)
    $aes.IV= [Convert]::FromBase64String($ivBase64)
    
    $encryptor= $aes.CreateEncryptor($aes.Key, $aes.IV)
    $plainTextBytes= [System.Text.Encoding]::UTF8.GetBytes($plainText)
    
    $encryptedBytes= $encryptor.TransformFinalBlock($plainTextBytes, 0, $plainTextBytes.Length)
    return [Convert]::ToBase64String($encryptedBytes)
}

function Decrypt-String {
    param (
        [string]$cipherTextBase64,
        [string]$keyBase64,
        [string]$ivBase64
    )
    
    $aes= [System.Security.Cryptography.Aes]::Create()
    $aes.Key= [Convert]::FromBase64String($keyBase64)
    $aes.IV= [Convert]::FromBase64String($ivBase64)
    
    $decryptor= $aes.CreateDecryptor($aes.Key, $aes.IV)
    $cipherTextBytes= [Convert]::FromBase64String($cipherTextBase64)
    
    $decryptedBytes= $decryptor.TransformFinalBlock($cipherTextBytes, 0, $cipherTextBytes.Length)
    return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
}

# Generate a random key and IV for AES (must be done once and saved securely)
clear-host
$API= $(Read-Host -Prompt "Enter API Key").tostring()
clear-host
$ztnet= $(Read-Host -Prompt "Enter ZeroTier Network ID").tostring()
clear-host
$key= [byte[]](1..32) # 256-bit key
$iv= [byte[]](1..16)  # 128-bit IV
$keyBase64= [Convert]::ToBase64String($key)
$ivBase64= [Convert]::ToBase64String($iv)

# Encrypt the plain text
$ztnet= Encrypt-String -plainText $ztnet -keyBase64 $keyBase64 -ivBase64 $ivBase64
$API= Encrypt-String -plainText $API -keyBase64 $keyBase64 -ivBase64 $ivBase64


write-output "ZTNET | $ztnet" >.\1.txt
Write-Output "ID | $API" >>.\1.txt
Write-Output " " >>.\1.txt
write-output "***************************************************" >>.\1.txt
write-output "**      DO NOT LEAVE THIS IN THE FILE!           **" >>.\1.txt
write-output "**      COPY IT SOMEWHERE ELSE. SAVE IT          **" >>.\1.txt
write-output "**      See Below:                               **" >>.\1.txt
write-output " " >>.\1.txt
write-output "Keybase64: $keyBase64" >>.\1.txt
write-output "IVBase64: $ivBase64" >>.\1.txt
write-output "***************************************************" >>.\1.txt

Write-Output "File stored at $($(Get-ChildItem .\1.txt).fullname)"
Write-Output "Save the Key and IV somewhere else, remove it from the file and upload this to your github"
Write-Output "You'll need to add the key and iv to 'instructions.ps1'"
pause
notepad .\1.txt
