_             = require 'lodash'
MeshbluHttp   = require 'meshblu-http'
TriggerParser = require '../helpers/trigger-parser'
debug         = require('debug')('triggers-service:triggers-service')
randomstring  = require 'randomstring'

class TriggersService
  constructor: ({@meshbluConfig}) ->

  getTriggerByNames: ({name, type}, callback) =>
    type ?= 'operation:trigger'
    meshbluHttp = new MeshbluHttp @meshbluConfig
    query =
      type: 'octoblu:flow'
      online: true
      owner: @meshbluConfig.uuid
      'flow.nodes':
        '$elemMatch':
          name: name
          type: type
    meshbluHttp.devices query, (error, devices) =>
      return callback error if error?

      triggers = TriggerParser.parseTriggersFromDevices {devices, type}
      callback null, triggers

  allTriggers: ({type}, callback) =>
    meshbluHttp = new MeshbluHttp @meshbluConfig
    meshbluHttp.devices type: 'octoblu:flow', online: true, (error, devices) =>
      return callback error if error?

      triggers = TriggerParser.parseTriggersFromDevices {devices, type}
      callback null, triggers

  myTriggers: ({type}, callback) =>
    meshbluHttp = new MeshbluHttp @meshbluConfig
    meshbluHttp.devices type: 'octoblu:flow', owner: @meshbluConfig.uuid, online: true, (error, devices) =>
      return callback error if error?

      triggers = TriggerParser.parseTriggersFromDevices {devices, type}
      callback null, triggers

  sendMessageById: ({flowId,triggerId,body,uploadedFiles,defaultPayload}, callback) =>
    meshbluHttp = new MeshbluHttp @meshbluConfig

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

    meshbluHttp.message message, (error, body) =>
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

module.exports = TriggersService
