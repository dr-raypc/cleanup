# Author:	Raymond Mayer
# Updated:	11/8/2023	-	Added SERVER switch.

param(
    [switch]$server
  )
function cleanup {
	param(
    	[switch]$server
  	)
	if ($server) {
		#	Get System Uptime	
		$uptime = (get-date) - (gcim Win32_OperatingSystem).LastBootUpTime | Select-Object days,hours,minutes
		Write-Host "`nDevice Uptime:	" -NoNewLine
		Write-Host "$uptime`n" -ForegroundColor Green


		#	Get Windows Update download size and remove it	
		$winupdatefiles = "C:\Windows\SoftwareDistribution\Download"
		#	$winupdatesize = "{0:N2} GB" -f ((Get-ChildItem $winupdatefiles -Recurse -ErrorAction SilentlyContinue | where-object { -not $_.PSIsContainer } | measure Length -s).sum / 1Gb)
		$winupdatesize = "{0:N2} MB" -f ((Get-ChildItem $winupdatefiles -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)
		Remove-Item $winupdatefiles -Recurse -Force -ErrorAction SilentlyContinue
		Write-Host "[x] " -ForegroundColor Green -NoNewLine
		Write-Host "$winupdatesize Windows Update Files Removed.`n"


		#	Get Windows Temp size and remove it
		$wintempfiles = "C:\Windows\Temp\*"
		$wintempsize = "{0:N2} GB" -f ((Get-ChildItem $wintempfiles -Recurse -ErrorAction SilentlyContinue  | Measure-Object Length -s).sum / 1Gb)
		Remove-Item $wintempfiles -Recurse -Force -ErrorAction SilentlyContinue
		Write-Host "[x] " -ForegroundColor Green -NoNewLine
		Write-Host "$wintempsize Windows Temp Files Removed.`n"

		#	Clean Windows Component Store
		dism /online /cleanup-image /analyzecomponentstore
		dism /online /cleanup-image /startcomponentcleanup
		dism /online /cleanup-image /startcomponentcleanup /resetbase
		Write-Host "`n`n[x] " -ForegroundColor Green -NoNewLine
		Write-Host "Cleaned Windows Component Store`n"
		cleanmgr
		Write-Host "[x] " -ForegroundColor Green -NoNewLine
		Write-Host "Executed Final Disk Cleanup`n`n"
	}


#	Get System Uptime	
	$uptime = (get-date) - (gcim Win32_OperatingSystem).LastBootUpTime | Select-Object days,hours,minutes
	Write-Host "`nDevice Uptime:	" -NoNewLine
	Write-Host "$uptime`n" -ForegroundColor Green


#	Install Windows Update	
	Install-WindowsUpdate -AcceptAll -MicrosoftUpdate
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "Installed Windows Updates.`n"


#	Get Windows Update download size and remove it	
	$winupdatefiles = "C:\Windows\SoftwareDistribution\Download"
#	$winupdatesize = "{0:N2} GB" -f ((Get-ChildItem $winupdatefiles -Recurse -ErrorAction SilentlyContinue | where-object { -not $_.PSIsContainer } | measure Length -s).sum / 1Gb)
	$winupdatesize = "{0:N2} MB" -f ((Get-ChildItem $winupdatefiles -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)
	Remove-Item $winupdatefiles -Force -Recurse -ErrorAction SilentlyContinue
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "$winupdatesize Windows Update Files Removed.`n"
	

#	Get Windows Temp size and remove it
	$wintempfiles = "C:\Windows\Temp\*"
	$wintempsize = "{0:N2} GB" -f ((Get-ChildItem $wintempfiles -Recurse -ErrorAction SilentlyContinue  | Measure-Object Length -s).sum / 1Gb)
	Remove-Item $wintempfiles -Recurse -Force -ErrorAction SilentlyContinue
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "$wintempsize Windows Temp Files Removed.`n"


#	Get Windows dump file size and remove them
	$windmpfiles = Get-ChildItem c:\ *.dmp -Recurse -Force -ErrorAction SilentlyContinue
#	$windmpsize = "{0:N2} GB" -f ((Get-ChildItem $windmpfiles -Recurse -ErrorAction SilentlyContinue | measure Length -s).sum / 1Gb)
	$windmpsize = "{0:N2} GB" -f (($windmpfiles | Measure-Object Length -s).sum / 1Gb)
	Remove-Item $windmpfiles -Recurse -Force -ErrorAction SilentlyContinue
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "$windmpsize Windows Dump Files Removed.`n"


#	Get User temp file size and remove them	
	$usertmpfiles = Get-ChildItem -Path "$env:SystemDrive\Users\*\AppData\Local\Temp\*" -Recurse -Force
	$usertmpfilesize = "{0:N2} GB" -f ((Get-ChildItem $usertmpfiles -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -s).sum / 1Gb)
	Remove-Item $usertmpfiles -Recurse -Force -ErrorAction SilentlyContinue
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "$usertmpfilesize Temporary User Files Removed.`n"


#	Get User temp file size and remove them
	#$usertmpfiles = Get-ChildItem -Path 'C:\Users' -ErrorAction SilentlyContinue | foreach {
	#	Get-ChildItem -Path "$($_.FullName)\AppData\Local\Temp\*" -Recurse -ErrorAction SilentlyContinue
	#	Get-ChildItem -Path "$($_.FullName)\AppData\Local\Temporary Internet Files\*" -Recurse -ErrorAction SilentlyContinue
	#}
	#$usertmpfilesize = "{0:N2} GB" -f ((Get-ChildItem $usertmpfiles -Recurse -ErrorAction SilentlyContinue | measure Length -s).sum / 1Gb)
	#Remove-Item $usertmpfiles -Recurse -Force -ErrorAction SilentlyContinue
	#Write-Host "[x] " -ForegroundColor Green -NoNewLine
	#Write-Host "$usertmpfilesize Temporary User Files Removed.`n"


#	Optimize C drive and disable hibernation
	Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "Optimized SSD (ReTrim)`n"
	powercfg -h off
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "Disabled Hibernate Feature`n"


#	Clean Windows Component Store
	dism /online /cleanup-image /analyzecomponentstore
	dism /online /cleanup-image /startcomponentcleanup
	dism /online /cleanup-image /startcomponentcleanup /resetbase
	Write-Host "`n`n[x] " -ForegroundColor Green -NoNewLine
	Write-Host "Cleaned Windows Component Store`n"
	cleanmgr
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "Executed Final Disk Cleanup`n`n"
}