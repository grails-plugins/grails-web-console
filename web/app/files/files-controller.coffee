App.Files = App.Files || {}

# Marionette 3.x: Controller was removed, use Marionette.Object instead
App.Files.Controller = Marionette.Object.extend

  initialize: ->
    @collection = new App.Entities.FileCollection()

    @listenTo App, 'file:created', (file) ->
      @fetchScripts file.store, file.getParent()

    @scriptsView = new App.Files.ScriptsView
      collection: @collection

  fetchScripts: (store, path) ->
    @collection.fetchByStoreAndPath store, path

  promptForNewFile: (store, path) ->
    dfd = $.Deferred()

    collection = new App.Entities.FileCollection()

    view = new App.Files.FilesSectionView
      collection: collection

    collection.fetchByStoreAndPath store, path

    App.Util.Modal.showInModal view,
      draggable: true
      resizable: true

    view.$el.find('.file-name').focus()

    view.on 'save', (file) ->
      dfd.resolveWith null, [file]
      view.destroy()

    view.on 'destroy', -> dfd.resolve()

    dfd.promise()
