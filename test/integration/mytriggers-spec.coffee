http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
fakeFlow = require './fake-flow.json'

describe 'GET /mytriggers', ->
  beforeEach ->
    @meshblu = shmock 0xf00d

  afterEach (done) ->
    @meshblu.close => done()

  beforeEach (done) ->
    meshbluConfig =
      server: 'localhost'
      port: 0xf00d

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

  beforeEach (done) ->
    auth =
      username: 'ai-turns-hostile'
      password: 'team-token'

    options =
      auth: auth
      json: true

    @meshblu.get('/v2/whoami')
      .reply 200, uuid: 'ai-turns-hostile', token: 'team-token'

    @getHandler = @meshblu.get('/devices')
      .query(type:'octoblu:flow', owner:'ai-turns-hostile')
      .reply 200, devices: [fakeFlow]

    request.get "http://localhost:#{@serverPort}/mytriggers", options, (error, @response, @body) =>
      done error

  it 'should return the triggers', ->
    expect(@response.statusCode).to.equal 200
    expect(@getHandler.isDone).to.be.true
    expect(@body[0]).to.contain id: '562f4090-9ed8-11e5-bf39-09fc31cb0cf0'