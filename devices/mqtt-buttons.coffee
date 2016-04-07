module.exports = (env) ->

  Promise = env.require 'bluebird'

  class MqttButtons extends env.devices.ButtonsDevice

    constructor: (@config, @plugin) ->
      @name = @config.name
      @id = @config.id
      super(@config)

      if @plugin.connected
        @onConnect()

      @plugin.mqttclient.on('connect', =>
        @onConnect()
      )

      @plugin.mqttclient.on 'message', (topic, message) =>
        for b in @config.buttons
          if b.topic == topic
            payload = message.toString()
          if payload == b.message
            @emit 'button', b.id


    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          @emit 'button', b.id
          @plugin.mqttclient.publish(b.topic, b.message)
          return


    onConnect: () ->
      for b in @config.buttons
        @plugin.mqttclient.subscribe(b.topic)
