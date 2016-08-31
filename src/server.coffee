expressOctoblu = require 'express-octoblu'
MeshbluAuth    = require 'express-meshblu-auth'
Router         = require './router'
multer         = require 'multer'
debug          = require('debug')('triggers-service:server')

class Server
  constructor: (options)->
    { @logFn, @disableLogging, @port } = options
    { @meshbluConfig } = options

  address: =>
    @server.address()

  run: (callback) =>
    meshbluAuth = new MeshbluAuth @meshbluConfig

    app = expressOctoblu({ @logFn, @disableLogging, bodyLimit: '50mb' })
    app.use meshbluAuth.auth()
    app.use multer().any()

    router = new Router {@meshbluConfig, meshbluAuth}
    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
