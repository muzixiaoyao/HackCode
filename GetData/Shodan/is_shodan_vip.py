# -*- coding: UTF-8 -*- 
import shodan
import sys
def is_vip(key="123123123"):
        SHODAN_API_KEY = key
        api = shodan.Shodan(SHODAN_API_KEY)
        try:
                results = api.search("apache", page=20, limit=None, offset=None, facets=None, minify=True)
                return True
        except shodan.APIError, e:
                return False

if __name__ == '__main__':
        KEY = sys.argv[1]
        if is_vip(KEY):
                print "土豪"
        else:
                print "屌丝"