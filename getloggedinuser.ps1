param(
[string]$computername,
[string]$listfile
)

#function for checking office version
function getuser ($computer){
	try{
		$computerinfo = Get-WmiObject -Class Win32_ComputerSystem  -ComputerName $computer -ErrorAction Stop
		
		
		$user = $computerinfo.username
		
		return $computer +", " + $user
	}catch{
		return $computer +", - no response"
	}
}
 
 
 #fail if a list and single computer specified
if ($computername -And $list) {
	write-host "you can only use one param at a time" -foregroundcolor "red"
	
#if single computer specified - get office version from that computer
}elseif ($computername) {
	getuser($computername)
	
#if text file list specified - loop through it to get versions	
} elseif($listfile) {
	$computers = Get-Content -Path $listfile
	
	foreach ($computer in $computers){
		getuser($computer)
		
	}
		
#improper param specified	
}Else {
	write-host "valid params are -Computername -List `n only use one at a time" -foregroundcolor "red"
}

