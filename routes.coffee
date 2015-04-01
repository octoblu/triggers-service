express = require 'express'
request = require 'request'
router  = express.Router()

TriggerController = require './trigger-controller'
triggerController = new TriggerController()

router.get '/', (req, res) ->
  res.send 'Trigger Service. I am Groot!!!'

router.get '/triggers', triggerController.getTriggers

module.exports = router
