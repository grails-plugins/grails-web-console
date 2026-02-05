App.Result = App.Result || {}

# Marionette 3.x: Controller was removed, use Marionette.Object instead
App.Result.Controller = Marionette.Object.extend

  initialize: (options) ->
    @history = new App.Result.History

    @collection = new App.Result.ResultCollection()
    @resultsView = new App.Result.ResultCollectionView(collection: @collection)
    @resultsView.on 'execute', @executeInline, @
    @resultsView.on 'upKeyPress', @onUpKeyPress, @
    @resultsView.on 'downKeyPress', @onDownKeyPress, @

  onUpKeyPress: ->
    text = @history.getPrev()
    @resultsView.setPromptText text

  onDownKeyPress: ->
    text = @history.getNext()
    @resultsView.setPromptText text

  executeInline: (input) ->
    @history.add input
    @execute input

  execute: (input) ->
    result = new App.Result.Result
      input: input

    result.execute()
    @collection.add result

  clear: ->
    @resultsView.clear()
    @collection.reset()

App.Result.History = class

  constructor: ->
    @array = []
    @resetIndex()

  add: (text) ->
    @array.push text
    @resetIndex()

  getPrev: ->
    @index-- if @index > 0
    @array[@index]

  getNext: ->
    @index++ if @index < @array.length
    text = if @index < @array.length then @array[@index] else ''
    text

  resetIndex: ->
    @index = @array.length
