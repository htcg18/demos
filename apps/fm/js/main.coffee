log = console.log.bind console

File = Backbone.Model.extend()

FileView = Backbone.View.extend
  tagName: 'li'
  template: JST.file
  suffix: 'B K M G T P'.split ' '
  render: ->
    type = @model.get 'type'
    @$el.addClass type

    switch type
      when 'file', 'symlink'
        stats = @model.get 'size'
        i = 0
        while stats > 1024
          stats /= 1024
          i++
        stats = stats.toPrecision 3
        stats += @suffix[i]
      when 'directory'
        stats = -2 + @model.get 'nlink'
      else
        stats = type

    basename = @model.get 'basename'
    @$el.html @template { stats, basename }
    @
  initialize: ->
    @model.on 'change:active', @active, @
  active: (file, active) ->
    @$el.toggleClass 'active', active

Files = Backbone.Collection.extend
  model: File

Dir = Backbone.Model.extend
  defaults:
    index: 0
  goAbs: (index) ->
    if index is -1
      index += @get('files').length
    @changeIndex index
  goRel: (delta) ->
    index = delta + @get 'index'
    @changeIndex index
  changeIndex: (index) ->
    files = @get 'files'
    {length} = files
    return unless 0 <= index < length
    files.at(@get 'index').set 'active', false
    active = files.at index
    active.set 'active', true
    @set 'index', index
    App.set 'basename', active.get 'basename'

DirView = Backbone.View.extend
  tagName: 'ul'
  initialize: ->
    @collection.on 'reset', @render, @
  render: ->
    @collection.each (file) =>
      fileView = new FileView model: file
      @$el.append fileView.render().el
    @model.goRel 0
    @

Column = Backbone.View.extend
  className: 'column'

Columns = Backbone.View.extend
  shortcuts:
    'g, shift+k, home': 'home'
    'shift+g, shift+j, end': 'end'
    'j, s, down': 'down'
    'k, w, up': 'up'
    'l, right': 'right'
    'h, left': 'left'
  initialize: ->
    for shortcut, f of @shortcuts
      key shortcut, @[f].bind @
    App.on 'change:dirname', @append, @
  append: (App, dirname) ->
    col = new Column
    @$el.append col.render().el
    App.rpc 'ls', [dirname], (files) =>
      files = new Files files
      @dir = dir = new Dir { files }
      dirView = new DirView
        collection: files
        model: dir
      col.$el.append dirView.render().el
  home: ->
    @dir.goAbs 0
  end: ->
    @dir.goAbs -1
  down: ->
    @dir.goRel +1
  up: ->
    @dir.goRel -1
  right: ->
    dirname  = App.get 'dirname'
    basename = App.get 'basename'
    App.set 'dirname', dirname + basename + '/'
  left: ->

Header = Backbone.View.extend
  template: JST.header
  render: ->
    @$el.html @template App.toJSON()
    @
  initialize: ->
    App.on 'change', @render, @

Application = Backbone.Model.extend
  defaults:
    basename: ''
  rpc: (method, args, cb) ->
    $.ajax
      type: 'POST'
      url: '/rpc'
      data: { method, args }
      dataType: 'json'
      success: cb

App = new Application
new Header el: '#header'
new Columns el: '#columns'
App.rpc 'env', ['HOME', 'USER', 'HOSTNAME'], (data) ->
  [dirname, user, hostname] = data
  dirname += '/'
  App.set { dirname, user, hostname }
