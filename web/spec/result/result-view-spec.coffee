describe 'App.Result.ResultView', ->

  beforeEach ->
    @model = new App.Result.Result
    @view = new App.Result.ResultView
      model: @model

  afterEach ->

  it 'should convertTreeNode', ->
    @model.set
      input: 'test'
      exception:
        message: 'test-name'
        stackTrace:
          a: 'a'
          b: 'b'

    result = @view.serializeData()

    expect(result.resultTree).toEqual
      name: 'test-name'
      children: [
        {name: 'a', value: 'a'}
        {name: 'b', value: 'b'}
      ]

    @model.set
      input: 'test'
      exception:
        message: 'test-name'
        stackTrace: ['aaa', 'bbb', 'ccc']

    result = @view.serializeData()

    expect(result.resultTree).toEqual
      name: 'test-name'
      children: [
        {name: 'aaa'}
        {name: 'bbb'}
        {name: 'ccc'}
      ]
