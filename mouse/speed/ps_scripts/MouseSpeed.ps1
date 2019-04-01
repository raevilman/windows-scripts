<#
	.SYNOPSIS
		Sets the mouse speed.

	.DESCRIPTION
		Sets the mouse speed via the SystemParametersInfo SPI_SETMOUSESPEED
        and stores the speed in the registry

	.PARAMETER  Speed
        Integer between 1 (slowest) and 20 (fastest). A value of 10 is the default.

	.EXAMPLE
        Sets the mouse speed to the defautl value.

		PS C:\> Set-MouseSpeed -Speed 10

	.INPUTS
		System.int

	.NOTES
		See Get-MouseSpeed also.

	.LINK
		about_functions_advanced

	.LINK
		about_comment_based_help

    .LINK
        https://msdn.microsoft.com/en-us/library/ms724947(v=VS.85).aspx

#>
function Set-MouseSpeed() {

    [cmdletbinding()]
    Param(
        [Parameter(ValueFromPipeline=$true)]
        [ValidateRange(1,20)] 
        [int]
        $Speed = 10
    )       

$MethodDefinition = @"
    [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint pvParam, uint fWinIni);
"@
    $User32 = Add-Type -MemberDefinition $MethodDefinition -Name "User32Set" -Namespace Win32Functions -PassThru
    $User32::SystemParametersInfo(0x0071,0,$Speed,0) | Out-Null
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name MouseSensitivity -Value $Speed
}

<#
	.SYNOPSIS
		Gets the mouse speed.

	.DESCRIPTION
		Gets the mouse speed via the SystemParametersInfo SPI_GETMOUSESPEED

	.EXAMPLE
        Gets the current mouse speed.

		PS C:\> Get-MouseSpeed

	.Outputs
		System.int

	.NOTES
		See Set-MouseSpeed also.

	.LINK
		about_functions_advanced

	.LINK
		about_comment_based_help

    .LINK
        https://msdn.microsoft.com/en-us/library/ms724947(v=VS.85).aspx

#>
function Get-MouseSpeed() {

$MethodDefinition = @"
    [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, ref uint pvParam, uint fWinIni);
"@
    $User32 = Add-Type -MemberDefinition $MethodDefinition -Name "User32Get" -Namespace Win32Functions -PassThru

    [Int32]$Speed = 0
    $User32::SystemParametersInfo(0x0070,0,[ref]$Speed,0) | Out-Null
    return $Speed
}