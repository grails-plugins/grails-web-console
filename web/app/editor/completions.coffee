App.Editor = App.Editor || {}

# Nodes inside which a name is not a variable reference: text in strings and
# comments, a name being declared, a member reached with a dot, and a label.
# Code inside a GString's ${...} is an Interpolation, so it is reached first
# when walking up from there and completes as usual.
NOT_A_REFERENCE = ['StringLiteral', 'GString', 'SlashyString', 'DollarSlashyString',
                   'LineComment', 'BlockComment', 'Definition', 'PropertyName', 'Label']

isReference = (node) ->
  while node
    return true if node.name is 'Interpolation'
    return false if node.name in NOT_A_REFERENCE
    node = node.parent
  true

# Completes the variables the console binds for every script (ctx,
# grailsApplication and the rest, sent by the server as App.data.implicitVars)
# where the syntax tree says an expression can stand.
App.Editor.implicitVarCompletions = (context) ->
  cm = window.CM6
  word = context.matchBefore(/[\w$]+/)
  return null unless word or context.explicit
  from = word?.from ? context.pos
  node = cm.syntaxTree(context.state).resolveInner(context.pos, -1)
  return null unless isReference(node)
  # `obj.ct` names a member of obj, not a variable
  return null if /(\.|::)\s*$/.test(context.state.sliceDoc(Math.max(0, from - 3), from))
  vars = App.data?.implicitVars ? {}
  # Close once the name is complete, so Enter goes on to insert a newline.
  return null if word and vars.hasOwnProperty(word.text)
  options = for name, description of vars
    {label: name, type: 'variable', detail: description}
  {from, options, validFor: /^[\w$]*$/}
