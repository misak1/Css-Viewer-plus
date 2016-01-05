logging = false

onRequest = (request, sender, callback) ->
  if request.action == 'check'
    if request.url
      if getItem('cache') == 'true'
        indexedDBHelper.getLink(request.url).then ((link) ->
          if typeof link != 'undefined' and 200 <= link.status and link.status < 400
            log 'found'
            log link
            return callback(link.status)
          else
            check request.url, callback
            log 'not in db'
            log request.url
            log 'added'
          return
        ), (err) ->
          log err
          return
      else
        # do not use cache
        check request.url, callback
  true

check = (url, callback) ->
  XMLHttpTimeout = null
  xhr = new XMLHttpRequest

  xhr.onreadystatechange = (data) ->
    if xhr.readyState == 4
      log xhr
      clearTimeout XMLHttpTimeout
      return callback(xhr.status)
    return

  try
    xhr.open getItem('checkType'), url, true
    xhr.send()
  catch e
    console.log e
  XMLHttpTimeout = setTimeout((->
    return callback(408)
    xhr.abort()
    return
  ), timeout += 1000)
  return

# OPTIONS: Management
# OPTIONS: Set items in localstore

setItem = (key, value) ->
  try
    log 'Inside setItem:' + key + ':' + value
    window.localStorage.removeItem key
    window.localStorage.setItem key, value
  catch e
    log 'Error inside setItem'
    log e
  log 'Return from setItem' + key + ':' + value
  return

# OPTIONS: Get items from localstore

getItem = (key) ->
  value = undefined
  log 'Get Item:' + key
  try
    value = window.localStorage.getItem(key)
  catch e
    log 'Error inside getItem() for key:' + key
    log e
    value = 'null'
  log 'Returning value: ' + value
  value

# OPTIONS: Zap all items in localstore

clearStrg = ->
  log 'about to clear local storage'
  window.localStorage.clear()
  log 'cleared'
  return

log = (txt) ->
  if logging
    console.log txt
  return

chrome.browserAction.onClicked.addListener (tab) ->
  chrome.tabs.executeScript tab.id, { file: 'check.js' }, ->
    blacklist = getItem('blacklist')
    nofollow = getItem('noFollow')
    checkType = getItem('checkType')
    cacheType = getItem('cache')
    optionsURL = chrome.extension.getURL('options.html')
    chrome.tabs.sendMessage tab.id,
      bl: blacklist
      ct: checkType
      ca: cacheType
      op: optionsURL
      nf: nofollow
    return
  return
# Timeout for each link is 60+1 seconds
timeout = 30000
