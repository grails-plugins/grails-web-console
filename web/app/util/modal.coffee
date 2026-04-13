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

    if options.draggable
      $el.find('.modal-content').draggable
        handle: '.modal-header'
        addClasses: false

      $el.find('.modal-header').css 'cursor', 'move'

    if options.resizable
      $el.find('.modal-content').resizable
        addClasses: false
        resize: (event, ui) -> view.resize?()

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
