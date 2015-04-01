Meshblu      = require './meshblu'
TriggerModel = require './trigger-model'

class TriggerController
  constructor: ->
    @triggerModel = new TriggerModel()

  trigger: (req, res) =>
    flowId = req.params.flowId
    triggerId = req.params.triggerId
    bearerToken = req.header('Authorization')?.split(': ')[1]

    @triggerModel.trigger flowId, triggerId, bearerToken, (error, body) =>
      console.log 'Error: ', error.message if error
      console.log 'Body: ', body if body

      return res.status(201).json(body)

  getTriggers: (req, res) =>
    bearerToken = req.header('Authorization')?.split(': ')[1]

    return res.status(401).send('Unauthorized') unless bearerToken

    @triggerModel.getTriggers bearerToken, (error, triggers) =>
      return res.status(500).json(error) if error
      return res.status(200).json(triggers)

module.exports = TriggerController
