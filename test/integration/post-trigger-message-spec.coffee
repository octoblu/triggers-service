http          = require 'http'
request       = require 'request'
shmock        = require 'shmock'
Server        = require '../../src/server'
fs            = require 'fs'
fakeFlow      = require './fake-flow.json'
enableDestroy = require 'server-destroy'

describe 'POST /flows/:flowId/triggers/:triggerId', ->
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

        request.post "http://localhost:#{@serverPort}/flows/foo/triggers/bar", options, (error, @response, @body) =>
          done error

      it 'should return the triggers', ->
        expect(@response.statusCode).to.equal 201

      it 'should post the message', ->
        @postHandler.done()

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


        message =
          devices: [ 'foo' ]
          topic: 'triggers-service'
          payload:
            from: 'bar'
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

        request.post "http://localhost:#{@serverPort}/flows/foo/triggers/bar", options, (error, @response, @body) =>
          done error

      it 'should return the triggers', ->
        expect(@response.statusCode).to.equal 201

      it 'should post the message', ->
        @postHandler.done()

      it 'should respond with the triggered: true', ->
        expect(@body).to.equal '{"triggered":true}'


  context 'when not authed', ->
    beforeEach (done) ->
      options =
        json: true

      @meshblu.post('/authenticate')
        .reply 200, uuid: 'ai-turns-hostile', token: 'team-token'

      @postHandler = @meshblu.post('/messages')
        .reply 201

      request.post "http://localhost:#{@serverPort}/flows/foo/triggers/bar", options, (error, @response, @body) =>
        done error

    it 'should return the triggers', ->
      expect(@response.statusCode).to.equal 201

    it 'should post the message', ->
      @postHandler.done()

    it 'should respond with the triggered: true', ->
      expect(@body.triggered).to.be.true
