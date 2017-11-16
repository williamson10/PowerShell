################ SETUP VARS
$dc = 'Your_DC_HOSTNAME_OR_IP'

################ Functions
function getcomputerinfo($computer){
	try{
		$computerinfo = Get-WmiObject -Class Win32_ComputerSystem  -ComputerName $computer -ErrorAction Stop
		return $computerinfo
	}catch{
		return $error[0]
	}
}

function getuptime($computer){
	try{
		$uptime =  Get-WmiObject -Class Win32_OperatingSystem  -ComputerName $computer -ErrorAction Stop
		return $uptime
	}catch{
		return $error[0]
	}
}

function getadcomputer($computer){
	try{
		$adcomputer = Invoke-Command -ComputerName $dc -argumentlist $computer -ScriptBlock {
			#param needed because otherwise $computer would be passed to the DC which cannot expand the variable
			param($computer)
			get-adcomputer -identity $computer
		}
		return $adcomputer
	}catch{
		return $error[0]
	}
}

function getsoftware($computer){
	try{
		$pwd = pwd
		# Start the remote registry service so we can enumerate software
		psexec.exe \\$computer net start 'remote registry'
		
		#Define the variable to hold the location of Currently Installed Programs
		  $UninstallKey='SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall'
		#Create an instance of the Registry Object and open the HKLM base key
		   $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computer)  
		#Drill down into the Uninstall key using the OpenSubKey Method
		  $regkey=$reg.OpenSubKey($UninstallKey)  
		#Retrieve an array of string that contain all the subkey names
		  $subkeys=$regkey.GetSubKeyNames()  
		
		#stop remote registry service
		psexec.exe \\$computer net stop 'remote registry'
		
		return $regkey
	}catch{
		return $error[0]
	}
}

################ Form Code
Add-Type -AssemblyName System.Windows.Forms

$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Computer Info"
$Form.TopMost = $false
$Form.Width = 300
$Form.Height = 400
$Form.Add_Load({
#add here code triggered by the event
})

$lbl_ComputerInfo = New-Object system.windows.Forms.Label
$lbl_ComputerInfo.Text = "Computer Info"
$lbl_ComputerInfo.AutoSize = $true
$lbl_ComputerInfo.Width = 25
$lbl_ComputerInfo.Height = 10
$lbl_ComputerInfo.location = new-object system.drawing.point(15,10)
$lbl_ComputerInfo.Font = "Microsoft Sans Serif,16"
$Form.controls.Add($lbl_ComputerInfo)

$lbl_Status = New-Object system.windows.Forms.Label
$lbl_Status.AutoSize = $true
$lbl_Status.Width = 30
$lbl_Status.Height = 10
$lbl_Status.location = new-object system.drawing.point(180,17)
$lbl_Status.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($lbl_Status)



$cbx_hostname = New-Object system.windows.Forms.ComboBox
$cbx_hostname.Text = "Enter Hostname or IP"
$cbx_hostname.Width = 160
$cbx_hostname.Height = 30
$cbx_hostname.location = new-object system.drawing.point(15,45)
$cbx_hostname.Font = "Microsoft Sans Serif,10"
$cbx_hostname.Items.Add("FPCWL12")
$cbx_hostname.Items.Add("C2DBYQ1")
$cbx_hostname.Add_SelectedValueChanged({
	
})
$Form.controls.Add($cbx_hostname)


$btn_go = New-Object system.windows.Forms.Button
$btn_go.Text = "GO!"
$btn_go.Width = 75
$btn_go.Height = 25
$btn_go.location = new-object system.drawing.point(180,45)
$btn_go.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($btn_go)
$btn_go.Add_click({

	$lbl_Status.Text = "working..."
		
	if (Test-Connection -Computername $cbx_hostname.Text -BufferSize 16 -Count 1 -Quiet){
		
		
		
		$results = getcomputerinfo($cbx_hostname.Text)
		$uptime = getuptime($cbx_hostname.Text)
		$adcomputer = getadcomputer($cbx_hostname.Text)
		
		$txt_loggedInuser.text = $results.username
		$txt_model.text = $results.model
		$txt_manufacturer.text = $results.manufacturer
		$txt_memory.text =  [math]::Round($results.totalphysicalmemory / 1073741824 )
		$txt_uptime.text = get-date $uptime.ConvertToDateTime($uptime.LastBootUpTime) -Format 'h:mm tt - MMMM d, yyyy '
		$txt_reformat.text = get-date $uptime.ConvertToDateTime($uptime.InstallDate) -Format 'MM/dd/yyyy'
		$txt_dname.text = $adcomputer
	
		$lbl_Status.Text = ""
	}else{
		
		$lbl_Status.Text = "No Response"
		
		$txt_loggedInuser.text = ""
		$txt_model.text = ""
		$txt_manufacturer.text = ""
		$txt_memory.text =  ""
		$txt_uptime.text = ""
		$txt_reformat.text = ""
		$txt_dname.text = ""
	}
})

#pressing enter invokes the go button
$Form.AcceptButton = $btn_go

$txt_dname = New-Object system.windows.Forms.TextBox
$txt_dname.Width = 240
$txt_dname.Height = 50
$txt_dname.ReadOnly = $true
$txt_dname.MultiLine = $true
$txt_dname.location = new-object system.drawing.point(15,290)
$txt_dname.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($txt_dname)


$txt_manufacturer = New-Object system.windows.Forms.TextBox
$txt_manufacturer.Width = 125
$txt_manufacturer.Height = 20
$txt_manufacturer.ReadOnly = $true
$txt_manufacturer.location = new-object system.drawing.point(130,80)
$txt_manufacturer.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($txt_manufacturer)

$label11 = New-Object system.windows.Forms.Label
$label11.Text = "Manufacturer"
$label11.AutoSize = $true
$label11.Width = 25
$label11.Height = 10
$label11.location = new-object system.drawing.point(15,80)
$label11.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($label11)



$label14 = New-Object system.windows.Forms.Label
$label14.Text = "Model"
$label14.AutoSize = $true
$label14.Width = 25
$label14.Height = 10
$label14.location = new-object system.drawing.point(15,110)
$label14.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($label14)

$txt_model = New-Object system.windows.Forms.TextBox
$txt_model.Width = 125
$txt_model.Height = 20
$txt_model.location = new-object system.drawing.point(130,110)
$txt_model.Font = "Microsoft Sans Serif,10"
$txt_model.ReadOnly = $true
$Form.controls.Add($txt_model)



$label16 = New-Object system.windows.Forms.Label
$label16.Text = "Logged In User"
$label16.AutoSize = $true
$label16.Width = 25
$label16.Height = 10
$label16.location = new-object system.drawing.point(15,140)
$label16.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($label16)

$txt_loggedInuser = New-Object system.windows.Forms.TextBox
$txt_loggedInuser.Width = 125
$txt_loggedInuser.Height = 20
$txt_loggedinuser.ReadOnly = $true
$txt_loggedInuser.location = new-object system.drawing.point(130,140)
$txt_loggedInuser.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($txt_loggedInuser)

$lbl_memory = New-Object system.windows.Forms.Label
$lbl_memory.Text = "Memory (GB)"
$lbl_memory.AutoSize = $true
$lbl_memory.Width = 25
$lbl_memory.Height = 10
$lbl_memory.location = new-object system.drawing.point(15,170)
$lbl_memory.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($lbl_memory)

$txt_memory = New-Object system.windows.Forms.TextBox
$txt_memory.Width = 125
$txt_memory.Height = 20
$txt_memory.ReadOnly = $true
$txt_memory.location = new-object system.drawing.point(130,170)
$txt_memory.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($txt_memory)

$lbl_uptime = New-Object system.windows.Forms.Label
$lbl_uptime.Text = "Last Boot Time"
$lbl_uptime.AutoSize = $true
$lbl_uptime.Width = 25
$lbl_uptime.Height = 10
$lbl_uptime.location = new-object system.drawing.point(15,200)
$lbl_uptime.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($lbl_uptime)

$txt_uptime = New-Object system.windows.Forms.TextBox
$txt_uptime.Width = 125
$txt_uptime.Height = 20
$txt_uptime.ReadOnly = $true
$txt_uptime.location = new-object system.drawing.point(130,200)
$txt_uptime.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($txt_uptime)

$lbl_reformat = New-Object system.windows.Forms.Label
$lbl_reformat.Text = "Win Install Date"
$lbl_reformat.AutoSize = $true
$lbl_reformat.Width = 25
$lbl_reformat.Height = 10
$lbl_reformat.location = new-object system.drawing.point(15,230)
$lbl_reformat.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($lbl_reformat)

$txt_reformat = New-Object system.windows.Forms.TextBox
$txt_reformat.Width = 125
$txt_reformat.Height = 20
$txt_reformat.ReadOnly = $true
$txt_reformat.location = new-object system.drawing.point(130,230)
$txt_reformat.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($txt_reformat)

#Buttons and actions
$btn_files = New-Object system.windows.Forms.Button
$btn_files.Text = "Files"
$btn_files.Width = 75
$btn_files.Height = 25
$btn_files.location = new-object system.drawing.point(15,260)
$btn_files.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($btn_files)
$btn_files.Add_click({
	$remotehost = [string]$cbx_hostname.Text
	$path = "\\$remotehost\c$\"
	ii $path
})


$btn_software = New-Object system.windows.Forms.Button
$btn_software.Text = "Software"
$btn_software.Width = 75
$btn_software.Height = 25
$btn_software.location = new-object system.drawing.point(100,260)
$btn_software.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($btn_software)
$btn_software.Add_click({
	$results = getsoftware($cbx_hostname.Text)
	$results #| out-gridview
})


$btn_cmd = New-Object system.windows.Forms.Button
$btn_cmd.Text = "CMD"
$btn_cmd.Width = 75
$btn_cmd.Height = 25
$btn_cmd.location = new-object system.drawing.point(185,260)
$btn_cmd.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($btn_cmd)
$btn_cmd.Add_click({
	$hostname = $cbx_hostname.Text
	$pwd = pwd
	Start-Process -filepath "cmd.exe" -ArgumentList "/k $pwd\psexec.exe \\$hostname cmd"
	
})




#do the form thing
[void]$Form.ShowDialog()
$Form.Dispose()