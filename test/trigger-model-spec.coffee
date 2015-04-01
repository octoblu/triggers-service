TriggerModel = require '../trigger-model'

describe 'TriggerModel', ->
  beforeEach ->
    @sut = new TriggerModel()

  describe 'constructor', ->
    it 'should exist', ->
      expect(@sut).to.exist

  describe 'triggers', ->
    it 'should exist', ->
      expect(@sut.triggers).to.exist
