module.exports = (env) ->

  Promise = env.require 'bluebird'

  class MqttButtons extends env.devices.ButtonsDevice

    constructor: (@config, @plugin) ->
      @name = config.name
      @id = config.id
      super(@config)

    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          @emit 'button', b.id
          @plugin.mqttclient.publish(b.topic, b.message)
          return
