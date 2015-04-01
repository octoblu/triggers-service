request = require 'request'
_       = require 'lodash'

class Meshblu
  constructor: (options={}) ->
    options = _.defaults(options, port: 443, protocol: 'https', server: 'meshblu.octoblu.com')
    {@uuid, @token, @server, @port, @protocol} = options
    @urlBase = "#{@protocol}://#{@server}:#{@port}"

  device: (deviceUuid, callback=->) =>
    options = json: true
    if @uuid && @token
      options.auth =
        user: @uuid
        pass: @token

    request.get "#{@urlBase}/v2/devices/#{deviceUuid}", options, (error, response, body) =>
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?

      callback null, body

  #TODO: Implement trigger() & devices()

  generateAndStoreToken: (deviceUuid, callback=->) =>
    options = json: true
    if @uuid && @token
      options.auth =
        user: @uuid
        pass: @token

    request.post "#{@urlBase}/devices/#{deviceUuid}/tokens", options, (error, response, body) =>
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?

      callback null, body

  revokeToken: (deviceUuid, deviceToken, callback=->) =>
    options = json: true
    if @uuid && @token
      options.auth =
        user: @uuid
        pass: @token

    request.del "#{@urlBase}/devices/#{deviceUuid}/tokens/#{deviceToken}", options, (error, response, body) =>
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?

      callback null

module.exports = Meshblu
