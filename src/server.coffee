cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
MeshbluAuth        = require 'express-meshblu-auth'
expressVersion     = require 'express-package-version'
SendError          = require 'express-send-error'
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
    meshbluAuth = new MeshbluAuth @meshbluConfig

    app = express()
    app.use meshbluHealthcheck()
    app.use expressVersion(format: '{"version": "%s"}')
    app.use SendError()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use meshbluAuth.retrieve()
    app.use multer().any()
    # app.use bodyParser.raw type: 'multipart/form-data', limit: '50mb', extended: true
    app.use bodyParser.urlencoded limit: '50mb', extended : true, defer: true
    app.use bodyParser.json limit : '50mb', defer: true

    app.options '*', cors()

    router = new Router {@meshbluConfig, meshbluAuth}
    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
