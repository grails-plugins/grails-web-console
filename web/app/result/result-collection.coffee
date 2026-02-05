App.Result = App.Result || {}

App.Result.ResultCollection = Backbone.Collection.extend

  model: (attrs, options) -> new App.Result.Result attrs, options
