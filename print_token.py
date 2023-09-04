#!/bin/python

import json
import time
import urllib.request

APIURL = 'http://127.0.0.1:6878/server/api?api_version=3&method=get_api_access_token'

def gettoken():
  value = json.loads(urllib.request.urlopen(APIURL).read())
  token = value['result']['token']
  title = ' API TOKEN '
  empty = ''

  print(empty)
  print("#%s#" % title.center(68, '='))
  print('#%s#' % empty.center(68, ' '))
  print('#%s#' % token.center(68, ' '))
  print('#%s#' % empty.center(68, ' '))
  print('#%s#' % empty.center(68, '='))
  print(empty)

def execute():
  retries = 0

  while retries < 10:
    try:
      gettoken()
      retries = 10
    except Exception as e:
      retries = retries + 1
      time.sleep(3)

execute()
