App.Main = App.Main || {}

App.Main.ContentView = Marionette.View.extend

    template: 'main/content'

    attributes:
        class: 'full-height'

    regions:
        centerRegion: '.center'
        westRegion: '.outer-west'

    initialize: (options) ->
        @listenTo App.settings, 'change:orientation', @updateInnerLayout
        @listenTo App.settings, 'change:results.showPane', @updateInnerLayout
        @listenTo App.settings, 'change:layout.west.isClosed', @updateOuterLayout

        @editorView = options.editorView
        @resultsView = options.resultsView
        @scriptsView = options.scriptsView



    onRender: ->
        @initLayout()

        @showChildView 'centerRegion', @editorView
        @showChildView 'westRegion', @scriptsView

        @resultsView.render()

        @updateInnerLayout()

    # onRender fires before the view is in the document, so the panes cannot
    # measure their container yet; percentage sizes only resolve once attached.
    onAttach: ->
        @updateOuterLayout()
        @updateInnerLayout()

    refresh: ->
        @editorView.refresh()
        @updateInnerLayout()

    initLayout: ->
        # west (scripts) | everything else
        @layoutOuter = new App.Util.Splitter @$el,
            direction: 'horizontal'
            before: true
            fixed: @$('.outer-west')
            flexible: @$('.outer-center')
            size: App.settings.get('layout.west.size')
            onResizeEnd: (size) ->
                App.settings.set 'layout.west.size', size
                App.settings.save()

        # editor | results, side by side or stacked depending on orientation
        @layoutEast = new App.Util.Splitter @$('.outer-center'),
            direction: 'horizontal'
            fixed: @$('.east')
            flexible: @$('.center')
            size: App.settings.get('layout.east.size')
            onResize: => @editorView.refresh()
            onResizeEnd: (size) ->
                App.settings.set 'layout.east.size', size
                App.settings.save()

        @layoutSouth = new App.Util.Splitter @$('.outer-center'),
            direction: 'vertical'
            fixed: @$('.south')
            flexible: @$('.center')
            size: App.settings.get('layout.south.size')
            onResize: => @editorView.refresh()
            onResizeEnd: (size) ->
                App.settings.set 'layout.south.size', size
                App.settings.save()

        @layoutEast.hide()
        @layoutSouth.hide()
        @layoutOuter.hide() if App.settings.get 'layout.west.isClosed'

    toggleScripts: ->
        App.settings.set 'layout.west.isClosed', not @layoutOuter.isHidden()
        App.settings.save()
        @updateOuterLayout()

    updateOuterLayout: ->
        if App.settings.get 'layout.west.isClosed'
            @layoutOuter.hide()
        else
            @layoutOuter.show()

    toggleResults: ->
        App.settings.set 'results.showPane', not App.settings.get('results.showPane')
        App.settings.save()
        @updateInnerLayout()

    updateInnerLayout: ->
        if not App.settings.get 'results.showPane'
            @layoutSouth.hide()
            @layoutEast.hide()
            @editorView.refresh()
            return

        if App.settings.get('orientation') is 'vertical'
            @$('.east').append @resultsView.el
            @layoutSouth.hide()
            @layoutEast.show()
        else
            @$('.south').append @resultsView.el
            @layoutEast.hide()
            @layoutSouth.show()
        @editorView.refresh()
