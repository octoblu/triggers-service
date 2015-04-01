TriggerController = require '../trigger-controller'

describe 'TriggerController', ->
  beforeEach ->
    @sut = new TriggerController()

  describe 'constructor', ->
    it 'should exist', ->
      expect(@sut).to.exist

  describe '->getTriggers', ->
    it 'should exist', ->
      expect(@sut.getTriggers).to.exist

  describe '->trigger', ->
    it 'should exist', ->
      expect(@sut.trigger).to.exist

