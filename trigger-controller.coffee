MeshbluHttp      = require 'meshblu-http'
TriggerModel = require './trigger-model'
_            = require 'lodash'
debug        = require('debug')('triggers-service:trigger-controller')

class TriggerController
  constructor: (@meshbluOptions={}) ->
    @triggerModel = new TriggerModel()

  trigger: (request, response) =>
    {flowId, triggerId} = request.params

    defaultAuth =
      uuid: process.env.TRIGGER_SERVICE_UUID
      token: process.env.TRIGGER_SERVICE_TOKEN

    meshbluConfig = _.extend {}, defaultAuth, request.meshbluAuth, @meshbluOptions
    meshblu = new MeshbluHttp meshbluConfig
    message =
      devices: [flowId]
      topic: 'triggers-service'
      payload:
        from: triggerId
        params: request.body

    debug 'sending message', message

    meshblu.message message, (error, body) =>
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(error.code ? 500).send(error.message) if error?
      return response.status(201).json(body)

  getTriggers: (request, response) =>
    meshbluConfig = _.extend request.meshbluAuth, @meshbluOptions
    meshblu = new MeshbluHttp meshbluConfig
    meshblu.devices type: 'octoblu:flow', (error, body) =>
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(error.code ? 500).send(error.message) if error?

      triggers = @triggerModel.parseTriggersFromDevices body.devices
      return response.status(200).json(triggers)

  getMyTriggers: (request, response) =>
    meshbluAuth = request.meshbluAuth ? {}
    meshbluConfig = _.extend meshbluAuth, @meshbluOptions
    meshblu = new MeshbluHttp meshbluConfig
    meshblu.devices type: 'octoblu:flow', owner: meshbluConfig.uuid, (error, body) =>
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(error.code ? 500).send(error.message) if error?

      triggers = @triggerModel.parseTriggersFromDevices body.devices
      return response.status(200).json(triggers)

module.exports = TriggerController
