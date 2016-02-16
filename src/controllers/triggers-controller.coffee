TriggersService = require '../services/triggers-service'
_               = require 'lodash'
typeIs          = require 'type-is'
debug           = require('debug')('triggers-service:triggers-controller')

class TriggersController
  constructor: ({@meshbluConfig}) ->

  allTriggers: (request, response) =>
    triggersService = new TriggersService {meshbluConfig: request.meshbluAuth}

    triggersService.allTriggers (error, triggers) =>
      return response.status(error.code || 500).send error: error if error?
      response.status(200).send triggers

  myTriggers: (request, response) =>
    triggersService = new TriggersService {meshbluConfig: request.meshbluAuth}

    triggersService.myTriggers (error, triggers) =>
      return response.status(error.code || 500).send error: error if error?
      response.status(200).send triggers

  sendMessageById: (request, response) =>
    {flowId, triggerId} = request.params
    {body} = request

    debug 'sendMessageById', request.header('Content-Type'), request.body

    triggersService = new TriggersService {@meshbluConfig}

    uploadedFiles = @_handleFiles request

    triggersService.sendMessageById {flowId,triggerId,uploadedFiles,body}, (error) =>
      return response.status(error.code || 500).send error: error if error?
      response.sendStatus(201)

  sendMessageByName: (request, response) =>
    {triggerName} = request.params
    {body} = request

    debug 'sendMessageByName', request.header('Content-Type'), request.body

    triggersService = new TriggersService {meshbluConfig: request.meshbluAuth}

    uploadedFiles = @_handleFiles request

    triggersService.sendMessageByName {triggerName,uploadedFiles,body}, (error) =>
      return response.status(error.code || 500).send error: error if error?
      response.sendStatus(201)

  _handleFiles: (request) =>
    return unless typeIs(request, ['multipart/form-data'])
    return if _.isEmpty request.files
    uploadedFiles = {}
    _.each request.files, (file) =>
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
