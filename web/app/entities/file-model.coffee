App.Entities = App.Entities || {}

App.Entities.File = Backbone.Model.extend

    defaults: ->
        text: App.data.newFileText ? ''

    getAbsolutePath: -> @id

    getParent: ->
        App.Util.Path.getParent @id

    isDirectory: ->
        @get('type') is 'dir'

    isFile: ->
        @get('type') is 'file'

    sync: (method, file, options) ->
        fileStore = App.getFileStoreByName(@store)
        if fileStore
            App.getFileStoreByName(@store).syncFile method, file, options
        else
            alert "Invalid store: #{@store}"

App.Entities.getFile = (store, path) ->
    file = new App.Entities.File id: path
    file.store = store
    file.fetch().then -> file
