@if exist %systemroot%\system32\boot.dat goto OK
@goto OVER
:OK
@move %systemroot%\system32\boot.dat .\pass.txt
@echo 拷贝密码文件成功...
@pause
@exit
:OVER
@echo 没有密码文件...
@pause
@exit