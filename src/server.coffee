cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
OctobluRaven       = require 'octoblu-raven'
compression        = require 'compression'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
MeshbluAuth        = require 'express-meshblu-auth'
expressVersion     = require 'express-package-version'
SendError          = require 'express-send-error'
Router             = require './router'
multer             = require 'multer'
debug              = require('debug')('triggers-service:server')

class Server
  constructor: (options)->
    {@disableLogging, @port} = options
    {@meshbluConfig,@octobluRaven} = options
    @octobluRaven ?= new OctobluRaven

  address: =>
    @server.address()

  run: (callback) =>
    meshbluAuth = new MeshbluAuth @meshbluConfig

    app = express()
    app.use compression()
    app.use @octobluRaven.express().handleErrors()
    app.use meshbluHealthcheck()
    app.use expressVersion(format: '{"version": "%s"}')
    app.use SendError()
    skip = (request, response) =>
      return response.statusCode < 400
    app.use morgan 'dev', { immediate: false, skip } unless @disableLogging
    app.use cors()
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
