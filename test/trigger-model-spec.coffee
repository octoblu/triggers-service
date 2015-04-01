TriggerModel = require '../trigger-model'

describe 'TriggerModel', ->
  beforeEach ->
    @sut = new TriggerModel()

  describe 'constructor', ->
    it 'should exist', ->
      expect(@sut).to.exist

  describe '->triggers', ->
    it 'should exist', ->
      expect(@sut.getTriggers).to.exist

    describe 'when called with bearerToken and callback', ->
      beforeEach ->
        @sut.getTriggers 'my-fancy-bearer', () ->
        return null


