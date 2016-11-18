 
 Import-Module ActiveDirectory
 
 Get-ADComputer -Properties * -Filter {(enabled -eq $True)} | where OperatingSystem -NotLike "*Server*" | select Name | foreach {$_.Name} | Out-File computerlist.txt