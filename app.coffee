express = require 'express'
TriggerController = require './trigger-controller'

app = express()
triggerController = new TriggerController()

app.get '/', (req, res) ->
  res.send online: true

app.get '/triggers', triggerController.getTriggers

app.post '/trigger/:flowId/:triggerId', triggerController.trigger


server = app.listen 8889
