TriggerModel = require './trigger-model'

class TriggerController
  constructor: ->
    @TriggerModel = new TriggerModel()

  getTriggers: (req, res) =>
    bearerToken = ''

    return res.status(401).send('unauthorized') unless bearerToken

    @TriggerModel.triggers bearerToken, (error, response, body) =>
      return res.status(500).send(error) if error
      return res.status(200).send(response.body)

module.exports = TriggerController
