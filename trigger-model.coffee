_ = require 'lodash'
request = require 'request'

class TriggerModel
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
      flowName: device.name
      id: trigger.id


module.exports = TriggerModel
