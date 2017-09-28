@echo off
echo dim WshShell,cmd >> %3runas.vbs
echo cmd="%SystemRoot%\system32\cmd.exe" >> %3runas.vbs
echo Set WshShell=WScript.CreateObject("WScript.Shell") >> %3runas.vbs
echo WshShell.Run cmd >> %3runas.vbs
echo WScript.Sleep 500 >> %3runas.vbs
echo WshShell.SendKeys"runas /user:Administrators\%1 %3Bcmd.bat" >> %3runas.vbs
echo WshShell.SendKeys"{ENTER}" >> %3runas.vbs
echo WScript.Sleep 1000 >> %3runas.vbs
echo WshShell.SendKeys"%2" >> %3runas.vbs
echo WshShell.SendKeys"{ENTER}" >> %3runas.vbs
echo WScript.Sleep 500 >> %3runas.vbs
echo WshShell.SendKeys"exit" >> %3runas.vbs
echo WshShell.SendKeys"{ENTER}" >> %3runas.vbs
echo @echo off >> %3Bcmd.bat
echo %4 %5 %6 %7 %8 %9 >> %3Bcmd.bat
echo del %3runas.vbs >> %3Bcmd.bat
echo del %3Bcmd.bat >> %3Bcmd.bat
%3\runas.vbs