'use strict';

module.exports = function(grunt) {

  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-concat');

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

    concat: {
      bower_js: {
        options: {
          separator: "\n",
        },
        src: ['bower_components/jquery/dist/jquery.min.js', 
              'bower_components/underscore/underscore.js', 
              'bower_components/d3/d3.min.js'],
        dest: 'visualizer/lib/main.js'
      }
    },
      

    bower: { install: true },

    watch: {
      scripts: {
        files: ['src/*.js'],
        options: {
          livereload: true
        }
      }
    },

  });

  grunt.registerTask('default', ['concat', 'connect:server', "watch"]);

};
