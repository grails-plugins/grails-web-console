App.Main = App.Main || {}

App.Main.HelpView = Marionette.View.extend

    template: 'main/help'

    triggers:
        'click .close-it': 'toggle:help'

    className: 'full-height help-view'

    serializeData: ->
        implicitVars: App.data.implicitVars
        shortcuts: App.data.shortcuts
