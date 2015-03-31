express = require 'express'
routes = require './routes'
app = express()

app.use routes

server = app.listen 8889, ->
  host = server.address().address
  port = server.address().port

  console.log 'Server running http://%s:%s', host, port
