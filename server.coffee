express = require 'express'
meshbluAuth = require 'express-meshblu-auth'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
TriggerController = require './trigger-controller'
cors = require 'cors'

MESHBLU_HOST          = process.env.MESHBLU_HOST || 'meshblu.octoblu.com'
MESHBLU_PORT          = process.env.MESHBLU_PORT || '443'
MESHBLU_PROTOCOL      = process.env.MESHBLU_PROTOCOL || 'https'
TRIGGER_SERVICE_PORT  = process.env.TRIGGER_SERVICE_PORT || 80
TRIGGER_SERVICE_UUID  = process.env.TRIGGER_SERVICE_UUID
TRIGGER_SERVICE_TOKEN = process.env.TRIGGER_SERVICE_TOKEN

triggerController = new TriggerController
  server: MESHBLU_HOST
  port: MESHBLU_PORT
  protocol: MESHBLU_PROTOCOL

app = express()
app.use cors()
app.use meshbluHealthcheck()

app.use '/triggers', meshbluAuth
  server: MESHBLU_HOST
  port: MESHBLU_PORT
  protocol: MESHBLU_PROTOCOL

app.options '*', cors()

app.get '/triggers', triggerController.getTriggers

app.post '/flows/:flowId/triggers/:triggerId', triggerController.trigger

server = app.listen TRIGGER_SERVICE_PORT, ->
  host = server.address().address
  port = server.address().port

  console.log "Server running on #{host}:#{port}"
