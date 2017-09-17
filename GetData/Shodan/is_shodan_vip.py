import shodan
SHODAN_API_KEY = "rHRbstt6uayzsIaTe22AQmyLx12bGfx2"
api = shodan.Shodan(SHODAN_API_KEY)
try:
        results = api.search("apache", page=20, limit=None, offset=None, facets=None, minify=True)
        print "vip"
except shodan.APIError, e:
        print "穷逼"
        #print 'Error: %s' % e
#print 'Results found: %s' % results['total']
#for result in results['matches']:
#        print result['ip_str']
        

