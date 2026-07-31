App.Editor = App.Editor || {}

# Editor themes, keyed by the value stored in settings. Each entry names the
# chrome variant it sits in — the surrounding navbar, toolbar, output pane and
# modals only have a light and a dark form — and supplies the CodeMirror
# extension, so a new theme is a single entry here plus one line in
# templates/main/settings.hbs, with no stylesheet changes.
#
# `extension` is a function because window.CM6 is populated by the module shim
# in index.gsp and must not be dereferenced while this file is being evaluated.
#
# No CodeMirror 6 theme is published as a webjar beyond @codemirror/theme-one-dark,
# so everything except one-dark is defined here.

# https://ethanschoonover.com/solarized/ — one palette, two themes: the accents
# are shared and only the base tones swap, which is the whole point of it.
SOLARIZED =
  base03: '#002b36', base02: '#073642', base01: '#586e75', base00: '#657b83'
  base0:  '#839496', base1:  '#93a1a1', base2:  '#eee8d5', base3:  '#fdf6e3'
  yellow: '#b58900', orange: '#cb4b16', red:    '#dc322f', magenta: '#d33682'
  violet: '#6c71c4', blue:   '#268bd2', cyan:   '#2aa198', green:   '#859900'

# https://draculatheme.com/contribute — official palette
DRACULA =
  background: '#282a36', currentLine: '#44475a', foreground: '#f8f8f2'
  comment:    '#6272a4', cyan: '#8be9fd', green: '#50fa7b', orange: '#ffb86c'
  pink:       '#ff79c6', purple: '#bd93f9', red: '#ff5555', yellow: '#f1fa8c'

# Builds the EditorView.theme half from a small set of surface colours, so every
# theme below only has to say what its surfaces are.
buildTheme = (c, dark) ->
  window.CM6.EditorView.theme
    '&': {color: c.fg, backgroundColor: c.bg}
    '.cm-content': {caretColor: c.caret}
    '.cm-cursor, .cm-dropCursor': {borderLeftColor: c.caret}
    '&.cm-focused .cm-selectionBackgroundInactive, .cm-selectionBackground, ::selection':
      {backgroundColor: c.selection}
    '.cm-activeLine': {backgroundColor: c.activeLine}
    '.cm-gutters': {backgroundColor: c.gutterBg, color: c.gutterFg, border: 'none'}
    '.cm-activeLineGutter': {backgroundColor: c.gutterBg, color: c.fg}
    '.cm-matchingBracket, .cm-nonmatchingBracket':
      {backgroundColor: c.selection, outline: "1px solid #{c.gutterFg}"}
  , dark: dark

# The tag-to-colour mapping is identical in shape for every theme; only the
# colours differ, so it is written once.
buildHighlight = (c) ->
  {HighlightStyle, tags} = window.CM6
  HighlightStyle.define [
    {tag: tags.keyword,                                       color: c.keyword}
    {tag: [tags.name, tags.deleted, tags.character, tags.propertyName, tags.macroName],
                                                              color: c.fg}
    {tag: [tags.function(tags.variableName), tags.labelName], color: c.function}
    {tag: [tags.color, tags.constant(tags.name), tags.standard(tags.name)],
                                                              color: c.constant}
    {tag: [tags.definition(tags.name), tags.separator],       color: c.definition}
    {tag: [tags.typeName, tags.className, tags.number, tags.changed,
           tags.annotation, tags.modifier, tags.self, tags.namespace],
                                                              color: c.type}
    {tag: [tags.operator, tags.operatorKeyword, tags.url, tags.escape,
           tags.regexp, tags.link, tags.special(tags.string)], color: c.operator}
    {tag: [tags.meta, tags.comment],       color: c.comment, fontStyle: 'italic'}
    {tag: tags.strong,                     fontWeight: 'bold'}
    {tag: tags.emphasis,                   fontStyle: 'italic'}
    {tag: tags.strikethrough,              textDecoration: 'line-through'}
    {tag: tags.link,                       textDecoration: 'underline'}
    {tag: tags.heading,                    fontWeight: 'bold', color: c.heading}
    {tag: [tags.atom, tags.bool, tags.special(tags.variableName)], color: c.atom}
    {tag: [tags.processingInstruction, tags.string, tags.inserted], color: c.string}
    {tag: tags.invalid,                    color: c.invalid}
  ]

build = (colours, dark) -> ->
  [buildTheme(colours, dark), window.CM6.syntaxHighlighting(buildHighlight colours)]

solarized = (dark) ->
  s = SOLARIZED
  surfaces =
    if dark
      {bg: s.base03, fg: s.base0,  caret: s.base1,  selection: s.base02
       activeLine: '#07364280', gutterBg: s.base02, gutterFg: s.base01
       comment: s.base01, definition: s.base1}
    else
      {bg: s.base3,  fg: s.base00, caret: s.base01, selection: s.base2
       activeLine: '#eee8d580', gutterBg: s.base2,  gutterFg: s.base1
       comment: s.base1,  definition: s.base01}
  build $.extend({}, surfaces,
    keyword: s.green, function: s.blue, constant: s.yellow, type: s.violet
    operator: s.cyan, heading: s.orange, atom: s.magenta, string: s.cyan
    invalid: s.red), dark

dracula = ->
  d = DRACULA
  build
    bg: d.background, fg: d.foreground, caret: d.foreground
    selection: d.currentLine, activeLine: '#44475a70'
    gutterBg: d.background, gutterFg: d.comment
    comment: d.comment, definition: d.green
    keyword: d.pink, function: d.green, constant: d.purple, type: d.cyan
    operator: d.pink, heading: d.purple, atom: d.purple, string: d.yellow
    invalid: d.red
  , true

App.Editor.themes =
  'default':
    chrome: 'light'
    extension: -> []
  'solarized-light':
    chrome: 'light'
    extension: -> solarized(false)()
  'one-dark':
    chrome: 'dark'
    extension: -> window.CM6.oneDark
  'solarized-dark':
    chrome: 'dark'
    extension: -> solarized(true)()
  'dracula':
    chrome: 'dark'
    extension: -> dracula()()

App.Editor.themeFor = (name) ->
  App.Editor.themes[name] ? App.Editor.themes['default']

App.Editor.chromeFor = (name) ->
  App.Editor.themeFor(name).chrome
