Meshblu      = require './meshblu'
TriggerModel = require './trigger-model'

class TriggerController
  constructor: (meshbluOptions) ->
    @triggerModel = new TriggerModel()
    @meshblu = new Meshblu meshbluOptions

  trigger: (req, res) =>
    bearerToken = req.bearerToken
    return res.status(401).send('Unauthorized') unless bearerToken?

    {flowId, triggerId} = req.params

    @meshblu.trigger flowId, triggerId, bearerToken, (error, body) =>
      return res.status(401).json(error.message) if error?.message == 'unauthorized'
      return res.status(500) if error?
      return res.status(201).json(body)

  getTriggers: (req, res) =>
    bearerToken = req.bearerToken
    return res.status(401).send('Unauthorized') unless bearerToken?

    @meshblu.flows bearerToken, (error, body) =>
      return res.status(401).json(error.message) if error?.message == 'unauthorized'
      return res.status(500) if error?

      triggers = @triggerModel.parseTriggersFromDevices body.devices
      return res.status(200).json(triggers)

module.exports = TriggerController
