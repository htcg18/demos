log = console.log.bind console

Item = Backbone.Model.extend
  defaults:
    active: false

ItemView = Backbone.View.extend
  tagName: 'li'
  template: JST.item
  render: ->
    @$el.toggleClass 'active', @model.get 'active'
    @$el.html @template @model.toJSON()
    @
  initialize: ->
    @model.on 'change', @render, @

List = Backbone.Collection.extend
  model: Item

ListView = Backbone.View.extend
  tagName: 'ul'
  className: 'nav nav-list well'
  render: ->
    @collection.each (model) =>
      view = new ItemView { model }
      @$el.append view.render().el
  initialize: ->
    @collection.on 'reset', @render, @

Router = Backbone.Router.extend
  routes:
    'list/:item': 'activate'
  activate: (item) ->
    App.activated?.set 'active', false
    App.activated = model = App.list.get item
    model.set 'active', true
    App.display.render model

Display = Backbone.View.extend
  tagName: 'pre'
  render: (model) ->
    s = ''
    for key, val of model.toJSON()
      s += "#{key}: #{val}\n"
    @$el.text s

App =
  initialize: ->
    @list = list = new List
    listView = new ListView
      collection: list
    $('#menu').append listView.el
    @display = display = new Display
    $('#display').append display.el

    #replace with list.fetch
    list.reset [
      { name: 'foo', id: 'foo' }
      { name: 'bar', id: 'bar' }
      { name: 'baz', id: 'baz' }
    ]

    router = new Router
    Backbone.history.start()

App.initialize()
