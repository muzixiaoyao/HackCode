#!/usr/bin/env python
#-*- conding:utf-8 -*-
import os
import sys
import cve_2017_12615
ip_port = open('iplsit.txt','a+')
for each_line in ip_port:
    cve_2017_12615.Is_cve2017_12615(each_line)