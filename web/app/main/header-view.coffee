App.Main = App.Main || {}

App.Main.HeaderView = Marionette.View.extend

    template: 'main/header'

    attributes:
        class: 'navbar fixed-top'

    initialize: ->
        @listenTo App, 'file:show', @onFileShow

    onFileShow: (file) ->
        name = file.get('name')
        if name
            @$('.title span').html(name).removeClass('d-none')
        else
            @$('.title span').addClass('d-none')

    onRender: ->
        @settingsView = new App.Main.SettingsView(model: App.settings)
        @$('.settings-btn-group').append @settingsView.render().$el
        @settingsView.render()

    onDestroy: ->
        @settingsView.destroy()
