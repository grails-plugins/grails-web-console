App.Editor = App.Editor || {}

App.Editor.EditorView = Marionette.View.extend

    template: 'editor/editor'

    events:
        'click button.open': 'onOpenClick'
        'click button.execute': 'onExecuteClick'
        'click button.new': 'onNewClick'
        'click button.save': 'onSaveClick'
        'click a.save-as': 'onSaveAsClick'

    initialize: ->
        @listenTo App.settings, 'change:theme', @setTheme

    attributes:
        id: 'editor'

    onRender: ->
        @initEditor()

    initEditor: ->
        # CodeMirror 6 is loaded as an ES module by the import map in index.gsp,
        # which hangs its exports on window.CM6 before jQuery ready fires.
        cm = window.CM6
        @themeCompartment = new cm.Compartment()
        indent = ' '.repeat(App.data.indentUnit ? 4)

        run = (command) -> -> App.execute(command); true

        textarea = @$('textarea[name=code]')[0]
        @editor = new cm.EditorView
            doc: ''
            parent: textarea.parentNode
            extensions: [
                cm.lineNumbers()
                cm.highlightActiveLine()
                cm.highlightActiveLineGutter()
                cm.history()
                cm.bracketMatching()
                cm.syntaxHighlighting(cm.defaultHighlightStyle, fallback: true)
                cm.StreamLanguage.define(cm.groovy)
                cm.indentUnit.of(if App.data.indentWithTabs then '\t' else indent)
                cm.keymap.of([
                    {key: 'Mod-Enter', run: run('execute')}
                    {key: 'Mod-s',     run: run('save'), preventDefault: true}
                    {key: 'Escape',    run: run('clear')}
                    cm.indentWithTab
                ].concat(cm.defaultKeymap, cm.historyKeymap))
                @themeCompartment.of(@themeExtension())
            ]
        textarea.remove()
        @editor.focus()

    themeExtension: ->
        App.Editor.themeFor(App.settings.get('theme')).extension()

    setTheme: ->
        @editor.dispatch effects: @themeCompartment.reconfigure(@themeExtension())

    getValue: ->
        @editor.state.doc.toString()

    refresh: ->
        @editor.requestMeasure()

    setValue: (text) ->
        @editor.dispatch
            changes: {from: 0, to: @editor.state.doc.length, insert: text}
        @editor.focus()

    onOpenClick: (event) ->
        event.preventDefault()
        App.execute 'toggleScripts'

    onNewClick: (event) ->
        event.preventDefault()
        App.execute 'new'

    onSaveClick: (event) ->
        event.preventDefault()
        App.execute 'save'

    onSaveAsClick: (event) ->
        event.preventDefault()
        App.execute 'saveAs'

    onExecuteClick: (event) ->
        event.preventDefault()
        App.execute 'execute'

    onShow: ->
        @editor.focus()
