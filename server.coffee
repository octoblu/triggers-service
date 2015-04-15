express = require 'express'
meshbluAuth = require 'express-meshblu-auth'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
TriggerController = require './trigger-controller'

MESHBLU_HOST         = process.env.MESHBLU_HOST || 'meshblu.octoblu.com'
MESHBLU_PORT         = process.env.MESHBLU_PORT || '443'
MESHBLU_PROTOCOL     = process.env.MESHBLU_PROTOCOL || 'https'
TRIGGER_SERVICE_PORT = process.env.TRIGGER_SERVICE_PORT || 9000

triggerController = new TriggerController
  server: MESHBLU_HOST
  port: MESHBLU_PORT
  protocol: MESHBLU_PROTOCOL

app = express()
app.use meshbluHealthcheck()

app.use meshbluAuth
  server: MESHBLU_HOST
  port: MESHBLU_PORT
  protocol: MESHBLU_PROTOCOL

app.get '/triggers', triggerController.getTriggers

app.post '/flows/:flowId/triggers/:triggerId', triggerController.trigger

server = app.listen TRIGGER_SERVICE_PORT, ->
  host = server.address().address
  port = server.address().port

  console.log "Server running on #{host}:#{port}"
