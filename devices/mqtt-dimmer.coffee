module.exports = (env) ->

  Promise = env.require 'bluebird'

  class MqttDimmer extends env.devices.DimmerActuator
  
    constructor: (@config, @plugin, lastState) ->
      @name = config.name
      @id = config.id
      @_state = lastState?.state?.value or off
      @_dimlevel = lastState?.dimlevel?.value or 0

      if @plugin.connected
        @onConnect()

      @plugin.mqttclient.on('connect', =>
        @onConnect()
      )

      @plugin.mqttclient.on('message', (topic, message) =>
        if config.topic == topic
          switch message.toString()
            when "on", "true"
              @_setState(on)
              @_state = on
              @emit @name, on
            else
              @_setState(off)
              @_state = off
              @emit @name, off
        )
      super()

    onConnect: () ->
      if @config.stateTopic == ""
        @plugin.mqttclient.subscribe(@config.topic)
      else
        @plugin.mqttclient.subscribe(@config.stateTopic)

    turnOn: ->
      @plugin.mqttclient.publish(@config.topic, @config.onMessage)
      Promise.resolve()
      
    turnOff: ->
      @plugin.mqttclient.publish(@config.topic, @config.offMessage)
      Promise.resolve()

    changeDimlevelTo: (dimlevel) ->
      level = (parseFloat(dimlevel) * 10)
      brightness = level.toString()
      @plugin.mqttclient.publish(@config.topic, brightness)
      @_setDimlevel(dimlevel)
      Promise.resolve()

    setdimlevel: (brightness) ->

    getDimlevel: -> Promise.resolve(@_dimlevel)