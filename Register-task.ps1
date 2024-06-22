$Trigger = New-ScheduledTaskTrigger -At 9:00am –Daily
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "$env:USERPROFILE\Desktop\ZeroTier_BD\ZT_BD.ps1"
Register-ScheduledTask -TaskName "ZT_BD" -Action $action -Trigger $trigger -Principal $principal