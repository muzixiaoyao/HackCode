
介绍：

可以本linux操作系统本地提权

部分代码：

#!/bin/sh
# Linux 2.6
# bug found by Sebastian Krahmer
#
# lame sploit using LD technique
# by kcope in 2009
# tested on debian-etch,ubuntu,gentoo
# do a 'cat /proc/net/netlink'
# and set the first arg to this
# script to the pid of the netlink socket
# (the pid is udevd_pid - 1 most of the time)
# + sploit has to be UNIX formatted text :)
# + if it doesn't work the 1st time try more often


