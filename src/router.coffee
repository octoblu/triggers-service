TriggersController = require './controllers/triggers-controller'
meshbluAuth = require 'express-meshblu-auth'
MeshbluAuthExpress = require 'express-meshblu-auth/src/meshblu-auth-express'

class Router
  constructor: ({@meshbluConfig}) ->
    @meshbluAuth = meshbluAuth @meshbluConfig
    @triggersController = new TriggersController {@meshbluConfig}

  route: (app) =>
    app.get '/triggers', @meshbluAuth, @triggersController.myTriggers
    app.get '/mytriggers', @meshbluAuth,  @triggersController.myTriggers
    app.get '/my-triggers', @meshbluAuth, @triggersController.myTriggers

module.exports = Router
