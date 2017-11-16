param(
[string]$computername,
[string]$listfile
)

#function for checking memory chips (needs to be able to support more than 2 chips. Should be able to count them?)
function getuser ($computer){
	try{
		$memoryinfo = Get-WmiObject -Class Win32_PHYSICALMEMORY  -ComputerName $computer -ErrorAction Stop
		$computerinfo = Get-WmiObject -Class Win32_ComputerSystem  -ComputerName $computer -ErrorAction Stop
		$count =  ($memoryinfo | measure).Count
		$user = $computerinfo.username
		
		if ($count -gt 1){
			$mem1cap = $memoryinfo[0].Capacity
			$mem2cap = $memoryinfo[1].Capacity
			
			return $computer+"," + $user +"," + $mem1cap +"," + $mem2cap + "," +  $count
		
		}elseif($count -eq 1) {
			$computer+"," + $user +"," + $memoryinfo.Capacity +",,"+  $count
		}
		
		
		
	}catch{
		return $computer +", - no response"
	}
}
 
 
 #fail if a list and single computer specified
if ($computername -And $list) {
	write-host "you can only use one param at a time" -foregroundcolor "red"
	
#if single computer specified - Get memory chips from computer 
}elseif ($computername) {
	getuser($computername)
	
#if text file list specified - loop through it to get memory chips	
} elseif($listfile) {
	$computers = Get-Content -Path $listfile
	
	foreach ($computer in $computers){
		getuser($computer)
		
	}
		
#improper param specified	
}Else {
	write-host "valid params are -Computername -List `n only use one at a time" -foregroundcolor "red"
}