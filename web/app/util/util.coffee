App.Util = App.Util || {}

App.Util.snakeToCamel = (s) -> s.replace(/(\_\w)/g, (m) -> m[1].toUpperCase())

App.Util.padRight = (s, length, padChar = ' ') ->
  while s.length < length
    s = s + padChar
  s
