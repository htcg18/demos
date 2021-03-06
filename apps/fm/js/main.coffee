log = console.log.bind console

File = Backbone.Model.extend
  prefixes: 'B K M G T P'.split ' '
  initialize: (attrs) ->
    {type, size, nlink} = attrs
    switch type
      when 'file', 'symlink'
        i = 0
        while size > 1024
          size /= 1024
          i++
        size = size.toPrecision 3
        stats = size + @prefixes[i]
      when 'directory'
        stats = nlink - 2
      else
        stats = type
    @set { stats }

FileView = Backbone.View.extend
  tagName: 'li'
  template: JST.file
  render: ->
    @$el.html @template @model.toJSON()
    @
  active: (model, active) ->
    @$el.toggleClass 'active', active
  initialize: ->
    @model.on 'change:active', @active, @
    @$el.addClass @model.get 'type'

Files = Backbone.Collection.extend
  model: File

Dir = Backbone.Model.extend
  defaults:
    active: 0
  goAbs: (active) ->
    if active < 0
      active += @get('files').length
    @go active
  goDelta: (delta) ->
    active = delta + @get 'active'
    @go active
  go: (active) ->
    files = @get 'files'
    {length} = files
    return unless 0 <= active < length
    old = files.at @get 'active'
    now = files.at active
    old.set active: false
    now.set active: true
    basename = now.get 'basename'
    @set { active, basename }
    App.set { basename }

DirView = Backbone.View.extend
  tagName: 'ul'
  className: 'dir'
  render: ->
    @collection.each (model) =>
      fileView = new FileView { model }
      @$el.append fileView.render().el
    @model.go 0
    @
  initialize: ->
    @collection = @model.get 'files'
    @model.on 'remove', @remove, @

Dirs = Backbone.Collection.extend
  model: Dir

DirsView = Backbone.View.extend
  shortcuts:
    'g, shift+k, home': 'home'
    'shift+g, shift+j, end': 'end'
    'h, left': 'left'
    'j, down': 'down'
    'k, up': 'up'
    'l, right': 'right'
  initialize: ->
    for shortcut, cb of @shortcuts
      key shortcut, @[cb].bind @
    @collection.on 'add', @add, @
    @collection.on 'remove', @remove, @
    App.on 'change:dirname', @dirname, @
  remove: (model, collection) ->
    @dir = @collection.at @collection.length - 1
    dirname  = @dir.get 'dirname'
    basename = @dir.get 'basename'
    App.set { dirname, basename }
  add: (model) ->
    @dir = model
    dirView = new DirView { model }
    @$el.append dirView.render().el
    App.set dirname: model.get 'dirname'
  home: ->
    @dir.goAbs 0
  end: ->
    @dir.goAbs -1
  left: ->
    @collection.pop()
  down: ->
    @dir.goDelta +1
  up: ->
    @dir.goDelta -1
  right: ->
    dirname  = App.get 'dirname'
    basename = App.get 'basename'
    App.set
      dirname: dirname + basename + '/'
      basename: ''
  dirname: (App, dirname) ->
    prev = App.previous 'dirname'
    prev or= ''
    return unless prev.length < dirname.length #XXX
    App.rpc 'ls', [dirname], (files) =>
      files = new Files files
      dir = new Dir { files, dirname }
      @collection.add dir

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
    $.post '/rpc', { method, args }, cb, 'json'

App = new Application
header = new Header
  el: '#header'
dirsView = new DirsView
  collection: new Dirs
  el: '#dirs'

App.rpc 'env', ['HOME', 'USER', 'HOSTNAME'], (data) ->
  [dirname, user, hostname] = data
  dirname += '/'
  App.set { dirname, user, hostname }
