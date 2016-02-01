_ = require 'lodash'
TriggersController = require './controllers/triggers-controller'
meshbluAuth = require 'express-meshblu-auth'
MeshbluAuthExpress = require 'express-meshblu-auth/src/meshblu-auth-express'

class Router
  constructor: ({@meshbluConfig}) ->
    @meshbluAuth = meshbluAuth @meshbluConfig
    @triggersController = new TriggersController {@meshbluConfig}

  route: (app) =>
    app.get '/all-triggers', @meshbluAuth, @triggersController.allTriggers
    app.get '/triggers', @meshbluAuth, @triggersController.myTriggers
    app.get '/mytriggers', @meshbluAuth,  @triggersController.myTriggers
    app.get '/my-triggers', @meshbluAuth, @triggersController.myTriggers
    app.get '/flows/:flowId/triggers/:triggerId', (req, res) ->
      res.status(405).send('Method Not Allowed: POST required')

    # app.post '/flows/:flowId/triggers/:triggerId', @_conditionalAuth, @triggersController.sendMessage
    app.post '/flows/:flowId/triggers/:triggerId', @triggersController.sendMessage

  _conditionalAuth: (req, res, next) =>
    meshbluAuthExpress = new MeshbluAuthExpress @meshbluConfig
    meshbluAuthExpress.getFromAnywhere req

    auth = req.meshbluAuth ? {}

    {uuid, token} = _.defaults auth, @meshbluConfig
    return res.status(401).end() unless uuid? && token?
    meshbluAuthExpress.authDeviceWithMeshblu uuid, token, (error) ->
      return res.status(error.code ? 500).send(error.message) if error?
      next()

module.exports = Router
