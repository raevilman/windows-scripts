<#
	.SYNOPSIS
		Sets mouse parameters.

	.DESCRIPTION
		Sets the mouse speed via the SystemParametersInfo
		and stores the speed in the registry

	.PARAMETER  Speed
		Integer between 1 (slowest) and 20 (fastest).

	.PARAMETER  ScrollLines
		Integer between -1 (slowest) and 100.

	.EXAMPLE
		Sets the mouse speed to the value 10.

		PS C:\> Set-Mouse -Speed 10

	.EXAMPLE
		Sets the mouse WheelScrollLines to the value 5.

		PS C:\> Set-Mouse -ScrollLines 5

		.INPUTS
		System.int

	.NOTES
		See Get-Mouse also.

	.LINK
		about_functions_advanced

	.LINK
		about_comment_based_help

	.LINK
		https://msdn.microsoft.com/en-us/library/ms724947(v=VS.85).aspx
				
	.LINK
		https://github.com/raevilman/windows-scripts/edit/master/mouse/speed/ps_scripts/MouseSpeed.ps1

#>
function Set-Mouse() {

	[cmdletbinding()]
	Param(
		[ValidateRange(1, 20)] 
		[int]
		$Speed,
		[ValidateRange(-1, 100)] 
		[int]
		$ScrollLines
	)       

	$MethodDefinition = @"
		[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
		public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint pvParam, uint fWinIni);
"@
	$User32 = Add-Type -MemberDefinition $MethodDefinition -Name "User32Set" -Namespace Win32Functions -PassThru
	if ($Speed) {
		Write-Verbose "new mouse speed: $Speed"
		$User32::SystemParametersInfo(0x0071, 0, $Speed, 0) | Out-Null
		Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name MouseSensitivity -Value $Speed
	}
	if ($ScrollLines) {
		Write-Verbose "new mouse scrollLines: $ScrollLines"
		$User32::SystemParametersInfo(0x0069, $ScrollLines, 0, 0x01) | Out-Null
		Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name WheelScrollLines -Value $ScrollLines
	}
}

<#
	.SYNOPSIS
		Gets the mouse settings.

	.DESCRIPTION
		Gets the mouse settings via the SystemParametersInfo

	.EXAMPLE
		Gets the current mouse

		PS C:\> Get-Mouse

	.Outputs
		System.int

	.NOTES
		See Set-Mouse also.

	.LINK
		about_functions_advanced

	.LINK
		about_comment_based_help

	.LINK
		https://msdn.microsoft.com/en-us/library/ms724947(v=VS.85).aspx

	.LINK
		https://github.com/raevilman/windows-scripts/edit/master/mouse/speed/ps_scripts/MouseSpeed.ps1

#>
function Get-Mouse {
	[cmdletbinding()]
	param()

	$MethodDefinition = @"
		[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
		public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, ref uint pvParam, uint fWinIni);
"@
	$User32 = Add-Type -MemberDefinition $MethodDefinition -Name "User32Get" -Namespace Win32Functions -PassThru

	[Int32]$Speed = 0
	$User32::SystemParametersInfo(0x0070, 0, [ref]$Speed, 0) | Out-Null
	[Int32]$ScrollLines = 0
	$User32::SystemParametersInfo(0x0068, 0, [ref]$ScrollLines, 0) | Out-Null
	return [pscustomobject]@{
		"speed"       = $Speed;
		"scrollLines" = $ScrollLines
	}
}
