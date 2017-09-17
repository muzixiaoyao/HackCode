#coding=utf-8
import urllib


def getHtml(url):
    page = urllib.urlopen(url)
    html = page.read()
    return html
html = getHtml('https://github.com/search?p=5&q=shodan+api+key&type=Code&utf8=%E2%9C%93')
print html