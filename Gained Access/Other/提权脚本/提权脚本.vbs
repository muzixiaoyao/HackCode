dim WshShell,cmd
cmd="%SystemRoot%\system32\cmd.exe"
Set WshShell=WScript.CreateObject("WScript.Shell")
WshShell.Run cmd
WScript.Sleep 500
WshShell.SendKeys"runas /user:Administrators\”√ªß√˚ √‹¬Î √¸¡Ó"
WshShell.SendKeys"{ENTER}"
WScript.Sleep 1000
WshShell.SendKeys"%2"
WshShell.SendKeys"{ENTER}"
WScript.Sleep 500
WshShell.SendKeys"exit"
WshShell.SendKeys"{ENTER}"