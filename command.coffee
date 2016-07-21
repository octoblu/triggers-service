_             = require 'lodash'
MeshbluConfig = require 'meshblu-config'
OctobluRaven  = require 'octoblu-raven'
Server        = require './src/server'

class Command
  constructor: ->
    @octobluRaven = new OctobluRaven
    @serverOptions =
      meshbluConfig:  new MeshbluConfig().toJSON()
      port:           process.env.PORT || 80
      disableLogging: process.env.DISABLE_LOGGING == "true"
      octobluRaven:   @octobluRaven

  panic: (error) =>
    console.error error.stack
    process.exit 1

  catchErrors: =>
    @octobluRaven.patchGlobal()

  run: =>
    # Use this to require env
    # @panic new Error('Missing required environment variable: ENV_NAME') if _.isEmpty @serverOptions.envName

    server = new Server @serverOptions
    server.run (error) =>
      return @panic error if error?

      {address,port} = server.address()
      console.log "Server listening on #{address}:#{port}"

    process.on 'SIGTERM', =>
      console.log 'SIGTERM caught, exiting'
      server.stop =>
        process.exit 0

command = new Command()
command.catchErrors()
command.run()
