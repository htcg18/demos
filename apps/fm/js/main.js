// Generated by CoffeeScript 1.3.3
(function() {
  var App, Columns, Dir, DirView, File, FileView, Files, Header, app, columns, header, log;

  log = console.log.bind(console);

  File = Backbone.Model.extend({
    defaults: {
      active: false
    }
  });

  FileView = Backbone.View.extend({
    tagName: 'li',
    template: JST.file,
    render: function() {
      this.$el.addClass(this.model.get('type'));
      this.$el.html(this.template(this.model.toJSON()));
      return this;
    },
    initialize: function() {
      return this.model.on('change:active', this.active, this);
    },
    active: function(file, active) {
      return this.$el.toggleClass('active', active);
    }
  });

  Files = Backbone.Collection.extend({
    model: File
  });

  Dir = Backbone.Model.extend({
    down: function() {
      var active, files, length;
      active = this.get('active');
      files = this.get('files');
      length = files.length;
      if (!(active < length - 1)) {
        return;
      }
      files.at(active).set('active', false);
      active += 1;
      files.at(active).set('active', true);
      return this.set('active', active);
    }
  });

  DirView = Backbone.View.extend({
    tagName: 'ul',
    initialize: function() {
      return this.collection.on('reset', this.render, this);
    },
    render: function() {
      var _this = this;
      this.collection.each(function(file) {
        var fileView;
        fileView = new FileView({
          model: file
        });
        return _this.$el.append(fileView.render().el);
      });
      if (this.collection.length) {
        this.collection.at(0).set('active', true);
        this.model.set('active', 0);
      }
      return this;
    }
  });

  Columns = Backbone.View.extend({
    initialize: function() {
      return this.model.on('change:pwd', this.append, this);
    },
    append: function(app, pwd) {
      var _this = this;
      return app.rpc('ls', [pwd], function(files) {
        var dir, dirView;
        files = new Files(files);
        dir = new Dir({
          files: files
        });
        dirView = new DirView({
          collection: files,
          model: dir
        });
        _this.$el.append(dirView.render().el);
        return dir.down();
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
      return this.model.on('change:pwd', this.render, this);
    }
  });

  App = Backbone.Model.extend({
    rpc: function(method, args, cb) {
      return $.ajax({
        type: 'POST',
        url: '/rpc',
        data: {
          method: method,
          args: args
        },
        dataType: 'json',
        success: cb
      });
    }
  });

  app = new App;

  header = new Header({
    model: app,
    el: '#header'
  });

  columns = new Columns({
    model: app,
    el: '#columns'
  });

  app.rpc('env', ['HOME', 'USER', 'HOSTNAME'], function(data) {
    var hostname, pwd, user;
    pwd = data[0], user = data[1], hostname = data[2];
    return app.set({
      pwd: pwd,
      user: user,
      hostname: hostname
    });
  });

}).call(this);
