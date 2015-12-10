http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
fakeFlow = require './fake-flow.json'

describe 'POST /flows/:flowId/triggers/:triggerId', ->
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

      request.post "http://localhost:#{@serverPort}/flows/foo/triggers/bar", options, (error, @response, @body) =>
        done error

    it 'should send a message', ->
      expect(@response.statusCode).to.equal 201
      expect(@postHandler.isDone).to.be.true

  context 'when not authed', ->
    beforeEach (done) ->
      options =
        json: true

      @meshblu.get('/v2/whoami')
        .reply 200, uuid: 'ai-turns-hostile', token: 'team-token'

      @postHandler = @meshblu.post('/messages')
        .reply 201

      request.post "http://localhost:#{@serverPort}/flows/foo/triggers/bar", options, (error, @response, @body) =>
        done error

    it 'should send a message', ->
      expect(@response.statusCode).to.equal 201
      expect(@postHandler.isDone).to.be.true
