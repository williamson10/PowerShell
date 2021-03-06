param(
[string]$computername,
[string]$listfile
)

#function for getting disk space
function getdiskinfo ($computer){
	try{
		$disk = Get-WmiObject Win32_LogicalDisk -ComputerName $computer -Filter "DeviceID='C:'" -EA SilentlyContinue 
		$free = [math]::Round($disk.FreeSpace / 1GB)
		return $computer +", " + $free + " GB FREE"
	}catch{
		return $computer +", - no response"
	}
}
 
 #fail if a list and single computer specified
if ($computername -And $list) {
	write-host "you can only use one param at a time" -foregroundcolor "red"
	
#if single computer specified - get disk space for computer
}elseif ($computername) {
	getdiskinfo($computername)
	
#if text file list specified - loop through it to get disk space on each computer	
} elseif($listfile) {
	$computers = Get-Content -Path $listfile
	foreach ($computer in $computers){
		getdiskinfo($computer)
	}
		
#improper param specified	
}Else {
	write-host "valid params are -Computername -List `n only use one at a time" -foregroundcolor "red"
}


