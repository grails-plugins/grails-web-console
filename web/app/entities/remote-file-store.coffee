App.Entities = App.Entities || {}

###
File store for files on the server.
###
class App.Entities.RemoteFileStore

  storeName: 'remote'

  displayName: 'Remote Storage'

  syncFile: (method, file, options) ->
    url = if file.isNew() then App.createLink 'file' else App.createLink 'file', path: file.get('id')
    Backbone.sync(method, file, _.extend({url: url}, options)).then(null, @parseErrorMessage)

  syncCollection: (method, collection, options) ->
    url = App.createLink 'listFiles', path: collection.getNormalizedPath() + '/'
    Backbone.sync method, collection, _.extend({url: url}, options)

  parseCollection: (collection, response, options) ->
    collection.path = response.path # path gets normalized
    response.files

  parseErrorMessage: (jqxhr) ->
    resp = null

    try
      resp = JSON.parse(jqxhr.responseText)
    catch ex

    resp?.error ? 'An error occurred.'

# Initialize remote file store when app starts (if enabled)
App.Entities.initRemoteFileStore = (options) ->
  App.addFileStore new App.Entities.RemoteFileStore if options.remoteFileStoreEnabled
