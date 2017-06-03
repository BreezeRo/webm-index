# site.coffee - client side Javascript
# (c) 2016 nilsding
# Licensed under the terms of the FreeBSD license.  See the LICENSE file in
# the repository's root for the full license text.

data = []
videoplayer = null
currentWebM = null
content = null
infoContent = null
indexContent = null
indexOpened = false

```
function getStack() {
    try {
        throw new Error();
    } catch(e) {
        return e.stack;
    }
}
```

loadData = (callback) ->
  xhr = new XMLHttpRequest()
  xhr.open 'GET', '/js/data.js'
  xhr.onreadystatechange = ->
    return if xhr.readyState != 4 || xhr.status != 200
    data = JSON.parse xhr.responseText
    callback()
  xhr.send()

getPlayCounts = () ->
  window.localStorage.playCounts = "{}" unless window.localStorage.playCounts?
  JSON.parse(window.localStorage.playCounts)

setPlayCounts = (obj) ->
  window.localStorage.playCounts = JSON.stringify(obj)

increasePlayCountFor = (webmName) ->
  playCounts = getPlayCounts()
  playCounts[webmName] = 0 unless playCounts[webmName]?
  playCounts[webmName] += 1
  console.log("increasing play count for #{webmName} from #{playCounts[webmName] - 1} to #{playCounts[webmName]}")
  console.log getStack()
  setPlayCounts(playCounts)

initPlayCountsFor = (webmNames) ->
  playCounts = getPlayCounts()
  for webmName in webmNames
    playCounts[webmName] = 0 unless playCounts[webmName]?
  setPlayCounts(playCounts)

playWebM = (webm) ->
  currentWebM = webm
  document.getElementById('title').innerHTML = webm.file_name.replace(/\.webm$/, '')
  document.getElementById('songWrapper').style.display = "none"
  document.getElementById('description').innerHTML = "<i>This video does not have a description.</i>"
  document.getElementById('permalink').href = data.basedir + '/' + webm.file_name
  document.getElementById('uploader').innerHTML = webm.uploaded_by || 'unknown'

  window.location.hash = encodeURIComponent webm.file_name.replace(/\.webm$/, '')
  videoplayer.src = data.basedir + '/' + webm.file_name
  videoplayer.controls = true
  videoplayer.play()
  increasePlayCountFor(webm.file_name)

  if webm.data?
    if webm.data.title?
      document.getElementById('title').innerHTML = webm.data.title
    if webm.data.song?
      document.getElementById('songWrapper').style.display = null
      document.getElementById('song').innerHTML = webm.data.song
    if webm.data.description?
      document.getElementById('description').innerHTML = webm.data.description

playWebMByFileName = (fileName, event = null) ->
  event.preventDefault() if event?
  webm = (video for video in data.videos when video.file_name is decodeURIComponent(fileName))
  if webm.length == 0
    console.log "WebM not found: #{fileName}"
    return playRandomWebM()
  playWebM webm[0]
window.playWebMByFileName = playWebMByFileName

playRandomWebM = ->
  getRandomFileNameWithHash = -> "#" + encodeURIComponent(data.videos[Math.floor(Math.random() * data.videos.length)].file_name.replace(/\.webm$/, '').trim())
  newhash = getRandomFileNameWithHash()
  newhash = getRandomFileNameWithHash() while window.location.hash == newhash
  console.log "#{window.location.hash} = #{newhash}"
  window.location.hash = newhash

toggleIndex = ->
  if indexOpened
    #content.style.left = "0%"
    infoContent.style.left = "0%"
    indexContent.style.left = "-15%"
  else
    #content.style.left = "15%"
    infoContent.style.left = "15%"
    indexContent.style.left = "0%"
  indexOpened = !indexOpened

hashChange = ->
  hash = window.location.hash.replace(/^#|\.webm$/, '').trim()
  if hash.length > 0
    playWebMByFileName(hash + ".webm")

load = ->
  videoplayer = document.getElementById('videoplayer')
  content = document.getElementsByClassName('wrapper')[0]
  infoContent = document.getElementsByClassName('info-wrapper')[0]
  indexContent = document.getElementsByClassName('index')[0]
  content.style.left = "0%"
  infoContent.style.left = "0%"
  indexContent.style.left = "-15%"
  document.getElementById('randomWebM').addEventListener 'click', (ev) ->
    ev.preventDefault()
    playRandomWebM()
  document.getElementById('indexLink').addEventListener 'click', (ev) ->
    ev.preventDefault()
    toggleIndex()
  document.getElementById('permalink').addEventListener 'click', (ev) ->
    videoplayer?.pause()
  videoplayer.addEventListener 'ended', (ev) ->
    if document.getElementById('autoplay').checked
      playRandomWebM()
    else
      videoplayer.play()

  loadData ->
    initPlayCountsFor(data.videos.map((webm) -> webm.file_name))
    document.getElementById('indexList').innerHTML = data.index
    hash = window.location.hash.replace(/^#|\.webm$/, '').trim()
    if hash.length > 0
      return playWebMByFileName(hash + ".webm")
    else
      playRandomWebM()

window.addEventListener "hashchange", hashChange, false
document.addEventListener "DOMContentLoaded", load, false
