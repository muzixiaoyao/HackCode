'null session first
Set WshNetwork = WScript.CreateObject("WScript.Network")
WshNetwork.AddWindowsPrinterConnection "\\192.168.1.105\prt1"