gulp    = require 'gulp'
nodemon = require 'gulp-nodemon'

gulp.task 'server', ->
  nodemon
    script: 'app.coffee'
    ext: 'html js coffee'
    ignore: ['./node_modules/**']
    env:
      'MESHBLU_HOST': '0.0.0.0'
      'MESHBLU_PORT': '3000'
      'MESHBLU_PROTOCOL': 'http'
      'TRIGGER_SERVICE_PORT': '8889'

gulp.task 'default', ['watch']

gulp.task 'watch', ['server']
