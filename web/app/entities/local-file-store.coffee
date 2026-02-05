App.Entities = App.Entities || {}

###
File store that uses localStorage.
###
class App.Entities.LocalFileStore

  constructor: (@name) ->
    @_load()

  storeName: 'local'

  displayName: 'Local Storage'

  syncFile: (method, file, options) -> @sync method, file, options

  syncCollection: (method, collection, options) -> @sync method, collection, options

  parseCollection: (collection, response, options) -> response

  list: ->
    new App.Entities.FileCollection(@fetch())

  fetch: ->
    _.values @data

  find: (file) ->
    @data[file.id]

  create: (file) ->
    file.set 'lastModified', new Date().getTime()
    file.set 'id', file.get('path') + file.get('name')
    @data[file.id] = file.toJSON()
    @_save()
    file.toJSON()

  update: (file) ->
    file.set 'lastModified', new Date().getTime()
    @data[file.id] = file.toJSON()
    @_save()
    file.toJSON()

  destroy: (file) ->
    delete @data[file.id]

    @_save()
    file.toJSON()

  destroyAll: ->
    @data = {}
    localStorage.removeItem @name

  _save: ->
    localStorage.setItem @name, JSON.stringify(@data)

  _load: ->
    store = localStorage.getItem(@name)
    try
      @data = JSON.parse(store) ? {}
    catch e
      @data = {}
    file.type = 'file' for id, file of @data

  sync: (method, file, options) ->
    resp = undefined
    switch method
      when 'read'
        resp = if file.id then @find(file) else @fetch()
      when 'create'
        resp = @create(file) # save
      when 'update'
        resp = @update(file) # save
      when 'delete'
        resp = @destroy(file)

    dfd = $.Deferred()

    if resp
      dfd.resolveWith @, [resp]
      options?.success? resp
    else
      dfd.rejectWith @, ['File doesn\'t exist']
      options?.error? 'File doesn\'t exist'

    dfd

# Initialize local file store when app starts
App.Entities.initLocalFileStore = ->
  App.addFileStore new App.Entities.LocalFileStore('gconsole.files')
