module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  match = require 'mqtt-wildcard'

  class MqttShutter extends env.devices.ShutterController

    constructor: (@config, @plugin, LastState) ->
      assert(@plugin.brokers[@config.brokerId])

      @name = @config.name
      @id = @config.id
      @_position = lastState?.position?.value or 'stopped'
      @mqttclient = @plugin.brokers[@config.brokerId].client

      if @mqttclient.connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      if @config.stateTopic
        @mqttclient.on 'message', (topic, message) =>
          if match(topic, @config.stateTopic)?
            switch message.toString()
              when @config.upMessage
                @_setPosition('up')
              when @config.downMessage
                @_setPosition('down')
              when @config.stopMessage
                @_setPosition('stopped')
              else
                env.logger.debug "#{@name} with id:#{@id} - Message is not in accordance with config."

      super()

    onConnect: () ->
      if @config.stateTopic
        @mqttclient.subscribe(@config.stateTopic, { qos: @config.qos })

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
