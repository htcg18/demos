var path = require('path');

module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib-jst');

  // Project configuration.
  grunt.initConfig({
    jst: {
      compile: {
        options: {
          processName: function(filepath) {
            return path.basename(filepath, '.html');
          },
          templateSettings: {
            interpolate : /\{\{(.+?)\}\}/g
          }
        },
        files: {
          'app/js/tpl.js': ['app/tpl/*.html']
        }
      }
    }
  });

  // Default task.
  grunt.registerTask('default', 'jst');
};
