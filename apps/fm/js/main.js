// Generated by CoffeeScript 1.3.3
(function() {
  var App, Application, Dir, DirView, Dirs, DirsView, File, FileView, Files, Header, dirsView, header, log;

  log = console.log.bind(console);

  File = Backbone.Model.extend({
    prefixes: 'B K M G T P'.split(' '),
    initialize: function(attrs) {
      var i, nlink, size, stats, type;
      type = attrs.type, size = attrs.size, nlink = attrs.nlink;
      switch (type) {
        case 'file':
        case 'symlink':
          i = 0;
          while (size > 1024) {
            size /= 1024;
            i++;
          }
          size = size.toPrecision(3);
          stats = size + this.prefixes[i];
          break;
        case 'directory':
          stats = nlink - 2;
          break;
        default:
          stats = type;
      }
      return this.set({
        stats: stats
      });
    }
  });

  FileView = Backbone.View.extend({
    tagName: 'li',
    template: JST.file,
    render: function() {
      this.$el.html(this.template(this.model.toJSON()));
      return this;
    },
    active: function(model, active) {
      return this.$el.toggleClass('active', active);
    },
    initialize: function() {
      this.model.on('change:active', this.active, this);
      return this.$el.addClass(this.model.get('type'));
    }
  });

  Files = Backbone.Collection.extend({
    model: File
  });

  Dir = Backbone.Model.extend({
    defaults: {
      active: 0
    },
    goAbs: function(active) {
      if (active < 0) {
        active += this.get('files').length;
      }
      return this.go(active);
    },
    goDelta: function(delta) {
      var active;
      active = delta + this.get('active');
      return this.go(active);
    },
    go: function(active) {
      var basename, files, length, now, old;
      files = this.get('files');
      length = files.length;
      if (!((0 <= active && active < length))) {
        return;
      }
      old = files.at(this.get('active'));
      now = files.at(active);
      old.set({
        active: false
      });
      now.set({
        active: true
      });
      basename = now.get('basename');
      this.set({
        active: active,
        basename: basename
      });
      return App.set({
        basename: basename
      });
    }
  });

  DirView = Backbone.View.extend({
    tagName: 'ul',
    className: 'dir',
    render: function() {
      var _this = this;
      this.collection.each(function(model) {
        var fileView;
        fileView = new FileView({
          model: model
        });
        return _this.$el.append(fileView.render().el);
      });
      this.model.go(0);
      return this;
    },
    initialize: function() {
      this.collection = this.model.get('files');
      return this.model.on('remove', this.remove, this);
    }
  });

  Dirs = Backbone.Collection.extend({
    model: Dir
  });

  DirsView = Backbone.View.extend({
    shortcuts: {
      'g, shift+k, home': 'home',
      'shift+g, shift+j, end': 'end',
      'h, left': 'left',
      'j, down': 'down',
      'k, up': 'up',
      'l, right': 'right'
    },
    initialize: function() {
      var cb, shortcut, _ref;
      _ref = this.shortcuts;
      for (shortcut in _ref) {
        cb = _ref[shortcut];
        key(shortcut, this[cb].bind(this));
      }
      this.collection.on('add', this.add, this);
      this.collection.on('remove', this.remove, this);
      return this.model.on('change:dirname', this.dirname, this);
    },
    remove: function(model, collection) {
      var basename, dirname;
      this.model = this.collection.at(this.collection.length - 1);
      dirname = this.model.get('dirname');
      basename = this.model.get('basename');
      return App.set({
        dirname: dirname,
        basename: basename
      });
    },
    add: function(model) {
      var dirView;
      this.model = model;
      dirView = new DirView({
        model: model
      });
      this.$el.append(dirView.render().el);
      return App.set({
        dirname: model.get('dirname')
      });
    },
    home: function() {
      return this.model.goAbs(0);
    },
    end: function() {
      return this.model.goAbs(-1);
    },
    left: function() {
      return this.collection.pop();
    },
    down: function() {
      return this.model.goDelta(+1);
    },
    up: function() {
      return this.model.goDelta(-1);
    },
    right: function() {
      var basename, dirname;
      dirname = App.get('dirname');
      basename = App.get('basename');
      return App.set({
        dirname: dirname + basename + '/',
        basename: ''
      });
    },
    dirname: function(App, dirname) {
      var _this = this;
      if (!(App.previous('dirname').length < dirname.length)) {
        return;
      }
      return App.rpc('ls', [dirname], function(files) {
        var dir;
        files = new Files(files);
        dir = new Dir({
          files: files,
          dirname: dirname
        });
        return _this.collection.add(dir);
      });
    }
  });

  Header = Backbone.View.extend({
    template: JST.header,
    render: function() {
      this.$el.html(this.template(this.model.toJSON()));
      return this;
    },
    initialize: function() {
      return this.model.on('change', this.render, this);
    }
  });

  Application = Backbone.Model.extend({
    defaults: {
      dirname: '',
      basename: ''
    },
    rpc: function(method, args, cb) {
      return $.post('/rpc', {
        method: method,
        args: args
      }, cb, 'json');
    }
  });

  App = new Application;

  header = new Header({
    model: App,
    el: '#header'
  });

  dirsView = new DirsView({
    collection: new Dirs,
    model: App,
    el: '#dirs'
  });

  App.rpc('env', ['HOME', 'USER', 'HOSTNAME'], function(data) {
    var dirname, hostname, user;
    dirname = data[0], user = data[1], hostname = data[2];
    dirname += '/';
    return App.set({
      dirname: dirname,
      user: user,
      hostname: hostname
    });
  });

}).call(this);
