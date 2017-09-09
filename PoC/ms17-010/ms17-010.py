import os
import fileinput
 
print "---This is Ms17010's tools for 139/445---"
#ip开始
BeginIP = raw_input(" [+] >输入开始ip:") #172.16.9.1
#ip终点
EndIP = raw_input(" [+] >输入终端ip:")
 
#Log file
fp = open('log.txt', 'w+')
#向Smbtouch-1.1.1.xml里面按照xml的格式文档写入默认127.0.0.1
OldIP = '      <value>127.0.0.1</value>'
TempIP = OldIP
print "------------------scaning----------------"
print ""
#切片操作
IP1 =  BeginIP.split('.')[0]
IP2 =  BeginIP.split('.')[1]
IP3 =  BeginIP.split('.')[2]
IP4 = BeginIP.split('.')[-1]
EndIP_last = EndIP.split('.')[-1]
 
for i in range(int(IP4)-1,int(EndIP_last)):
     ip = str(IP1+'.'+IP2+'.'+IP3+'.'+IP4)
     int_IP4 = int(IP4)
     int_IP4 += 1
     IP4 = str(int_IP4)
     NewIP= '      <value>'+ip+'</value>'
     for line in fileinput.input('Smbtouch-1.1.1.xml',inplace=1): 
        print line.rstrip().replace(TempIP,NewIP)
     TempIP = NewIP             
     Output = os.popen(r"Smbtouch-1.1.1.exe").read()
     Output = Output[0:Output.find('<config',1)]
     fp.writelines(Output)
     Flag = Output.find('[-] Touch failed')
     if Flag == -1 :
    print '[+] Touch success:   ' +ip
     else: 
    print '[-] Touch failed:    ' +ip
else:
     fp.close( )    
     for line in fileinput.input('Smbtouch-1.1.1.xml',inplace=1): 
        print line.rstrip().replace(NewIP,OldIP)