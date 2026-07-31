App.Util = App.Util || {}

App.Util.Modal =

  ###
  options.draggable
  options.resizable
  ###
  showInModal: (view, options = {}) ->
    $el = $('<div class="modal" tabindex="-1" data-bs-backdrop="false"></div>').appendTo('body').html view.render().el
    modal = new bootstrap.Modal($el[0],
      backdrop: false
      keyboard: false
    )

    $el.on 'shown.bs.modal', -> view.resize?()

    # Bootstrap has no draggable or resizable modal, and these were the only
    # jQuery UI widgets the console used. Pointer capture makes both small
    # enough to do directly.
    if options.draggable
      App.Util.Modal.makeDraggable $el.find('.modal-content'), $el.find('.modal-header')
      $el.find('.modal-header').css 'cursor', 'move'

    if options.resizable
      App.Util.Modal.makeResizable $el.find('.modal-content'), -> view.resize?()

    $el.find('.modal-header .btn-close').on 'click', (event) ->
      event.preventDefault()
      view.destroy()

    $el.find('.modal-footer .cancel').on 'click', (event) ->
      event.preventDefault()
      view.destroy()

    view.on 'destroy', ->
      modal.hide()

    $el.on 'hidden.bs.modal', ->
      $el.remove()

    modal.show()

    $el

  # Drags $target by its $handle, switching the dialog to explicit positioning on
  # first move so Bootstrap's centring does not fight the offsets.
  makeDraggable: ($target, $handle) ->
    $handle.on 'pointerdown', (event) ->
      return if $(event.target).closest('button, a, input').length
      event.preventDefault()
      original = event.originalEvent
      rect = $target[0].getBoundingClientRect()
      startX = original.clientX
      startY = original.clientY
      $target.css {position: 'fixed', margin: 0, left: rect.left, top: rect.top,
                   width: rect.width}
      handle = event.currentTarget
      handle.setPointerCapture original.pointerId

      onMove = (moveEvent) ->
        move = moveEvent.originalEvent
        $target.css
          left: rect.left + (move.clientX - startX)
          top:  rect.top  + (move.clientY - startY)

      onUp = (upEvent) ->
        try handle.releasePointerCapture upEvent.originalEvent.pointerId
        $(handle).off 'pointermove', onMove
        $(handle).off 'pointerup pointercancel', onUp

      $(handle).on 'pointermove', onMove
      $(handle).on 'pointerup pointercancel', onUp

  # Adds a bottom-right grip that resizes $target, calling onResize as it goes.
  makeResizable: ($target, onResize) ->
    $grip = $('<div class="modal-resize-grip"></div>').appendTo $target
    $grip.on 'pointerdown', (event) ->
      event.preventDefault()
      original = event.originalEvent
      rect = $target[0].getBoundingClientRect()
      startX = original.clientX
      startY = original.clientY
      grip = event.currentTarget
      grip.setPointerCapture original.pointerId

      onMove = (moveEvent) ->
        move = moveEvent.originalEvent
        $target.css
          width:  Math.max(200, rect.width  + (move.clientX - startX))
          height: Math.max(150, rect.height + (move.clientY - startY))
        onResize?()

      onUp = (upEvent) ->
        try grip.releasePointerCapture upEvent.originalEvent.pointerId
        $(grip).off 'pointermove', onMove
        $(grip).off 'pointerup pointercancel', onUp
        onResize?()

      $(grip).on 'pointermove', onMove
      $(grip).on 'pointerup pointercancel', onUp
