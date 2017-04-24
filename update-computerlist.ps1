Get-ADComputer -Filter {(enabled -eq $True) -And (OperatingSystem -NotLike "*Server*")} | Select Name | Sort-Object Name | foreach {$_.Name} >> activecomputers.txt
