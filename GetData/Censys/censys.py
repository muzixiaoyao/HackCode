# -*- coding: UTF-8 -*-
# https://www.censys.io/api/v1/search/ipv4
# post:{"query": "keyword", "page": 1, "fields": ["ip", "protocols", "location.country"]}
# query指的是相应的搜索语句;page代表返回的页码;fields指的是你希望返回值中包含哪些字段
import sys
import json
import requests
import time

API_URL = "https://www.censys.io/api/v1"
UID = "d66fadf0-3035-44d2-aab4-453f77cb0a17"
SECRET = "n6jvwAg40F5p10luwSowxSjs9ZBvraPE"
page = 10
PAGES = 12


def getIp(page):
    iplist = []
    data = {
        "query": "keyword",
        "page": page,
        "fields": ["ip", "protocols", "location.country"]
    }
    try:
        res = requests.post(API_URL + "/search/ipv4", data=json.dumps(data), auth=(UID, SECRET))
    except:
        pass
    try:
        results = res.json()
    except:
        pass
    if res.status_code != 200:
        print "error occurred: %s" % results["error"]
        sys.exit(1)
    # print "Total_count:%s" % (results["metadata"]["count"])
    iplist.append("Total_count:%s" % (results["metadata"]["count"]))
    for result in results["results"]:
        # print "%s in %s" % (result["ip"],result["location.country"][0])
        # iplist.append((result["ip"]+':'+i+' in '+result["location.country"][0]))
        for i in result["protocols"]:
            iplist.append(result["ip"] + ':' + i + ' in ' + result["location.country"][0])
    return iplist


if __name__ == '__main__':
    print "start..."
    with open('censys.txt', 'a') as f:
        while page <= PAGES:
            iplist = (getIp(page))
            print 'page is：' + str(page)
            page += 1
            time.sleep(1)
            for i in iplist:
                f.write(i + '\n')
                print i