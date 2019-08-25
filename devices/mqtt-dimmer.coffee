module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  match = require 'mqtt-wildcard'
  flatten = require 'flat'

  class MqttDimmer extends env.devices.DimmerActuator

    constructor: (@config, @plugin, lastState) ->
      assert(@plugin.brokers[@config.brokerId])

      @name = @config.name
      @id = @config.id
      super()

      @message = @config.message
      @_state = lastState?.state?.value or off
      @_dimlevel = lastState?.dimlevel?.value or 0
      @resolution = (@config.resolution - 1) or 255
      @mqttclient = @plugin.brokers[@config.brokerId].client

      if @mqttclient.connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      if @config.stateTopic
        triggerDimlevel = (value) =>
          payload = parseInt(value, 10);
          percentLevel = @getPercentLevel(payload)
          if percentLevel != @_dimlevel
            if percentLevel <= 100
              @_setDimlevel(percentLevel)
            else
              env.logger.error ("value: #{percentLevel} is out of range")

        @mqttclient.on 'message', (topic, message) =>
          if match(topic, @config.stateTopic)?
            try data = JSON.parse(message) if @config.stateValueKey?
            if typeof data is 'object' and Object.keys(data).length != 0
              for key, data of flatten(data)
                if key == @config.stateValueKey
                  triggerDimlevel("#{data}")
                  found = true
              if not found
                env.logger.debug "{@name} with id:#{@id}: State topic payload does not contain the given key #{@config.stateValueKey}"
            else
              triggerDimlevel(message.toString())

    onConnect: () ->
      if @config.stateTopic
        @mqttclient.subscribe(@config.stateTopic, { qos: @config.qos })


    # Convert the PWM resolution by config value
    # Support for CIE correction will be added latter
    getDevLevel: (percentLevel) ->
      return (percentLevel * (@resolution / 100)).toFixed(0)

    # Convert device resolution value back to percent value
    getPercentLevel: (devLevel) ->
      percentLevel = Math.ceil((devLevel * 100) / @resolution)
      return parseInt(percentLevel, 10)

    turnOn: ->
      level = @getDevLevel(100)
      @mqttclient.publish(@config.topic, level, { qos: @config.qos, retain: @config.retain })
      @_setDimlevel(100)
      return Promise.resolve()

    turnOff: ->
      @mqttclient.publish(@config.topic, "0", { qos: @config.qos, retain: @config.retain })
      @_setDimlevel(0)
      return Promise.resolve()

    changeDimlevelTo: (dimlevel) ->
      if @_dimlevel is dimlevel then return Promise.resolve true
      level = @getDevLevel(dimlevel)
      @payload = @message.replace("value", "#{level}")
      @mqttclient.publish(@config.topic, @payload, { qos: @config.qos, retain: @config.retain })
      @_setDimlevel(dimlevel)
      return Promise.resolve()

    # getDimlevel: -> Promise.resolve(@_dimlevel)

    destroy: () ->
     if @config.stateTopic
       @mqttclient.unsubscribe(@config.stateTopic)
     super()
