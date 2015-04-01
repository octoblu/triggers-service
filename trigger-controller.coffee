TriggerModel = require './trigger-model'

class TriggerController
  constructor: ->
    @TriggerModel = new TriggerModel()

  getTriggers: (req, res) =>
    bearerToken = req.header('Authorization')?.split(' ')[1]

    return res.status(401).send('Unauthorized') unless bearerToken

    @TriggerModel.getTriggers bearerToken, (error, triggers) =>
      return res.status(500).json(error) if error
      return res.status(200).json(triggers)

module.exports = TriggerController
