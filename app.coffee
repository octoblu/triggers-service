express = require 'express'
bearerToken = require 'express-bearer-token'
TriggerController = require './trigger-controller'

MESHBLU_HOST         = process.env.MESHBLU_HOST
MESHBLU_PORT         = process.env.MESHBLU_PORT
MESHBLU_PROTOCOL     = process.env.MESHBLU_PROTOCOL
TRIGGER_SERVICE_PORT = process.env.TRIGGER_SERVICE_PORT

triggerController = new TriggerController
  server: MESHBLU_HOST
  port: MESHBLU_PORT
  protocol: MESHBLU_PROTOCOL

app = express()
app.use bearerToken reqKey: 'bearerToken'

app.get '/', (req, res) ->
  res.send online: true

app.get '/triggers', triggerController.getTriggers

app.post '/trigger/:flowId/:triggerId', triggerController.trigger

server = app.listen TRIGGER_SERVICE_PORT, =>
  host = server.address().address
  port = server.address().port

  console.log "Server running on #{host}:#{port}"
