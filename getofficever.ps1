param(
[string]$computername,
[string]$listfile
)

#function for checking office version
function getofficever ($computer){
	try{
		$regsearch = Invoke-Command -ComputerName $computer -ScriptBlock {reg query "HKEY_CLASSES_ROOT\Outlook.Application\CurVer"} -ErrorAction stop 
		$regkey =  $regsearch[2].Substring(47,2)
		$version = switch ($regkey) {
			default {"Could not get version info"}
			16 {"Office 2016"}
			15 {"Office 2013"}
			14 {"Office 2010"}
			12 {"Office 2007"}
		}
		return $computer +", " + $version
	}catch{
		return $computer +", - no response"
	}
}
 
 #fail if a list and single computer specified
if ($computername -And $list) {
	write-host "you can only use one param at a time" -foregroundcolor "red"
	
#if single computer specified - get office version from that computer
}elseif ($computername) {
	getofficever($computername)
	
#if text file list specified - loop through it to get version on each computer	
} elseif($listfile) {
	$computers = Get-Content -Path $listfile
	foreach ($computer in $computers){
		getofficever($computer)
	}
		
#improper param specified	
}Else {
	write-host "valid params are -Computername -List `n only use one at a time" -foregroundcolor "red"
}


