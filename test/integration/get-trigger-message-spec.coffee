http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
fakeFlow = require './fake-flow.json'

describe 'GET /flows/:flowId/triggers/:triggerId', ->
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
    options =
      json: true

    request.get "http://localhost:#{@serverPort}/flows/test/triggers/foo", options, (error, @response, @body) =>
      done error

  it 'should return the triggers', ->
    expect(@response.statusCode).to.equal 405
