request = require 'request'

class TriggerModel
  constructor: () ->
    # use env variable for dev/prod urls
    @apiPrefix = 'http://0.0.0.0:3000'

  triggers: (bearerToken, callback) ->
    options =
      url: "#{@apiPrefix}/devices?type=octoblu:flow"
      'auth':
        'bearer': bearerToken

    request options, callback

module.exports = TriggerModel
