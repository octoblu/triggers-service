_ = require 'lodash'

class TriggerParser
  @parseTriggersFromDevices: ({devices,type}) =>
    triggers = []

    return triggers unless devices?

    _.each devices, (device) =>
      triggers = _.union triggers, TriggerParser.collectTriggersFromDevice({device,type})

    triggers

  @collectTriggersFromDevice: ({device, type}) =>
    type ?= 'operation:trigger'
    triggersInFlow = _.where device.flow?.nodes, {type}

    _.map triggersInFlow, (trigger) =>
      name: trigger.name
      flowId: device.uuid
      flowName: device.name ? ''
      id: trigger.id
      uri: "https://triggers.octoblu.com/flows/#{device.uuid}/triggers/#{trigger.id}"


module.exports = TriggerParser
