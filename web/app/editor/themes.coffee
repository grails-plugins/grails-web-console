App.Editor = App.Editor || {}

# Editor themes, keyed by the value stored in settings. Each entry names the
# chrome variant it sits in — the surrounding navbar, toolbar, output pane and
# modals only have a light and a dark form — and supplies the CodeMirror
# extension, so a new theme is a single entry here plus one line in
# templates/main/settings.hbs, with no stylesheet changes.
#
# `extension` is a function because window.CM6 is populated by the module shim
# in index.gsp and must not be dereferenced while this file is being evaluated.

# https://ethanschoonover.com/solarized/ — no CodeMirror 6 port of this is
# published as a webjar, so it is defined here rather than pulled in.
SOLARIZED =
  base03: '#002b36', base01: '#586e75', base00: '#657b83', base0: '#839496'
  base1:  '#93a1a1', base2:  '#eee8d5', base3:  '#fdf6e3'
  yellow: '#b58900', orange: '#cb4b16', red:    '#dc322f', magenta: '#d33682'
  violet: '#6c71c4', blue:   '#268bd2', cyan:   '#2aa198', green:   '#859900'

solarizedLight = ->
  {EditorView, HighlightStyle, syntaxHighlighting, tags} = window.CM6

  theme = EditorView.theme
    '&': {color: SOLARIZED.base00, backgroundColor: SOLARIZED.base3}
    '.cm-content': {caretColor: SOLARIZED.base01}
    '.cm-cursor, .cm-dropCursor': {borderLeftColor: SOLARIZED.base01}
    '&.cm-focused .cm-selectionBackgroundInactive, .cm-selectionBackground, ::selection':
      {backgroundColor: SOLARIZED.base2}
    '.cm-activeLine': {backgroundColor: '#eee8d580'}
    '.cm-gutters':
      {backgroundColor: SOLARIZED.base2, color: SOLARIZED.base1, border: 'none'}
    '.cm-activeLineGutter': {backgroundColor: SOLARIZED.base2, color: SOLARIZED.base01}
    '.cm-matchingBracket, .cm-nonmatchingBracket':
      {backgroundColor: SOLARIZED.base2, outline: "1px solid #{SOLARIZED.base1}"}
  , dark: false

  highlight = HighlightStyle.define [
    {tag: tags.keyword,                    color: SOLARIZED.green}
    {tag: [tags.name, tags.deleted, tags.character, tags.propertyName, tags.macroName],
                                           color: SOLARIZED.base00}
    {tag: [tags.function(tags.variableName), tags.labelName], color: SOLARIZED.blue}
    {tag: [tags.color, tags.constant(tags.name), tags.standard(tags.name)],
                                           color: SOLARIZED.yellow}
    {tag: [tags.definition(tags.name), tags.separator], color: SOLARIZED.base01}
    {tag: [tags.typeName, tags.className, tags.number, tags.changed,
           tags.annotation, tags.modifier, tags.self, tags.namespace],
                                           color: SOLARIZED.violet}
    {tag: [tags.operator, tags.operatorKeyword, tags.url, tags.escape,
           tags.regexp, tags.link, tags.special(tags.string)],
                                           color: SOLARIZED.cyan}
    {tag: [tags.meta, tags.comment],       color: SOLARIZED.base1, fontStyle: 'italic'}
    {tag: tags.strong,                     fontWeight: 'bold'}
    {tag: tags.emphasis,                   fontStyle: 'italic'}
    {tag: tags.strikethrough,              textDecoration: 'line-through'}
    {tag: tags.link,                       textDecoration: 'underline'}
    {tag: tags.heading,                    fontWeight: 'bold', color: SOLARIZED.orange}
    {tag: [tags.atom, tags.bool, tags.special(tags.variableName)], color: SOLARIZED.magenta}
    {tag: [tags.processingInstruction, tags.string, tags.inserted], color: SOLARIZED.cyan}
    {tag: tags.invalid,                    color: SOLARIZED.red}
  ]

  [theme, syntaxHighlighting(highlight)]

App.Editor.themes =
  'default':
    chrome: 'light'
    extension: -> []
  'one-dark':
    chrome: 'dark'
    extension: -> window.CM6.oneDark
  'solarized-light':
    chrome: 'light'
    extension: solarizedLight

App.Editor.themeFor = (name) ->
  App.Editor.themes[name] ? App.Editor.themes['default']

App.Editor.chromeFor = (name) ->
  App.Editor.themeFor(name).chrome
