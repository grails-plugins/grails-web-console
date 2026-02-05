App.Entities = App.Entities || {}

localStorageKey = 'gconsole.settings'

App.Entities.Settings = Backbone.Model.extend

    defaults:
        'orientation': 'vertical'
        'layout.west.isClosed': true
        'layout.west.size': 250
        'layout.east.size': '50%'
        'layout.south.size': '50%'
        'results.showPane': true
        'results.wrapText': true
        'results.showInput': false
        'editor.autoImportDomains': true
        'editor.warnBeforeExit': true
        'theme': 'default'

    toggle: (attribute) ->
        @set attribute, not @get(attribute)

    save: ->
        localStorage.setItem localStorageKey, JSON.stringify(this)

    load: ->
        json = JSON.parse(localStorage.getItem(localStorageKey)) or {}
        @set json

# Singleton instance
App.Entities._settingsInstance = undefined

App.Entities.getSettings = ->
    unless App.Entities._settingsInstance
        App.Entities._settingsInstance = new App.Entities.Settings
        App.Entities._settingsInstance.load()
    App.Entities._settingsInstance
