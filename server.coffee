express = require 'express'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
TriggerController = require './trigger-controller'
cors = require 'cors'
bodyParser = require 'body-parser'

MESHBLU_HOST          = process.env.MESHBLU_HOST || 'meshblu.octoblu.com'
MESHBLU_PORT          = process.env.MESHBLU_PORT || '443'
MESHBLU_PROTOCOL      = process.env.MESHBLU_PROTOCOL || 'https'
TRIGGER_SERVICE_PORT  = process.env.TRIGGER_SERVICE_PORT || process.env.PORT || 80
TRIGGER_SERVICE_UUID  = process.env.TRIGGER_SERVICE_UUID
TRIGGER_SERVICE_TOKEN = process.env.TRIGGER_SERVICE_TOKEN

triggerController = new TriggerController
  server: MESHBLU_HOST
  port: MESHBLU_PORT
  protocol: MESHBLU_PROTOCOL

app = express()
app.use cors()
app.use meshbluHealthcheck()
app.use bodyParser.urlencoded limit: '50mb', extended : true
app.use bodyParser.json limit : '50mb'

meshbluOptions =
  server: MESHBLU_HOST
  port: MESHBLU_PORT
  protocol: MESHBLU_PROTOCOL

app.use '/all-triggers', meshbluAuth meshbluOptions
app.use '/triggers', meshbluAuth meshbluOptions
app.use '/mytriggers', meshbluAuth meshbluOptions
app.use '/my-triggers', meshbluAuth meshbluOptions

app.use '/flows/:flowId/triggers/:triggerId', (request, response, next) ->
  meshbluAuthExpress = new MeshbluAuthExpress meshbluOptions
  meshbluAuthExpress.getFromAnywhere request

  defaultAuth =
    uuid: TRIGGER_SERVICE_UUID
    token: TRIGGER_SERVICE_TOKEN

  {uuid, token} = request.meshbluAuth ? defaultAuth
  return response.status(401).end() unless uuid? && token?
  meshbluAuthExpress.authDeviceWithMeshblu uuid, token, (error) ->
    return response.status(error.code ? 500).send(error.message) if error?
    next()

app.options '*', cors()

app.get '/all-triggers', triggerController.getTriggers
app.get '/triggers', triggerController.getMyTriggers
app.get '/mytriggers', triggerController.getMyTriggers
app.get '/my-triggers', triggerController.getMyTriggers

app.post '/flows/:flowId/triggers/:triggerId', triggerController.trigger

app.get '/flows/:flowId/triggers/:triggerId', (request, response) ->
  response.status(405).send('Method Not Allowed: POST required')

server = app.listen TRIGGER_SERVICE_PORT, ->
  host = server.address().address
  port = server.address().port

  console.log "Server running on #{host}:#{port}"
