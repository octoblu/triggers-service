_             = require 'lodash'
MeshbluHttp   = require 'meshblu-http'
TriggerParser = require '../helpers/trigger-parser'
debug         = require('debug')('triggers-service:triggers-service')
randomstring  = require 'randomstring'

class TriggersService
  constructor: ({@meshbluConfig}) ->
    @meshbluHttp = new MeshbluHttp @meshbluConfig

  getTriggerByNames: ({name, type}, callback) =>
    type ?= 'operation:trigger'
    query =
      type: 'octoblu:flow'
      online: true
      owner: @meshbluConfig.uuid
      'flow.nodes':
        '$elemMatch':
          name: name
          type: type

    @_queryAndParse {query, type}, callback

  allTriggers: ({type, flowContains}, callback) =>
    query =
      type: 'octoblu:flow'
      online: true

    @_queryAndParse {query, type, flowContains}, callback

  myTriggers: ({type, flowContains}, callback) =>
    query =
      type: 'octoblu:flow'
      owner: @meshbluConfig.uuid
      online: true

    @_queryAndParse {query, type, flowContains}, callback

  sendMessageById: ({flowId,triggerId,body,uploadedFiles,defaultPayload}, callback) =>
    payloadOptions =
      from: triggerId
      params: body
      payload: body
      files: uploadedFiles

    payload = _.extend {}, defaultPayload, payloadOptions

    message =
      devices: [flowId]
      topic: 'triggers-service'
      payload: payload

    @meshbluHttp.message message, (error, body) =>
      return callback error if error?
      return callback null

  sendMessageByIdV2: ({flowId,triggerId,body,uploadedFiles,defaultPayload}, callback) =>
    message =
      metadata:
        createdAt: Date.now()
        to:
          nodeId: triggerId
      files: uploadedFiles
      devices: [flowId]
      data: body

    @meshbluHttp.message message, (error, body) =>
      return callback error if error?
      return callback null

  sendMessageByName: ({triggerName,body,uploadedFiles,defaultPayload,type}, callback) =>
    @getTriggerByNames {name: triggerName, type: type}, (error, triggers) =>
      return callback error if error?
      trigger = _.find triggers, name: triggerName
      unless trigger?
        error = new Error 'No Trigger by that name'
        error.code = 404
        return callback error

      {id,flowId} = trigger
      @sendMessageById {flowId,triggerId:id,body,uploadedFiles,defaultPayload}, callback

  _queryAndParse: ({query, type, flowContains}, callback) =>
    @meshbluHttp.devices query, (error, devices) =>
      return callback error if error?

      triggers = TriggerParser.parseTriggersFromDevices {devices, type, flowContains}
      callback null, triggers

module.exports = TriggersService
