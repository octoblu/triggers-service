TriggersController = require './controllers/triggers-controller'

class Router
  constructor: ({@meshbluConfig, @meshbluAuth}) ->
    @triggersController = new TriggersController {@meshbluConfig}

  route: (app) =>
    app.get '/all-triggers', @meshbluAuth.gateway(), @triggersController.allTriggers
    app.get '/triggers', @meshbluAuth.gateway(), @triggersController.myTriggers
    app.get '/mytriggers', @meshbluAuth.gateway(),  @triggersController.myTriggers
    app.get '/my-triggers', @meshbluAuth.gateway(), @triggersController.myTriggers
    app.get '/flows/:flowId/triggers/:triggerId', (req, res) ->
      res.status(405).send('Method Not Allowed: POST required')

    app.post '/flows/:flowId/triggers/:triggerId', @triggersController.sendMessageById
    app.post '/flows/triggers/:triggerName', @meshbluAuth.gateway(), @triggersController.sendMessageByName

module.exports = Router
