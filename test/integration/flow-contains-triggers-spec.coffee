_             = require 'lodash'
http          = require 'http'
request       = require 'request'
shmock        = require 'shmock'
Server        = require '../../src/server'
fakeFlow      = require './fake-flow.json'
enableDestroy = require 'server-destroy'

describe 'GET /all-triggers?flowContains=device:generic', ->
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

  beforeEach ->
    auth =
      username: 'ai-turns-hostile'
      password: 'team-token'

    @options =
      auth: auth
      json: true

    @meshblu.post('/authenticate')
      .reply 200, uuid: 'ai-turns-hostile', token: 'team-token'

    @getHandler = @meshblu.get('/v2/devices')
      .query(type:'octoblu:flow', online: 'true')
      .reply 200, [fakeFlow]

  context 'when the device does not exist', ->
    beforeEach (done) ->
      request.get "http://localhost:#{@serverPort}/all-triggers?flowContains=device:no-way", @options, (error, @response, @body) =>
        done error

    it 'should not return triggers', ->
      expect(@response.statusCode).to.equal 200
      expect(@getHandler.isDone).to.be.true
      expect(@body).to.deep.equal []

  context 'when the device exists', ->
    beforeEach (done) ->
      request.get "http://localhost:#{@serverPort}/all-triggers?flowContains=device:generic", @options, (error, @response, @body) =>
        done error

    it 'should return triggers', ->
      expect(@response.statusCode).to.equal 200
      expect(@getHandler.isDone).to.be.true
      expect(@body).not.to.deep.equal []

  context 'when multiple device exists', ->
    beforeEach (done) ->
      request.get "http://localhost:#{@serverPort}/all-triggers?flowContains=device:generic&flowContains=device:twitter", @options, (error, @response, @body) =>
        done error

    it 'should return triggers', ->
      expect(@response.statusCode).to.equal 200
      expect(@getHandler.isDone).to.be.true
      expect(@body).not.to.deep.equal []
