_ = require 'lodash'
typeIs = require 'type-is'
MeshbluHttp = require 'meshblu-http'
TriggerParser = require '../helpers/trigger-parser'
debug = require('debug')('triggers-service:triggers-controller')
randomstring = require 'randomstring'

class TriggersController
  constructor: ({@meshbluConfig}) ->

  allTriggers: (req, res) =>
    meshbluAuth = req.meshbluAuth ? {}
    meshbluConfig = _.defaults meshbluAuth, @meshbluConfig
    meshbluHttp = new MeshbluHttp meshbluConfig
    meshbluHttp.devices type: 'octoblu:flow', (error, body) =>
      return res.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return res.status(error.code ? 500).send(error.message) if error?

      triggers = TriggerParser.parseTriggersFromDevices body.devices
      return res.status(200).json(triggers)

  myTriggers: (req, res) =>
    meshbluAuth = req.meshbluAuth ? {}
    meshbluConfig = _.defaults meshbluAuth, @meshbluConfig
    meshbluHttp = new MeshbluHttp meshbluConfig
    meshbluHttp.devices type: 'octoblu:flow', owner: meshbluConfig.uuid, (error, body) =>
      return res.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return res.status(error.code ? 500).send(error.message) if error?

      triggers = TriggerParser.parseTriggersFromDevices body.devices
      return res.status(200).json(triggers)

  sendMessage: (req, res) =>
    {flowId, triggerId} = req.params

    debug 'sendMessage', req.header('Content-Type'), req.body

    meshbluAuth = req.meshbluAuth ? {}
    meshbluConfig = _.defaults meshbluAuth, @meshbluConfig
    meshbluHttp = new MeshbluHttp meshbluConfig

    uploadedFiles = @_handleFiles req
    message =
      devices: [flowId]
      topic: 'triggers-service'
      payload:
        from: triggerId
        params: req.body
        payload: req.body
        files: uploadedFiles

    meshbluHttp.message message, (error, body) =>
      return res.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return res.status(error.code ? 500).send(error.message) if error?
      return res.status(201).json(body)

  _handleFiles: (req) =>
    return unless typeIs(req, ['multipart/form-data'])
    return if _.isEmpty req.files
    uploadedFiles = {}
    _.each req.files, (file) =>
      buf = file.buffer.toString('utf8')
      if file.mimetype == 'application/json'
        try
          buf = JSON.parse buf
        catch error

      filename = file.originalname ? file.fieldname
      if uploadedFiles[filename]?
        filename = "#{filename}_#{randomstring.generate(7)}"

      uploadedFiles[filename] =
        mimeType: file.mimetype
        data: buf
        fieldName: file.fieldname
        originalName: file.originalname
        encoding: file.encoding
        size: file.size

    return uploadedFiles

module.exports = TriggersController
