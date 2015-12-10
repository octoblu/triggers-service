http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
fakeFlow = require './fake-flow.json'

describe 'GET /mytriggers', ->
  beforeEach ->
    @meshblu = shmock 0xd00d

  afterEach (done) ->
    @meshblu.close => done()

  beforeEach (done) ->
    meshbluConfig =
      server: 'localhost'
      port: 0xd00d

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

    device =
      uuid: 'some-device-uuid'
      foo: 'bar'

    options =
      auth: auth
      json: device

    @meshblu.get('/v2/whoami')
      .reply(200, '{"uuid": "ai-turns-hostile"}')

    @getHandler = @meshblu.get('/devices?type=octoblu%3Aflow&owner=ai-turns-hostile')

    request.get "http://localhost:#{@serverPort}/mytriggers", options, (error, @response, @body) =>
      done error

  it 'should update the real device in meshblu', ->
    expect(@response.statusCode).to.equal 200
    expect(@getHandler.isDone).to.be.true
    expect(@body).to.contain id: ''
