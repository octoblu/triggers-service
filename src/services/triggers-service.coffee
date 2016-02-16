_             = require 'lodash'
MeshbluHttp   = require 'meshblu-http'
TriggerParser = require '../helpers/trigger-parser'
debug         = require('debug')('triggers-service:triggers-service')
randomstring  = require 'randomstring'

class TriggersService
  constructor: ({@meshbluConfig}) ->

  allTriggers: (callback) =>
    meshbluHttp = new MeshbluHttp @meshbluConfig
    meshbluHttp.devices type: 'octoblu:flow', (error, body) =>
      return callback @_createError 401, error.message if error?.message == 'unauthorized'
      return callback @_createError 500, error.message if error?

      triggers = TriggerParser.parseTriggersFromDevices body.devices
      callback null, triggers

  myTriggers: (callback) =>
    meshbluHttp = new MeshbluHttp @meshbluConfig
    meshbluHttp.devices type: 'octoblu:flow', owner: @meshbluConfig.uuid, (error, body) =>
      return callback @_createError 401, error.message if error?.message == 'unauthorized'
      return callback @_createError 500, error.message if error?

      triggers = TriggerParser.parseTriggersFromDevices body.devices
      callback null, triggers

  sendMessageById: ({flowId,triggerId,body,uploadedFiles}, callback) =>
    meshbluHttp = new MeshbluHttp @meshbluConfig

    message =
      devices: [flowId]
      topic: 'triggers-service'
      payload:
        from: triggerId
        params: body
        payload: body
        files: uploadedFiles

    meshbluHttp.message message, (error, body) =>
      return callback @_createError 401, error.message if error?.message == 'unauthorized'
      return callback @_createError 500, error.message if error?
      return callback null

  sendMessageByName: ({triggerName,body,uploadedFiles}, callback) =>
    @myTriggers (error, triggers) =>
      return callback error if error?
      trigger = _.find triggers, name: triggerName
      return callback @_createError 404, 'No Trigger by that name' unless trigger?

      meshbluHttp = new MeshbluHttp @meshbluConfig
      {flowId, id} = trigger

      message =
        devices: [flowId]
        topic: 'triggers-service'
        payload:
          from: id
          params: body
          payload: body
          files: uploadedFiles

      meshbluHttp.message message, (error, body) =>
        return callback @_createError 401, error.message if error?.message == 'unauthorized'
        return callback @_createError 500, error.message if error?
        return callback null

  _createError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = TriggersService
