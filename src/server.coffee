cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
meshbluAuth = require 'express-meshblu-auth'
MeshbluAuthExpress = require 'express-meshblu-auth/src/meshblu-auth-express'
debug              = require('debug')('triggers-service:server')
Router             = require './router'
multer             = require 'multer'

class Server
  constructor: (options)->
    {@disableLogging, @port} = options
    {@meshbluConfig} = options

  address: =>
    @server.address()

  run: (callback) =>
    app = express()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use meshbluHealthcheck()
    app.use multer().any()
    app.use bodyParser.urlencoded limit: '50mb', extended : true, defer: true
    app.use bodyParser.json limit : '50mb', defer: true

    app.options '*', cors()

    router = new Router {@meshbluConfig}
    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
