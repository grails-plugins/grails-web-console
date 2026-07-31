Marionette.Renderer.render = (template, data) ->
  JST[template] data, { allowProtoPropertiesByDefault: true } # use compiled templates

$.ajaxSetup(
  beforeSend: (xhr, settings) ->
    if not this.crossDomain and App.data
      # Send Spring Security CSRF token if available
      if App.data.springSecurityCsrfToken and App.data.springSecurityCsrfHeader
        xhr.setRequestHeader App.data.springSecurityCsrfHeader, App.data.springSecurityCsrfToken
      # Also send console's own CSRF token if enabled
      else if App.data.csrfToken
        xhr.setRequestHeader 'X-CSRFToken', App.data.csrfToken
)

Application = Marionette.Application.extend

  fileStores: {}

# Marionette 3.x: onBeforeStart receives (app, options)
  onBeforeStart: (app, options = {}) ->
# In Marionette 3.x, first arg is the app instance, second is options
    @data = options || {}

    @data[App.Util.snakeToCamel(k)] = v for k, v of @data

    # Initialize file stores
    App.Entities.initLocalFileStore()
    App.Entities.initRemoteFileStore(@data)

    # mixed content check for #36
    if window.location.protocol is 'https:' and @data.baseUrl.indexOf('http:') is 0
      @data.baseUrl = @data.baseUrl.replace 'http:', 'https:'

    modifier = if navigator.userAgent.indexOf('Mac OS X') != -1 then '⌘' else 'Ctrl'
    @data.shortcuts = {}
    @data.shortcuts["#{modifier}-enter"] = 'Execute'
    @data.shortcuts["#{modifier}-s"] =     'Save'
    @data.shortcuts["Esc"] =               'Clear output'

    # Marionette 3.x: Create regions directly
    @headerRegion = new Marionette.Region(el: '#header')
    @mainRegion = new Marionette.Region(el: '#main-content')
    @healthRegion = new Marionette.Region(el: '#health-region')

    @settings = App.Entities.getSettings()
    @editorController = new App.Editor.Controller
    @filesController = new App.Files.Controller
    @resultController = new App.Result.Controller
    @router = new App.Main.Router()

    @contentView = new App.Main.ContentView
      editorView: @editorController.editorView
      resultsView: @resultController.resultsView
      scriptsView: @filesController.scriptsView

    @mainRegion.show @contentView
    @contentView.refresh()

    @helpView = new App.Main.HelpView
    @helpView.on 'toggle:help', => @handleHelp()
    @healthRegion.show @helpView

    @on 'file:deleted', @onFileDeleted

# Marionette 3.x: Replace commands.setHandler with direct execute method
  execute: (command, args...) ->
    switch command
      when 'save' then @handleSave()
      when 'saveAs' then @handleSaveAs()
      when 'new' then @handleNew()
      when 'execute' then @handleExecute()
      when 'clear' then @handleClear()
      when 'help' then @handleHelp()
      when 'openFile' then @handleOpenFile(args...)
      when 'showFile' then @handleShowFile(args...)
      when 'toggleScripts' then @handleToggleScripts()
      when 'toggleResults' then @handleToggleResults()

  handleExecute: ->
    input = @editorController.getValue()
    @resultController.execute input

  handleClear: ->
    @resultController.clear()

  handleNew: ->
    if @_okToCloseCurrentFile()
      @router.showNew()
      @editorController.newFile()

  _okToCloseCurrentFile: ->
    not App.settings.get('editor.warnBeforeExit') or not @editorController.isDirty() or confirm 'Are you sure? You have unsaved changes.'

  handleSave: ->
    @editorController.save()

  handleSaveAs: ->
    text = @editorController.getValue()

    if @editorController.file.isNew()
      collection = @getActiveCollection()
      store = collection.store
      path = collection.path
    else
      file = @getActiveFile()
      store = file.store
      path = file.getParent()

    @filesController.promptForNewFile(store, path).done (file) =>
      if file
        file.set 'text', text

        @savingOn()
        file.save().then =>
          @savingOff()
          @editorController.showFile file
          @router.showFile file
          @trigger 'file:created', file

  getActiveFile: -> @editorController.file

  getActiveCollection: -> @filesController.collection

  handleHelp:->
    @healthRegion.$el.toggleClass 'd-none'

  handleOpenFile: (store, name) ->
    dfd = App.Entities.getFile(store, name)
    dfd.done (file) =>
      if file.isDirectory()
        @filesController.fetchScripts file.store, file.getAbsolutePath()
        @editorController.newFile()
      else
        @filesController.fetchScripts file.store, file.getParent()
        @editorController.showFile file
    dfd.fail (error) =>
      alert error
      @editorController.newFile()

  handleShowFile: (file) ->
    if @_okToCloseCurrentFile()
      file.fetch().done =>
        @editorController.showFile file
        @router.showFile file

  handleToggleScripts: ->
    @settings.toggle 'layout.west.isClosed'
    @settings.save()

  handleToggleResults: ->
    @contentView.toggleResults()

  onFileDeleted: (file) ->
    if @getActiveFile().id is file.id
      @router.showNew()
      @editorController.newFile()

  onStart: (data) ->
    @headerRegion.show new App.Main.HeaderView

    @_initKeybindings()

    @showTheme()
    @settings.on 'change:theme', @showTheme, this

    Backbone.history.start(pushState: false) if Backbone?.history
    $('body').css 'visibility', 'visible'

  _initKeybindings: ->
    # Document-wide so the shortcuts work with focus anywhere — the scripts
    # panel, nothing at all. App.Util.Keys applies the two guards: not while
    # typing in a field, and not for keys the editor's own keymap already
    # handled.
    keys = App.Util.Keys

    keys.global ((event) -> event.key is 'Enter' and keys.mod event), =>
      @execute 'execute'

    keys.global ((event) -> event.key?.toLowerCase() is 's' and keys.mod event), (event) =>
      event.preventDefault()
      event.stopPropagation()
      @execute 'save'

    keys.global ((event) -> event.key is 'Escape'), =>
      @execute 'clear'

  createLink: (action, params) ->
    link = "#{@data.baseUrl}/#{action}"
    link += '?' + $.param(params, true) if params
    link

  showTheme: ->
    theme = @settings.get('theme')
    # The surrounding chrome only has a light and a dark variant; editor themes
    # are independent of it, so adding one costs no stylesheet work.
    $('body').attr 'data-theme', theme
    $('body').attr 'data-chrome', App.Editor.chromeFor(theme)

  savingOn: ->
    $('.navbar .saving').fadeIn 100

  savingOff: ->
    $('.navbar .saving').fadeOut 100

  addFileStore: (fileStore) ->
    @fileStores[fileStore.storeName] = fileStore

  getFileStoreByName: (storeName) ->
    @fileStores[storeName]

  getAllFileStores: ->
    _.values @fileStores

  removeFileStore: (fileStore) ->
    delete @fileStores[fileStore.storeName]

window.App = new Application()
