function cleanup {
	$uptime = (get-date) - (gcim Win32_OperatingSystem).LastBootUpTime | select days,hours,minutes
	Write-Host "`nDevice Uptime:	" -NoNewLine
	Write-Host "$uptime`n" -ForegroundColor Green
	Install-WindowsUpdate -AcceptAll -MicrosoftUpdate
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "Installed Windows Updates.`n"	
	$winupdatefiles = "C:\Windows\SoftwareDistribution\Download\*"
	$winupdatesize = "{0:N2} GB" -f ((gci $winupdatefiles -Recurse -ErrorAction SilentlyContinue  | measure Length -s).sum / 1Gb)
	Remove-Item $winupdatefiles -Recurse -Force -ErrorAction SilentlyContinue
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "$winupdatesize Windows Update Files Removed.`n"
	$wintempfiles = "C:\Windows\Temp\*"
	$wintempsize = "{0:N2} GB" -f ((gci $wintempfiles -Recurse -ErrorAction SilentlyContinue  | measure Length -s).sum / 1Gb)
	Remove-Item $wintempfiles -Recurse -Force -ErrorAction SilentlyContinue
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "$wintempsize Windows Temp Files Removed.`n"
	$windmpfiles = gci c:\ *.dmp -Recurse -Force -ErrorAction SilentlyContinue
#	$windmpsize = "{0:N2} GB" -f ((gci $windmpfiles -Recurse -ErrorAction SilentlyContinue | measure Length -s).sum / 1Gb)
	$windmpsize = "{0:N2} GB" -f (($windmpfiles | measure Length -s).sum / 1Gb)
	Remove-Item $windmpfiles -Recurse -Force -ErrorAction SilentlyContinue
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "$windmpsize Windows Dump Files Removed.`n"
	#$usertmpfiles = Get-ChildItem -Path 'C:\Users' -ErrorAction SilentlyContinue | foreach {
	#	Get-ChildItem -Path "$($_.FullName)\AppData\Local\Temp\*" -Recurse -ErrorAction SilentlyContinue
	#	Get-ChildItem -Path "$($_.FullName)\AppData\Local\Temporary Internet Files\*" -Recurse -ErrorAction SilentlyContinue
	#}
	#$usertmpfilesize = "{0:N2} GB" -f ((gci $usertmpfiles -Recurse -ErrorAction SilentlyContinue | measure Length -s).sum / 1Gb)
	#Remove-Item $usertmpfiles -Recurse -Force -ErrorAction SilentlyContinue
	#Write-Host "[x] " -ForegroundColor Green -NoNewLine
	#Write-Host "$usertmpfilesize Temporary User Files Removed.`n"
	Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "Optimized SSD (ReTrim)`n"
	powercfg -h off
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "Disabled Hibernate Feature`n"
	dism /online /cleanup-image /analyzecomponentstore
	dism /online /cleanup-image /startcomponentcleanup
	dism /online /cleanup-image /startcomponentcleanup /resetbase
	Write-Host "`n`n[x] " -ForegroundColor Green -NoNewLine
	Write-Host "Cleaned Windows Component Store`n"
	cleanmgr
	Write-Host "[x] " -ForegroundColor Green -NoNewLine
	Write-Host "Executed Final Disk Cleanup`n`n"
}