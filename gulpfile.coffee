gulp    = require 'gulp'
nodemon = require 'gulp-nodemon'

gulp.task 'server', ->
  nodemon
    script: 'app.coffee'
    ext: 'html js'
    ignore: ['./node_modules/**']

gulp.task 'default', ['watch']

gulp.task 'watch', ['server']
