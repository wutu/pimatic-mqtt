module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  match = require 'mqtt-wildcard'

  class MqttSwitch extends env.devices.PowerSwitch

    constructor: (@config, @plugin, lastState) ->
      assert(@plugin.brokers[@config.brokerId])

      @name = @config.name
      @id = @config.id
      @_state = lastState?.state?.value or off
      @mqttclient = @plugin.brokers[@config.brokerId].client

      if @mqttclient.connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      if @config.stateTopic
        @mqttclient.on('message', (topic, message) =>
          if match(topic, @config.stateTopic)?
            switch message.toString()
              when @config.onMessage
                @_setState(on)
                @_state = on
                @emit "state", on
              when @config.offMessage
                @_setState(off)
                @_state = off
                @emit "state", off
              else
                env.logger.debug "#{@name} with id:#{@id}: Message is not harmony with onMessage or offMessage in config.json or with default values"
        )

      super()

    onConnect: () ->
      if @config.stateTopic
        @mqttclient.subscribe(@config.stateTopic, { qos: @config.qos })

    changeStateTo: (state) ->
      message = (if state then @config.onMessage else @config.offMessage)
      @mqttclient.publish(@config.topic, message, { qos: @config.qos, retain: @config.retain })
      @_setState(state)
      return Promise.resolve()

    destroy: () ->
      if @config.stateTopic
        @mqttclient.unsubscribe(@config.stateTopic)
      super()
