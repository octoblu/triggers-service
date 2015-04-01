_ = require 'lodash'
request = require 'request'

class TriggerModel
  constructor: () ->
    # use env variable for dev/prod urls
    @apiPrefix = 'http://0.0.0.0:3000'

  trigger: (flowId, triggerId, bearerToken, callback=->) =>
    options =
      json:
        devices: [flowId]
        topic: 'button'
        payload:
          from: triggerId
      auth:
        bearer: bearerToken

    request.post "#{@apiPrefix}/messages", options, (error, response, body) =>
      return callback error if error?
      return callback new Error(body.error) if body?.error?

      callback null, body

  getTriggers: (bearerToken, callback=->) =>
    options =
      url: "#{@apiPrefix}/devices?type=octoblu:flow"
      'auth':
        'bearer': bearerToken

    request options, (error, response, body) =>
      return callback(error, null) if error
      return callback(null, response) unless response.statusCode == 200

      triggers = @parseTriggersFromDevices JSON.parse(body).devices
      callback null, triggers

  parseTriggersFromDevices: (devices) =>
    triggers = []

    return triggers unless devices?

    _.each devices, (device) =>
      triggers = _.union triggers, @collectTriggersFromDevice(device)

    triggers

  collectTriggersFromDevice: (device) =>
    triggersInFlow = _.where device.flow, { type: 'trigger' }

    _.map triggersInFlow, (trigger) =>
      name: trigger.name
      flow: device.uuid
      id: trigger.id


module.exports = TriggerModel
