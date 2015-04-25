Meshblu      = require 'meshblu-http'
TriggerModel = require './trigger-model'
_            = require 'lodash'

class TriggerController
  constructor: (@meshbluOptions={}) ->
    @triggerModel = new TriggerModel()

  trigger: (request, response) =>
    {flowId, triggerId} = request.params

    defaultAuth =
      uuid: process.env.TRIGGER_SERVICE_UUID
      token: process.env.TRIGGER_SERVICE_TOKEN

    meshbluConfig = _.extend defaultAuth, request.meshbluAuth, @meshbluOptions
    meshblu = new Meshblu meshbluConfig
    message =
      devices: [flowId]
      topic: 'button'
      payload:
        from: triggerId
        params: request.body

    meshblu.message message, (error, body) =>
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(500).end() if error?
      return response.status(201).json(body)

  getTriggers: (request, response) =>
    meshbluConfig = _.extend request.meshbluAuth, @meshbluOptions
    meshblu = new Meshblu meshbluConfig
    meshblu.devices 'octoblu:flow', (error, body) =>
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(500).end() if error?

      triggers = @triggerModel.parseTriggersFromDevices body.devices
      return response.status(200).json(triggers)

module.exports = TriggerController
