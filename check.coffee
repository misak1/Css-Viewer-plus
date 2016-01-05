# Check My Links by Paul Livingstone
# @ocodia

removeClassFromElements = (classname) ->
  x = document.getElementsByClassName(classname)
  i = undefined
  i = 0
  while i < x.length
    x[i].classList.remove classname
    i++
  return

removeElementsByClass = (className) ->
  elements = document.getElementsByClassName(className)
  while elements.length > 0
    elements[0].parentNode.removeChild elements[0]
  return

removeDOMElement = (id) ->
  if document.getElementById(id)
    document.getElementById(id).remove()
  return

String::startsWith = (text) ->
  @substr(0, text.length) == text

String::contains = (text) ->
  @indexOf(text) != -1

chrome.extension.onMessage.addListener (request, sender) ->
  # Gather links
  pageLinks = document.getElementsByTagName('a')
  totalvalid = pageLinks.length
  queued = 0
  checked = 0
  invalid = 0
  passed = 0
  rpBox = undefined
  # Clear the Previous Run
  removeDOMElement 'ALP_ReportBox'
  ((pg) ->
    blacklist = request.bl
    blacklisted = undefined
    cacheType = request.ca
    checkType = request.ct
    reportStyle = document.createElement('style')
    reportStyle.setAttribute 'rel', 'stylesheet'
    reportStyle.setAttribute 'type', 'text/css'
    document.getElementsByTagName('head')[0].appendChild reportStyle
    reportStyle.appendChild document.createTextNode('#ALP_ReportBox{font-weight: bold; width: 250px; position: fixed; right:0px; top: 0px; background: #fff; margin: 20px; padding: 0px; font-family: Arial, Helvetica, sans-serif; font-size: 14px; line-height: 14px; border-radius: 5px; z-index: 99999; box-shadow: 0px 0px 3px rgba(0,0,0,1);}')
    reportBox = document.createElement('div')
    rbHeader = document.createElement('div')
    rbClose = document.createElement('div')
    rbClose.innerHTML = '&times;'
    rbClose.setAttribute 'id', 'ALP_RB_Close'
    rbSettings = document.createElement('div')
    reportBox.setAttribute 'id', 'ALP_ReportBox'
    rbHeader.innerHTML = 'Link Results'
    document.getElementsByTagName('body')[0].appendChild reportBox
    rpBox = document.getElementById('ALP_ReportBox')
    #////////
    a = undefined
    e = undefined
    h = undefined
    i = undefined
    j = undefined
    r = undefined
    rcss = undefined
    rid = undefined
    tblcss = undefined
    tdlcss = undefined
    tdrcss = undefined
    rid = 'ALT_VIEWER_PLUS'

    e = (t) ->
      document.getElementsByTagName t

    a = (o, a) ->
      att = o.getAttribute(a)
      if a == 'alt' and att == null
        return 'alt未設定'
      att

    if document.getElementById(rid)
      return
    i = e('img')
    if i.length <= 0
      return
    r = document.createElement('div')
    rcss = 'padding:0px;position:fixed;top:0;right:0;border:solid #ccc 1px;z-index:999;max-height:100%;overflow: auto;'
    tblcss = ' style=\'border-collapse:collapse;background:hsla(0,0%,0%,.75);\''
    tdlcss = ' style=\'padding:0 .5em 0 0;border-bottom:solid #fff 2px;text-align:right;\''
    tdrcss = ' style=\'padding:0 0 0 1em;border-bottom:solid #fff 2px;text-align:left;background-color:hsla(0,0%,0%,.45);color:#F0EA30;width:250px;\''
    r.id = rid
    r.style.cssText = rcss
    h = '<style>\n@-webkit-keyframes anime1 {\n0% {opacity: .2;}\n100% {opacity: 1;}\n}\n.img_blink{-webkit-animation: anime1 0.5s ease 0s infinite alternate;}\n</style>'
    h += '<table' + tblcss + ' class="ATT_VIEWER_TABLE">'
    j = 0
    #/ meta
    h += '<tr><td colspan="2" style="padding:1em 0 0 1em;border-bottom:solid #fff 2px;text-align:left;color:#fff;white-space:pre-wrap;max-width:500px;line-height:1;font-size: 12px;">'
    h += '<span class="ALT_VIEWER_CLOSE" style="background-color: hsla(0,100%,100%,1);color: #000;position: absolute;right: 0;top: 0;padding: 0.5em 1em;">Close✕</span>'
    matas = ''
    Array::forEach.apply document.querySelectorAll('title, meta, h1'), [ (e, i, a) ->
      `var i`
      out = e.outerHTML.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#39;').replace(/</g, '&lt;').replace(/>/g, '&gt;') + '\n'
      inn = e.innerHTML
      out.replace inn, '<span style="color:#F0EA30;">' + inn + '</span>'
      attrs = e.attributes
      i = attrs.length - 1
      while i >= 0
        # h += attrs[i].name + "->" + attrs[i].value + '\n';
        out = out.replace(new RegExp(attrs[i].name, 'g'), '<span style="color:#70BE47;">' + attrs[i].name + '</span>').replace(new RegExp(attrs[i].value, 'g'), '<span style="color:#F55A21;">' + attrs[i].value + '</span>')
        i--
      matas += out + '\n'
      return
 ]
    meta_txt = matas
    h += meta_txt
    h += '</td></tr>'
    #/ meta
    while j < i.length
      h += if j % 252 == 0 then '<tr>' else '<tr>'
      h += '<td' + tdlcss + '><img style=\'max-width: 350px;vertical-align:bottom;\' src=' + a(i[j], 'src') + '></td><td' + tdrcss + '>' + a(i[j], 'alt') + '</td></tr>'
      j++
    #/// title
    titles = ''
    Array::forEach.apply document.querySelectorAll('[title]'), [ (e, i, a) ->
      `var i`
      out = e.outerHTML.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#39;').replace(/</g, '&lt;').replace(/>/g, '&gt;') + '\n'
      attrs = e.attributes
      i = attrs.length - 1
      while i >= 0
        if attrs[i].name == 'title'
          title = attrs[i].value
          newout = out.replace('title', '<span style="color:#70BE47;">title</span>').replace(title, '<span style="color:#F55A21;">' + title + '</span>')
          h += '<tr><td' + tdlcss + ' style=\'max-width: 350px;vertical-align:top;\'><span style=\'max-width: 350px;display: inline-block;line-height:1;font-size: 12px;color: #fff;text-align: left;padding:.5em 0 0 .5em;overflow: hidden;\'>' + newout + '</span></td>'
          h += '<td class="ALT_VIEWER_TITLE" style="padding:1em 0 1em 1em;border-bottom:solid #fff 2px;text-align:left;background-color:hsla(0,0%,0%,.45);color:#F55A21;width:250px;overflow: hidden;vertical-align: top;">' + title + '</td></tr>'
        i--
      titles += out + '\n'
      return
 ]
    # console.log(titles);
    #/// /title
    h += '</table>'
    e('body')[0].appendChild r
    r.innerHTML = h

    r.onclick = ->
      # this.parentNode.removeChild(this);
      return

    # 閉じる

    document.querySelector('.ALT_VIEWER_CLOSE').onclick = ->
      `var i`
      i = r.childNodes.length - 1
      while i >= 0
        r.removeChild r.childNodes[i]
        i--
      return

    window.scrollTo 0, 0
    # hoverした画像にボーダー
    Array::forEach.apply document.querySelectorAll('.ATT_VIEWER_TABLE img'), [ (e, i, a) ->
      e.addEventListener 'mouseover', ((event) ->
        # console.log("mouseover", event.target.src);
        filename_ex = event.target.src.match('.+/(.+?)([?#;].*)?$')[1]
        document.querySelector('[src$="' + filename_ex + '"]').style.border = 'solid 3px #F82F66'
        # document.querySelector('[src$="'+filename_ex+'"]').style.boxSizing ="border-box";
        document.querySelector('[src$="' + filename_ex + '"]').classList.add 'img_blink'
        return
      ), false
      return
 ]
    Array::forEach.apply document.querySelectorAll('.ATT_VIEWER_TABLE img'), [ (e, i, a) ->
      e.addEventListener 'mouseout', ((event) ->
        # console.log("mouseout", event.target.src);
        filename_ex = event.target.src.match('.+/(.+?)([?#;].*)?$')[1]
        document.querySelector('[src$="' + filename_ex + '"]').style.border = 'none'
        # document.querySelector('[src$="'+filename_ex+'"]').style.boxSizing ="content-box";
        document.querySelector('[src$="' + filename_ex + '"]').classList.remove 'img_blink'
        return
      ), false
      return
 ]
    # hoverした時のtitle
    Array::forEach.apply document.querySelectorAll('.ATT_VIEWER_TABLE .ALT_VIEWER_TITLE'), [ (e, i, a) ->
      e.addEventListener 'mouseover', ((event) ->
        # console.log("mouseover", event.target.src);
        title = event.target.innerText
        document.querySelector('[title$="' + title + '"]').style.border = 'solid 3px #F82F66'
        document.querySelector('[title$="' + title + '"]').classList.add 'img_blink'
        return
      ), false
      return
 ]
    Array::forEach.apply document.querySelectorAll('.ATT_VIEWER_TABLE .ALT_VIEWER_TITLE'), [ (e, i, a) ->
      e.addEventListener 'mouseout', ((event) ->
        # console.log("mouseout", event.target.title);
        title = event.target.innerText
        document.querySelector('[title$="' + title + '"]').style.border = 'none'
        document.querySelector('[title$="' + title + '"]').classList.remove 'img_blink'
        return
      ), false
      return
 ]
    #////////

    document.getElementById('ALP_RB_Close').onclick = ->
      removeDOMElement 'ALP_ReportBox'
      return

    # Remove the event listener in the event this is run again without reloading
    chrome.extension.onMessage.removeListener doStuff
    return
  ) pageLinks
  true
