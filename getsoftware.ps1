param(
[string]$computername,
[string]$listfile,
[string]$softwarename
)

#function for checking office version
function getsoftware ($computer){
	try{
		$32bitsoftware = Invoke-Command -ComputerName $computer -ScriptBlock {Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ |Get-ItemProperty | Select-Object -Property Displayname, Publisher, UninstallString } 

		$64bitsoftware = Invoke-Command -ComputerName $computer -ScriptBlock {Get-ChildItem  -Path HKLM:\SOFTWARE\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\  | Get-ItemProperty | Select-Object -Property DisplayName, Publisher, UninstallString}

		$allsoftware = $32bitsoftware  + $64bitsoftware

		return $allsoftware | select-object -property Displayname, Publisher, uninstallstring | where-object {$_.displayname -like "*$softwarename*"}
		
	}catch{
		return $computer +", - no response"
	}
}
 
 
 #fail if a list and single computer specified
if ($computername -And $list) {
	write-host "you can only use one param at a time" -foregroundcolor "red"
	
#if single computer specified - get office version from that computer
}elseif ($computername) {
	getsoftware($computername)
	
#if text file list specified - loop through it to get versions	
} elseif($listfile) {
	$computers = Get-Content -Path $listfile
	
	foreach ($computer in $computers){
		getsoftware($computer)
		
	}
		
#improper param specified	
}Else {
	write-host "valid params are -Computername -List `n only use one at a time" -foregroundcolor "red"
}