var path = require('path');

module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib-jst');

  grunt.initConfig({
    jst: {
      compile: {
        options: {
          processName: function(filepath) {
            return path.basename(filepath, '.html');
          },
          templateSettings: {
            escape      : /\{\{(.+?)\}\}/g,
            evaluate    : /\{\{\$(.+?)\}\}/g,
            interpolate : /\{\{\{(.+?)\}\}\}/g
          }
        },
        files: {
          'js/tpl.js': ['tpl/*.html']
        }
      }
    }
  });

  grunt.registerTask('default', 'jst');
};
