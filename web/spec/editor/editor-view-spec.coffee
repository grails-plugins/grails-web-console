describe 'App.Editor.EditorView', ->

  beforeEach ->
    App.settings = new App.Entities.Settings()

    @view = new App.Editor.EditorView

    @$el = $('<div></div>').appendTo('body')
    @$el.append @view.render().$el

  afterEach ->
    @view.destroy()
    @$el.remove()

  it 'should setValue and getValue', ->
    @view.setValue 'test value'
    expect(@view.getValue()).toBe 'test value'

  it 'should syncEditorSettings', ->
    darkTheme = window.CM6.EditorView.darkTheme
    expect(@view.editor.state.facet darkTheme).toBe false
    App.settings.set 'theme', 'one-dark'
    expect(@view.editor.state.facet darkTheme).toBe true
    App.settings.set 'theme', 'default'
    expect(@view.editor.state.facet darkTheme).toBe false

  it 'should execute new on click', ->
    spyOn App, 'execute'
    $('button.new').click()
    expect(App.execute).toHaveBeenCalledWith 'new'

  it 'should execute save on click', ->
    spyOn App, 'execute'
    $('button.save').click()
    expect(App.execute).toHaveBeenCalledWith 'save'

  it 'should execute saveAs on click', ->
    spyOn App, 'execute'
    $('a.save-as').click()
    expect(App.execute).toHaveBeenCalledWith 'saveAs'

  it 'should execute execute on click', ->
    spyOn App, 'execute'
    $('button.execute').click()
    expect(App.execute).toHaveBeenCalledWith 'execute'