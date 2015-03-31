express = require 'express'
router  = express.Router()

router.get '/', (req, res) ->
  res.send 'Hello World!'

router.get '/status', (req, res) ->
  res.send status: 'online'

module.exports = router
