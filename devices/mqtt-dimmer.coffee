module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  match = require 'mqtt-wildcard'

  class MqttDimmer extends env.devices.DimmerActuator

    constructor: (@config, @plugin, lastState) ->
      assert(@plugin.brokers[@config.brokerId])

      @name = @config.name
      @id = @config.id
      @message = @config.message
      @_state = lastState?.state?.value or off
      @_dimlevel = lastState?.dimlevel?.value or 0
      @_lastdimlevel = lastState?.lastdimlevel?.value or 100
      @resolution = (@config.resolution - 1) or 255
      @mqttclient = @plugin.brokers[@config.brokerId].client

      if @mqttclient.connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      if @config.stateTopic
        @mqttclient.on 'message', (topic, message) =>
          if match(topic, @config.stateTopic)?
            payload = parseInt(message.toString(), 10);
            @getPerCentlevel(payload)
            if @perCentlevel != @_dimlevel
              if @perCentlevel <= 100
                @_setDimlevel(@perCentlevel)
                @_lastdimlevel = @perCentlevel
                @emit @dimlevel, @perCentlevel
              else
                env.logger.error ("value: #{@perCentlevel} is out of range")

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
      perCentlevel = Math.ceil(((devlevel * 100) / @resolution))
      @perCentlevel = parseInt(perCentlevel, 10)
      return @perCentlevel

    turnOn: ->
      @getDevLevel(@_lastdimlevel)
      @mqttclient.publish(@config.topic, @devLevel, { qos: @config.qos, retain: @config.retain })
      @_setDimlevel(@_lastdimlevel)
      return Promise.resolve()

    turnOff: ->
      @mqttclient.publish(@config.topic, "0", { qos: @config.qos, retain: @config.retain })
      @_setDimlevel(0)
      return Promise.resolve()

    changeDimlevelTo: (dimlevel) ->
      if @_dimlevel is dimlevel then return Promise.resolve true
      @getDevLevel(dimlevel)
      @payload = @message.replace("value", "#{@devLevel}")
      @mqttclient.publish(@config.topic, @payload, { qos: @config.qos, retain: @config.retain })
      @_lastdimlevel = dimlevel
      @_setDimlevel(dimlevel)
      return Promise.resolve()

    # getDimlevel: -> Promise.resolve(@_dimlevel)

    destroy: () ->
     if @config.stateTopic
       @mqttclient.unsubscribe(@config.stateTopic)
     super()
