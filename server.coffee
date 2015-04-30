express = require 'express'
meshbluAuth = require 'express-meshblu-auth'
MeshbluAuthExpress = require 'express-meshblu-auth/src/meshblu-auth-express'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
TriggerController = require './trigger-controller'
cors = require 'cors'
bodyParser = require 'body-parser'

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
app.use bodyParser.urlencoded limit: '50mb', extended : true
app.use bodyParser.json limit : '50mb'

meshbluOptions =
  server: MESHBLU_HOST
  port: MESHBLU_PORT
  protocol: MESHBLU_PROTOCOL

app.use '/triggers', meshbluAuth meshbluOptions
app.use '/mytriggers', meshbluAuth meshbluOptions

app.use '/flows/:flowId/triggers/:triggerId', (request, response, next) ->
  meshbluAuthExpress = new MeshbluAuthExpress meshbluOptions
  meshbluAuthExpress.getFromAnywhere request

  defaultAuth =
    uuid: TRIGGER_SERVICE_UUID
    token: TRIGGER_SERVICE_TOKEN

  {uuid, token} = request.meshbluAuth ? defaultAuth
  return response.status(401).end() unless uuid? && token?
  meshbluAuthExpress.authDeviceWithMeshblu uuid, token, (error) ->
    if error?
      console.error error
      return response.status(401).end()
    next()

app.options '*', cors()

app.get '/triggers', triggerController.getTriggers
app.get '/mytriggers', triggerController.getMyTriggers

app.post '/flows/:flowId/triggers/:triggerId', triggerController.trigger

app.get '/flows/:flowId/triggers/:triggerId', (request, response) ->
  response.status(405).send('Method Not Allowed: POST required')

server = app.listen TRIGGER_SERVICE_PORT, ->
  host = server.address().address
  port = server.address().port

  console.log "Server running on #{host}:#{port}"
