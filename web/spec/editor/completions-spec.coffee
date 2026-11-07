describe 'App.Editor.implicitVarCompletions', ->

  beforeEach ->
    App.data = $.extend({}, App.data, implicitVars: {ctx: 'the Spring application context', config: 'the Grails configuration'})

  # Completion results for the document `doc`, with the cursor where `|` is.
  complete = (doc, explicit = false) ->
    cm = window.CM6
    pos = doc.indexOf('|')
    state = cm.EditorState.create
      doc: doc.replace('|', '')
      extensions: [cm.groovy()]
    cm.syntaxTree(state) # parse before asking
    App.Editor.implicitVarCompletions(new cm.CompletionContext(state, pos, explicit))

  labels = (result) -> (option.label for option in result.options)

  it 'offers the implicit variables at the start of a statement', ->
    result = complete 'ct|'
    expect(result.from).toBe 0
    expect(labels result).toEqual ['ctx', 'config']

  it 'offers them as a command argument and inside an interpolation', ->
    expect(complete 'println co|').not.toBeNull()
    expect(complete '"bean: ${ct|}"').not.toBeNull()

  it 'offers them on request with nothing typed', ->
    expect(complete '|', true).not.toBeNull()
    expect(complete '|', false).toBeNull()

  it 'stays quiet in strings, comments, declarations and member names', ->
    expect(complete '"ct|"').toBeNull()
    expect(complete '// ct|').toBeNull()
    expect(complete 'def ct|').toBeNull()
    expect(complete 'foo.ct|').toBeNull()

  it 'closes once a name is complete', ->
    expect(complete 'ctx|').toBeNull()
