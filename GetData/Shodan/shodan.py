# -*- coding:utf-8 -*-
import shodan
api=shodan.shodan("v4YpsPUJ3wjDxEqywwu6aF5OZKWj8kik")
results=api.search('apache')
print results