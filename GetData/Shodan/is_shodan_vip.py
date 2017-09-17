import shodan
SHODAN_API_KEY = "11111111111111111111111111111111"
api = shodan.Shodan(SHODAN_API_KEY)
try:
        results = api.search("apache", page=20, limit=None, offset=None, facets=None, minify=True)
        print "vip"
except shodan.APIError, e:
        print "穷逼"

