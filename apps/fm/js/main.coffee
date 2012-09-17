log = console.log.bind console

File = Backbone.Model.extend
  defaults:
    active: false

FileView = Backbone.View.extend
  tagName: 'li'
  template: JST.file
  render: ->
    @$el.addClass @model.get 'type'
    @$el.html @template @model.toJSON()
    @
  initialize: ->
    @model.on 'change:active', @active, @
  active: (active) ->
    @$el.toggleClass 'active', active

Dir = Backbone.Collection.extend
  model: File

DirView = Backbone.View.extend
  tagName: 'ul'
  initialize: ->
    @collection.on 'reset', @render, @
  render: ->
    @collection.each (file) =>
      fileView = new FileView model: file
      @$el.append fileView.render().el
    @

Column = Backbone.View.extend()

Columns = Backbone.View.extend
  initialize: ->
    @model.on 'change:pwd', @append, @
  append: (app, pwd) ->
    app.rpc 'ls', [pwd], (files) =>
      dir = new Dir files
      dirView = new DirView
        collection: dir
      @$el.append dirView.render().el

Header = Backbone.View.extend
  template: JST.header
  render: ->
    @$el.html @template @model.toJSON()
    @
  initialize: ->
    @model.on 'change:pwd', @render, @

App = Backbone.Model.extend
  rpc: (method, args, cb) ->
    $.ajax
      type: 'POST'
      url: '/rpc'
      data: { method, args }
      dataType: 'json'
      success: cb

app = new App
header = new Header
  model: app
  el: '#header'
columns = new Columns
  model: app
  el: '#columns'

app.rpc 'env', ['HOME', 'USER', 'HOSTNAME'], (data) ->
  [pwd, user, hostname] = data
  app.set { pwd, user, hostname }
