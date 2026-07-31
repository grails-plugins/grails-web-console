App.Result = App.Result || {}

App.Result.ResultCollectionView = Marionette.CompositeView.extend

  template: 'result/results'

  attributes:
    class: 'results-view'

  childViewContainer: '.inner'

  events:
    'click .clear': 'onClearClick'
    'click .close-it': 'onCloseClick'
    'submit .prompt-form': 'onPromptSubmit'

  childView: -> App.Result.ResultView

  onAddChild: (childView) ->
# Delay scroll to allow the view to render
    _.defer => @scrollToResultView childView

  initialize: ->
    @listenTo App.settings, 'change:results.wrapText', @setWrap
    @listenTo App.settings, 'change:results.showInput', @setShowInput
    @listenTo @, 'childview:complete', @scrollToResultView

  scrollToResultView: (resultView) ->
    return unless resultView and resultView.$el and resultView.$el.length
    scroll = resultView.$el.position().top + resultView.$el.height() + @$('.script-result-section').scrollTop()
    @$('.script-result-section').animate scrollTop: scroll

  setWrap: ->
    @$('.script-result-section').toggleClass 'wrap', App.settings.get('results.wrapText')

  setShowInput: ->
    @$('.script-result-section').toggleClass 'hide-input', !App.settings.get('results.showInput')

  onRender: ->
    @setWrap()
    @setShowInput()

    @$('.prompt').on 'keydown', null, 'Shift+return return', (event) => @onExecute(event)
    @$('.prompt').on 'keyup', null, 'up', (event) => @onUpKeyPress(event)
    @$('.prompt').on 'keyup', null, 'down', (event) => @onDownKeyPress(event)

  onClearClick: (event) ->
    event.preventDefault()
    App.execute 'clear'

  onCloseClick: (event) ->
    event.preventDefault()
    App.execute 'toggleResults'

  onUpKeyPress: (event) ->
    @trigger 'upKeyPress'

  onDownKeyPress: (event) ->
    @trigger 'downKeyPress'

  setPromptText: (text) ->
    @$('.prompt').val text
    prompt = @$('.prompt')[0]
    prompt.setSelectionRange(text.length, text.length) if text

  onExecute: (event) ->
    input = @$('.prompt').val()
    if input
      if not event.shiftKey
        @trigger 'execute', input.trim()
        @$('.prompt').val ''

      @$('.prompt').css 'overflow', 'hidden'
      @$('.prompt').height 0
      @$('.prompt').height @$('.prompt')[0].scrollHeight

  clear: ->
    @$('.script-result.welcome').remove()

  serializeData: ->
    implicitVars = for k, v of App.data.implicitVars
      App.Util.padRight("  #{k}", 20) + v

    shortcuts = for k, v of App.data.shortcuts
      App.Util.padRight("  #{k}", 20) + v

    grailsVersion: App.data.grailsVersion
    groovyVersion: App.data.groovyVersion
    implicitVars: implicitVars
    shortcuts: shortcuts
