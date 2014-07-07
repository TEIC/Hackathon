'use strict';

module.exports = function(grunt) {

  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-contrib-watch');

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    connect: {
      server: {
        options: {
          port: 8000,
          hostname: "localhost"
        }
      }
    },

    bower: { install: true },

    watch: {
      scripts: {
        files: ['src/*.js', 'less/*.less'],
        options: {
          livereload: true
        }
      }
    },

  });

  grunt.registerTask('default', ['connect:server', "watch"]);

};
