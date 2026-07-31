App.Util = App.Util || {}

# Replaces jquery.hotkeys, which matched on event.keyCode — deprecated in the UI
# Events spec — and was unmaintained since 2010. event.key covers everything the
# console binds.
#
# The plugin applied one guard of its own that is easy to lose: a handler bound
# somewhere other than the event target did not fire inside text-accepting
# fields, so Esc did not clear the output while you were typing a filename. That
# guard lives in isTyping, and the editor guard in isFromEditor: CodeMirror 6
# calls preventDefault on a handled key but not stopPropagation, so without it a
# shortcut pressed in the editor would run once from the editor's own keymap and
# again from the document.
#
# Handlers bound directly to a field — the results prompt — deliberately skip
# both guards, matching jquery.hotkeys, whose filter only applied when
# `this !== event.target`.

TEXT_INPUT = /^(?:textarea|select)$/i

App.Util.Keys =

    # true when a modifier that means "command" on this platform is held
    mod: (event) -> event.metaKey or event.ctrlKey

    isTyping: (event) ->
        target = event.target
        return false unless target
        TEXT_INPUT.test(target.nodeName) or target.type is 'text'

    isFromEditor: (event) ->
        $(event.target).closest('.cm-editor').length > 0

    # Binds a document-wide shortcut. `matches` receives the event and returns
    # whether this is the intended key; `handler` runs only when neither guard
    # applies.
    global: (matches, handler) ->
        keys = App.Util.Keys
        $(document).on 'keydown', (event) ->
            return unless matches event
            return if keys.isTyping(event) or keys.isFromEditor(event)
            handler event
