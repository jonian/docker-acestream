#!/bin/python

import re
import time
import urllib

APIURL = 'http://localhost:6878/server/api?method=get_api_access_token'

def gettoken():
  value = urllib.urlopen(APIURL).read()
  match = re.search(r'[0-9a-f]{62}', value)
  match = match.group(0) if match else None
  title = ' API TOKEN '
  empty = ''

  print(empty)
  print("#%s#" % title.center(68, '='))
  print('#%s#' % empty.center(68, ' '))
  print('#%s#' % match.center(68, ' '))
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
