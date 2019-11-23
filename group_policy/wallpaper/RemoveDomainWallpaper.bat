REM On my machine I could only set solid color after running this
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /f /v Wallpaper
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
pause