param(
[string]$computername,
[string]$listfile
)

#function for getting logged in user
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
	
#if single computer specified - get logged in user
}elseif ($computername) {
	getuser($computername)
	
#if text file list specified - loop through it to get logged in user for each computer
} elseif($listfile) {
	$computers = Get-Content -Path $listfile
	foreach ($computer in $computers){
		getuser($computer)
	}
		
#improper param specified	
}Else {
	write-host "valid params are -Computername -List `n only use one at a time" -foregroundcolor "red"
}

