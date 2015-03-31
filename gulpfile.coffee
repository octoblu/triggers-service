gulp           = require 'gulp'
coffee         = require 'gulp-coffee'


gulp.task 'coffee:compile', ->
  gulp.src './**/*.coffee'
      .pipe coffee()
      .pipe concat('application.js')
      .pipe sourcemaps.write('.')
      .pipe gulp.dest('./public/assets/dist/')

gulp.task 'webserver', ->
  gulp.src './public'
      .pipe webserver({
        port: 8889
        livereload: false
        directoryListing: false
        open: false
      })

gulp.task 'default', ['coffee:compile'], ->

gulp.task 'watch', ['default', 'webserver'], ->
  gulp.watch ['./bower.json'], ['bower:concat', 'bower:css']
  gulp.watch ['./public/app/**/*.js'], ['javascript:concat']
  gulp.watch ['./app/**/*.coffee'], ['coffee:compile']
