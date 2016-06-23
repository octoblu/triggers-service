TriggersService = require '../services/triggers-service'
_               = require 'lodash'
typeIs          = require 'type-is'
debug           = require('debug')('triggers-service:triggers-controller')

class TriggersController
  constructor: ({@meshbluConfig}) ->

  allTriggers: (request, response) =>
    triggersService = new TriggersService {meshbluConfig: request.meshbluAuth}

    {type, flowContains} = request.query
    triggersService.allTriggers {type, flowContains}, (error, triggers) =>
      return response.sendError(error) if error?
      response.status(200).send triggers

  myTriggers: (request, response) =>
    triggersService = new TriggersService {meshbluConfig: request.meshbluAuth}

    {type, flowContains} = request.query
    triggersService.myTriggers {type, flowContains}, (error, triggers) =>
      return response.sendError(error) if error?
      response.status(200).send triggers

  sendMessageById: (request, response) =>
    {flowId, triggerId} = request.params
    {body} = request

    debug 'sendMessageById', request.header('Content-Type'), request.body

    triggersService = new TriggersService {@meshbluConfig}

    uploadedFiles = @_handleFiles request

    triggersService.sendMessageById {flowId,triggerId,uploadedFiles,body}, (error) =>
      return response.sendError(error) if error?
      response.status(201).send triggered: true

  sendMessageByIdV2: (request, response) =>
    {flowId, triggerId} = request.params
    {body} = request

    debug 'sendMessageById', request.header('Content-Type'), request.body

    triggersService = new TriggersService {@meshbluConfig}

    uploadedFiles = @_handleFiles request

    triggersService.sendMessageByIdV2 {flowId,triggerId,uploadedFiles,body}, (error) =>
      return response.sendError(error) if error?
      response.sendStatus 201

  sendMessageByName: (request, response) =>
    {triggerName} = request.params
    {type} = request.query
    {body} = request

    debug 'sendMessageByName', request.header('Content-Type'), request.body

    triggersService = new TriggersService {meshbluConfig: request.meshbluAuth}

    uploadedFiles = @_handleFiles request

    triggersService.sendMessageByName {triggerName,uploadedFiles,body,type}, (error) =>
      return response.sendError(error) if error?
      response.status(201).send triggered: true

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
