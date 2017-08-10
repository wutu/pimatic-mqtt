module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'

  class MqttShutter extends env.devices.ShutterController

    constructor: (@config, @plugin, LastState) ->
      assert(@plugin.brokers[@config.brokerId])

      @name = @config.name
      @id = @config.id
      @rollingTime = @config.rollingTime
      @_position = lastState?.position?.value or 'stopped'
      @mqttclient = @plugin.brokers[@config.brokerId].client

      super()

    moveToPosition: (position) ->
      if position is 'up' then payload = @config.upMessage else payload = @config.downMessage
      @mqttclient.publish(@config.topic, payload, { qos: @config.qos, retain: @config.retain })
      @_setPosition(position)
      return Promise.resolve()

    stop: ->
      @mqttclient.publish(@config.topic, @config.stopMessage, { qos: @config.qos, retain: @config.retain })
      @_setPosition('stopped')
      return Promise.resolve()

    destroy: () ->
      if @config.stateTopic
        @mqttclient.unsubscribe(@config.stateTopic)
      super()
