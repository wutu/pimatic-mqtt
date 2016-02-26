module.exports = (env) ->

  Promise = env.require 'bluebird'

  class MqttDimmer extends env.devices.DimmerActuator
  
    constructor: (@config, @plugin, lastState) ->
      @name = config.name
      @id = config.id
      @_state = lastState?.state?.value or off
      @_dimlevel = lastState?.dimlevel?.value or 0
      @resolution = (@config.resolution - 1) or 101
      @stateTopic = @config.stateTopic or false

      if @plugin.connected
        @onConnect()

      @plugin.mqttclient.on('connect', =>
        @onConnect()
      )

      super()

    onConnect: () ->
      @plugin.mqttclient.subscribe(@config.topic)
      if @stateTopic
        @plugin.mqttclient.subscribe(@config.stateTopic)

    # Convert the PWM resolution by config value
    # Suppport for CIE correction will be added latter
    _getDevLevel: (perCentlevel) ->
      @devLevel = (perCentlevel * (@resolution / 100)).toFixed(0)
      return @devLevel

    # Convert device resolution value back to percent value
    _getPerCentlevel: (devlevel) ->
      @perCentlevel = ((devlevel + 0.5 * 100) / @resolution).toFixed(0)
      return @perCentlevel

    turnOn: ->
      if @stateTopic
        @plugin.mqttclient.publish(@stateTopic, @config.onMessage)
      Promise.resolve()
      
    turnOff: ->
      if @stateTopic
        @plugin.mqttclient.publish(@stateTopic, @config.offMessage)
      Promise.resolve()

    changeDimlevelTo: (dimlevel) ->
      @_getDevLevel(dimlevel)
      @plugin.mqttclient.publish(@config.topic, @devLevel)
      @_setDimlevel(dimlevel)
      return Promise.resolve()

    getDimlevel: -> Promise.resolve(@_dimlevel)