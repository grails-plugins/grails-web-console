App.Util = App.Util || {}

# A two-pane splitter built on flexbox and pointer events, replacing the parts
# of jquery.layout the console used. jquery.layout was abandoned in 2013 and
# needed jQuery UI's draggable, which was the only reason 250K of jQuery UI
# shipped at all.
#
# One flexible pane and one sized pane, with a draggable bar between them. The
# sized pane can be hidden, which takes the bar with it. Sizes are reported back
# through onResizeEnd so the caller can persist them.
#
#   new App.Util.Splitter $container,
#     direction: 'horizontal'   # bar moves left/right; 'vertical' moves up/down
#     fixed: $sidePane          # the pane with an explicit size
#     flexible: $mainPane       # takes the remaining space
#     before: true              # fixed pane comes first in the DOM
#     size: 250
#     onResize: -> ...          # during the drag, once per frame
#     onResizeEnd: (size) -> ...

MIN_PANE = 40
KEY_STEP = 12
KEY_STEP_LARGE = 60
PERSIST_DELAY = 250

class Splitter

    constructor: (@$container, @options = {}) ->
        {@direction, @fixed, @flexible, @onResize, @onResizeEnd} = @options
        # jquery.layout accepted percentages, and the stored defaults still are
        # ('50%'), so a size is resolved against the container rather than
        # assumed to be pixels. Resolution is deferred until the container has
        # been laid out, since panes are constructed before the view is attached.
        @rawSize = @options.size
        @size = null
        @before = @options.before ? false
        @horizontal = @direction isnt 'vertical'
        @hidden = false

        # The direction is applied in show(), not here: the east and south
        # splitters share .outer-center as their container and only one of them
        # is ever visible, so whichever was constructed last would otherwise pin
        # the container to its own axis.
        @$container.addClass 'splitter-container'
        @fixed.addClass 'splitter-pane splitter-pane-fixed'
        @flexible.addClass 'splitter-pane splitter-pane-flexible'

        # title restores jquery.layout's tooltip; the ARIA bits make the bar
        # something a screen reader can name, which it never was before
        @$bar = $('<div class="splitter-bar" title="Resize" role="separator"></div>')
        @$bar.attr 'aria-orientation', if @horizontal then 'vertical' else 'horizontal'
        # tabindex makes the separator reachable; a focusable separator is the
        # one ARIA allows to carry value attributes, so the position can be
        # announced as it moves
        @$bar.attr 'tabindex', '0'
        @$bar.attr 'aria-label', 'Resize panes'
        if @before then @$bar.insertAfter(@fixed) else @$bar.insertBefore(@fixed)

        @$bar.on 'pointerdown', @onPointerDown
        @$bar.on 'keydown', @onKeyDown
        @applySize()

    # --- sizing ---------------------------------------------------------

    extent: ->
        if @horizontal then @$container.width() else @$container.height()

    resolveSize: ->
        total = @extent()
        return null unless total > 0
        half = Math.round total / 2
        return half unless @rawSize?
        if typeof @rawSize is 'string' and @rawSize.indexOf('%') isnt -1
            percent = parseFloat @rawSize
            return if isNaN percent then half else Math.round total * percent / 100
        parsed = parseFloat @rawSize
        if isNaN parsed then half else parsed

    applySize: ->
        @size ?= @resolveSize()
        unless @size?
            # The container has no extent yet — panes are built in onRender,
            # before the view is attached — so try again once it has been laid
            # out. Bounded, so a permanently hidden container cannot spin.
            if (@retries ?= 0) < 10
                @retries++
                requestAnimationFrame => @applySize() unless @hidden
            return
        @retries = 0
        prop = if @horizontal then 'width' else 'height'
        @fixed.css 'flex', "0 0 #{@clamp @size}px"
        @fixed.css prop, ''    # flex-basis drives it; a stale width would fight it
        @announce()

    announce: ->
        total = @extent()
        return unless total > 0
        bar = if @horizontal then @$bar.outerWidth() else @$bar.outerHeight()
        @$bar.attr 'aria-valuenow', Math.round @size
        @$bar.attr 'aria-valuemin', MIN_PANE
        @$bar.attr 'aria-valuemax', Math.max MIN_PANE, total - MIN_PANE - bar

    setSize: (size) ->
        @size = @clamp size
        @applySize()

    clamp: (size) ->
        total = @extent()
        return size unless total > 0
        bar = if @horizontal then @$bar.outerWidth() else @$bar.outerHeight()
        max = Math.max MIN_PANE, total - MIN_PANE - bar
        Math.min Math.max(size, MIN_PANE), max

    # --- visibility -----------------------------------------------------

    show: ->
        @$container.toggleClass 'splitter-vertical', not @horizontal
        if @hidden
            @hidden = false
            @fixed.show()
            @$bar.show()
        # Always re-apply: the first call happens in onRender, before the view is
        # attached, when the container has no extent and a percentage cannot be
        # resolved. Returning early here left the pane unsized on first paint.
        @applySize()

    hide: ->
        return if @hidden
        @hidden = true
        @fixed.hide()
        @$bar.hide()

    isHidden: -> @hidden

    # --- dragging -------------------------------------------------------

    onPointerDown: (event) =>
        event.preventDefault()
        original = event.originalEvent
        @$bar.addClass 'dragging'
        # capture keeps events coming to the bar even when the pointer runs over
        # the editor or an iframe, which is what made this fiddly before
        # Capture keeps events coming to the bar when the pointer runs over the
        # editor, but it is an optimisation — a browser that refuses it should
        # still get a working drag.
        try @$bar[0].setPointerCapture original.pointerId
        @dragStart = if @horizontal then original.clientX else original.clientY
        @size ?= @resolveSize()
        @dragStartSize = @size ? Math.round @extent() / 2
        @$bar.on 'pointermove', @onPointerMove
        @$bar.on 'pointerup pointercancel', @onPointerUp

    onPointerMove: (event) =>
        original = event.originalEvent
        position = if @horizontal then original.clientX else original.clientY
        delta = position - @dragStart
        delta = -delta unless @before
        @setSize @dragStartSize + delta
        unless @frame
            @frame = requestAnimationFrame =>
                @frame = null
                @onResize?()

    onPointerUp: (event) =>
        @$bar.removeClass 'dragging'
        try @$bar[0].releasePointerCapture event.originalEvent.pointerId
        @$bar.off 'pointermove', @onPointerMove
        @$bar.off 'pointerup pointercancel', @onPointerUp
        if @frame
            cancelAnimationFrame @frame
            @frame = null
        @onResize?()
        @onResizeEnd? @size

    # --- keyboard -------------------------------------------------------

    # Arrow keys nudge the bar along its own axis, shift for a coarser step, and
    # Home/End jump to the extremes. Movement is expressed as right/down positive
    # and then mapped through @before exactly as a drag is, so the pane grows in
    # the direction the bar visually travels.
    onKeyDown: (event) =>
        movement = switch event.key
            when 'ArrowLeft'  then if @horizontal then -1 else 0
            when 'ArrowRight' then if @horizontal then 1 else 0
            when 'ArrowUp'    then if @horizontal then 0 else -1
            when 'ArrowDown'  then if @horizontal then 0 else 1
            when 'Home'       then 'min'
            when 'End'        then 'max'
            else null
        return if not movement? or movement is 0

        event.preventDefault()
        @size ?= @resolveSize()
        return unless @size?

        if movement is 'min'
            @setSize MIN_PANE
        else if movement is 'max'
            @setSize @extent()
        else
            step = if event.shiftKey then KEY_STEP_LARGE else KEY_STEP
            delta = movement * step
            delta = -delta unless @before
            @setSize @size + delta

        @onResize?()
        # one write per burst of keypresses rather than one per key
        clearTimeout @persistTimer if @persistTimer
        @persistTimer = setTimeout =>
            @persistTimer = null
            @onResizeEnd? @size
        , PERSIST_DELAY

    destroy: ->
        clearTimeout @persistTimer if @persistTimer
        @$bar.off()
        @$bar.remove()

App.Util.Splitter = Splitter
