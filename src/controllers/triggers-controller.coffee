_ = require 'lodash'
MeshbluHttp = require 'meshblu-http'
TriggerParser = require '../helpers/trigger-parser'

class TriggersController
  constructor: ({@meshbluConfig}) ->

  myTriggers: (req, res) =>
    meshbluAuth = req.meshbluAuth ? {}
    meshbluConfig = _.defaults meshbluAuth, @meshbluConfig
    meshblu = new MeshbluHttp meshbluConfig
    meshblu.devices type: 'octoblu:flow', owner: meshbluConfig.uuid, (error, body) =>
      return res.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return res.status(error.code ? 500).send(error.message) if error?

      triggers = TriggerParser.parseTriggersFromDevices body.devices
      return res.status(200).json(triggers)

module.exports = TriggersController
