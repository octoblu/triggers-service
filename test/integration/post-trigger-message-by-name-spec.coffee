http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
fs = require 'fs'
fakeFlow = require './fake-flow.json'

describe 'POST /flows/triggers/:triggerName', ->
  beforeEach ->
    @meshblu = shmock 0xf00d

  afterEach (done) ->
    @meshblu.close => done()

  beforeEach (done) ->
    meshbluConfig =
      server: 'localhost'
      port: 0xf00d
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

        @meshblu.get('/v2/whoami')
          .reply 200, uuid: 'ai-turns-hostile', token: 'team-token'

        @postHandler = @meshblu.post('/messages')
          .reply 201

        @getHandler = @meshblu.get('/devices')
          .query {
            type: 'octoblu:flow'
            owner: 'ai-turns-hostile'
            'flow.nodes':
              '$elemMatch':
                name: 'GOOYAH'
                type: 'operation:trigger'
          }
          .reply 200, devices: [fakeFlow]

        request.post "http://localhost:#{@serverPort}/flows/triggers/GOOYAH", options, (error, @response, @body) =>
          done error

      it 'should return the triggers', ->
        expect(@response.statusCode).to.equal 201

      it 'should post the message', ->
        @postHandler.done()

      it 'should get the devices', ->
        @getHandler.done()

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

        @meshblu.get('/v2/whoami')
          .reply 200, uuid: 'ai-turns-hostile', token: 'team-token'

        @getHandler = @meshblu.get('/devices')
          .query {
            type: 'octoblu:flow'
            owner: 'ai-turns-hostile'
            'flow.nodes':
              '$elemMatch':
                name: 'GOOYAH'
                type: 'operation:trigger'
          }
          .reply 200, devices: [fakeFlow]

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

  context 'when not authed', ->
    beforeEach (done) ->
      options =
        json: true

      @meshblu.get('/v2/whoami')
        .reply 200, uuid: 'ai-turns-hostile', token: 'team-token'

      request.post "http://localhost:#{@serverPort}/flows/triggers/GOOYAH", options, (error, @response, @body) =>
        done error

    it 'should return should a 401', ->
      expect(@response.statusCode).to.equal 401
