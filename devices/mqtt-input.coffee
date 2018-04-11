module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'

  class MqttInput extends env.devices.InputDevice

    constructor: (@config, @plugin, lastState) ->
      assert(@plugin.brokers[@config.brokerId])

      @id = @config.id
      @name = @config.name

      @defaultValue = if @_inputType is "string" then "" else 0
      @input = lastState?.input?.value or @defaultValue

      @mqttclient = @plugin.brokers[@config.brokerId].client

      super(@config)

    getInput: () -> Promise.resolve(@input)

    _setInput: (value) ->
      unless @input is value
        @input = value
        @emit 'input', value

    changeInputTo: (value) ->
      if @config.type is "number"
        if isNaN(value)
          throw new Error("Input value is not a number")
        else
          @mqttclient.publish(@config.topic, value, { qos: @config.qos, retain: @config.retain })
          @_setInput(parseFloat(value))
      else
        @mqttclient.publish(@config.topic, value, { qos: @config.qos, retain: @config.retain })
        @_setInput value
      return Promise.resolve()

    destroy: ->
      super()
