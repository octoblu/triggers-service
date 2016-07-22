http          = require 'http'
request       = require 'request'
shmock        = require 'shmock'
Server        = require '../../src/server'
fs            = require 'fs'
fakeFlow      = require './fake-flow.json'
enableDestroy = require 'server-destroy'

describe 'POST /flows/triggers/:triggerName', ->
  beforeEach (done) ->
    @meshblu = shmock done
    enableDestroy @meshblu

  afterEach (done) ->
    @meshblu.destroy done

  beforeEach (done) ->
    meshbluConfig =
      hostname: 'localhost'
      port: @meshblu.address().port
      protocol: 'http'
      uuid: 'trigger-service-uuid'
      token: 'trigger-service-token'

    serverOptions =
      port: undefined,
      disableLogging: true
      meshbluConfig: meshbluConfig

    @server = new Server serverOptions

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop => done()

  context 'when authed', ->
    context 'when posting json', ->
      beforeEach (done) ->
        auth =
          username: 'ai-turns-hostile'
          password: 'team-token'

        options =
          auth: auth
          json: true

        @meshblu.post('/authenticate')
          .reply 200, uuid: 'ai-turns-hostile', token: 'team-token'

        @postHandler = @meshblu.post('/messages')
          .reply 201

        @getHandler = @meshblu.get('/v2/devices')
          .query {
            type: 'octoblu:flow'
            owner: 'ai-turns-hostile'
            online: 'true'
            'flow.nodes':
              '$elemMatch':
                name: 'GOOYAH'
                type: 'operation:trigger'
          }
          .reply 200, [fakeFlow]

        request.post "http://localhost:#{@serverPort}/flows/triggers/GOOYAH", options, (error, @response, @body) =>
          done error

      it 'should return the triggers', ->
        expect(@response.statusCode).to.equal 201

      it 'should post the message', ->
        @postHandler.done()

      it 'should get the devices', ->
        @getHandler.done()

      it 'should respond with the triggered: true', ->
        expect(@body.triggered).to.be.true

    context 'when posting a multipart form', ->
      beforeEach (done) ->
        auth =
          username: 'ai-turns-hostile'
          password: 'team-token'

        formData =
          custom_file:
            value: new Buffer('{foo: bar}')
            options:
              filename: 'somefile',
              contentType: 'application/json'

        options =
          auth: auth
          formData: formData

        @meshblu.post('/authenticate')
          .reply 200, uuid: 'ai-turns-hostile', token: 'team-token'

        @getHandler = @meshblu.get('/v2/devices')
          .query {
            type: 'octoblu:flow'
            owner: 'ai-turns-hostile'
            online: 'true'
            'flow.nodes':
              '$elemMatch':
                name: 'GOOYAH'
                type: 'operation:trigger'
          }
          .reply 200, [fakeFlow]

        message =
          devices: [ '5c7cd421-8896-4073-92ee-2acd6e0171b5' ]
          topic: 'triggers-service'
          payload:
            from: '562f4090-9ed8-11e5-bf39-09fc31cb0cf0'
            params: {}
            payload: {}
            files:
              somefile:
                mimeType: 'application/json'
                data: '{foo: bar}'
                fieldName: 'custom_file'
                originalName: 'somefile'
                encoding: '7bit'
                size: 10

        @postHandler = @meshblu.post('/messages')
          .send message
          .reply 201

        request.post "http://localhost:#{@serverPort}/flows/triggers/GOOYAH", options, (error, @response, @body) =>
          done error

      it 'should return the triggers', ->
        expect(@response.statusCode).to.equal 201

      it 'should post the message', ->
        @postHandler.done()

      it 'should get the devices', ->
        @getHandler.done()

      it 'should respond with the triggered: true', ->
        expect(@body).to.equal '{"triggered":true}'

  context 'when not authed', ->
    beforeEach (done) ->
      options =
        json: true

      @meshblu.post('/authenticate')
        .reply 200, uuid: 'ai-turns-hostile', token: 'team-token'

      request.post "http://localhost:#{@serverPort}/flows/triggers/GOOYAH", options, (error, @response, @body) =>
        done error

    it 'should return should a 401', ->
      expect(@response.statusCode).to.equal 401
