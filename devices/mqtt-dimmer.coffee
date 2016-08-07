module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'

  class MqttDimmer extends env.devices.DimmerActuator

    constructor: (@config, @plugin, lastState) ->
      assert(@plugin.brokers[@config.brokerId])

      @name = @config.name
      @id = @config.id
      @_state = lastState?.state?.value or off
      @_dimlevel = lastState?.dimlevel?.value or 0
      @resolution = (@config.resolution - 1) or 255
      @mqttclient = @plugin.brokers[@config.brokerId].client

      if @plugin.brokers[@config.brokerId].connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      if @config.stateTopic
        @mqttclient.on 'message', (topic, message) =>
          if @config.stateTopic == topic
            payload = message.toString()
            @getPerCentlevel(payload)
            if @perCentlevel != @_dimlevel && @perCentlevel <= 100
              @_setDimlevel(@perCentlevel)
              @emit @dimlevel, @perCentlevel

      super()

    onConnect: () ->
      if @config.stateTopic
        @mqttclient.subscribe(@config.stateTopic, { qos: @config.qos })


    # Convert the PWM resolution by config value
    # Suppport for CIE correction will be added latter
    getDevLevel: (perCentlevel) ->
      @devLevel = (perCentlevel * (@resolution / 100)).toFixed(0)
      return @devLevel

    # Convert device resolution value back to percent value
    getPerCentlevel: (devlevel) ->
      perCentlevel = ((devlevel + 0.5 * 100) / @resolution).toFixed(0)
      @perCentlevel = parseInt(perCentlevel, 10)
      return @perCentlevel

    turnOn: ->
      @getDevLevel(100)
      @mqttclient.publish(@config.topic, @devLevel, { qos: @config.qos, retain: @config.retain })
      return Promise.resolve()

    turnOff: ->
      @mqttclient.publish(@config.topic, 0, { qos: @config.qos, retain: @config.retain })
      return Promise.resolve()

    changeDimlevelTo: (dimlevel) ->
      @getDevLevel(dimlevel)
      @mqttclient.publish(@config.topic, @devLevel, { qos: @config.qos, retain: @config.retain })
      @_setDimlevel(dimlevel)
      return Promise.resolve()

    getDimlevel: -> Promise.resolve(@_dimlevel)

    destroy: () ->
     if @config.stateTopic
       @mqttclient.unsubscribe(@config.stateTopic)
     super()
