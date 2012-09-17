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
  active: (file, active) ->
    @$el.toggleClass 'active', active

Files = Backbone.Collection.extend
  model: File

Dir = Backbone.Model.extend
  down: ->
    active = @get 'active'
    files  = @get 'files'
    length = files.length
    return unless active < length - 1
    files.at(active).set 'active', false
    active += 1
    files.at(active).set 'active', true
    @set 'active', active

DirView = Backbone.View.extend
  tagName: 'ul'
  initialize: ->
    @collection.on 'reset', @render, @
  render: ->
    @collection.each (file) =>
      fileView = new FileView model: file
      @$el.append fileView.render().el
    if @collection.length
      @collection.at(0).set 'active', true
      @model.set 'active', 0
    @

Columns = Backbone.View.extend
  initialize: ->
    @model.on 'change:pwd', @append, @
  append: (app, pwd) ->
    app.rpc 'ls', [pwd], (files) =>
      files = new Files files
      dir = new Dir { files }
      dirView = new DirView
        collection: files
        model: dir
      @$el.append dirView.render().el
      dir.down()

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
