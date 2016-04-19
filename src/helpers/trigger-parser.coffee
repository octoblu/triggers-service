_ = require 'lodash'

class TriggerParser
  @parseTriggersFromDevices: ({devices,type,flowContains}) =>
    triggers = []
    flowContains = [flowContains] unless _.isArray flowContains
    flowContains = _.compact flowContains

    return triggers unless devices?

    _.each devices, (device) =>
      triggers = _.union triggers, TriggerParser.collectTriggersFromDevice({device,type,flowContains})

    triggers

  @collectTriggersFromDevice: ({device, type, flowContains}) =>
    type ?= 'operation:trigger'
    triggersInFlow = _.where device.flow?.nodes, {type}
    unless _.isEmpty flowContains
      return [] unless _.every flowContains, (nodeType) =>
        _.find(device.flow?.nodes, type: nodeType)?

    _.map triggersInFlow, (trigger) =>
      data =
        name:     trigger.name
        flowId:   device.uuid
        flowName: device.name ? ''
        id:       trigger.id
        online:   device.online
        uri:      "https://triggers.octoblu.com/flows/#{device.uuid}/triggers/#{trigger.id}"

module.exports = TriggerParser
