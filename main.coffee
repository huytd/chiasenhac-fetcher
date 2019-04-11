axios = require 'axios'
cheerio = require 'cheerio'

get = (url) ->
  resp = await axios.get url
  cheerio.load resp.data

open_album = (url) ->
  $ = await get url
  dowloadElements = $ '#playlist table tr td .gen a img[alt=Download]'
  dowloadElements
    .toArray()
    .map (e) -> ($ e).parent().attr 'href'

open_download = (url) ->
  $ = await get url
  links = ($ '#downloadlink2 b a').toArray()
  sizes = links.map (e) ->
    match = ($ e).text().match /(\d+\.\d+)\ MB/
    if match and match.length > 1
      parseFloat match[1]
    else
      0
  maxIdx = sizes.indexOf Math.max ...sizes
  ($ links[maxIdx]).attr 'href'
  
fetch_album = (album_url) ->
  songs = await open_album album_url
  urls = await Promise.all songs.map (e) -> open_download e
  urls.join("\n")

main = () ->
  [album_url, ...] = process.argv.filter (p) -> p.match /old\.chiasenhac\.vn/i
  result = await fetch_album album_url
  console.log result

main()
