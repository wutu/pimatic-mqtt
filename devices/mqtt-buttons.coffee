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
          if b.stateTopic == topic
            payload = message.toString()
          if payload == b.message
            @emit 'button', b.id


    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          @emit 'button', b.id
          @plugin.mqttclient.publish(b.topic, b.message, { qos: @config.qos, retain: @config.retain })
          return


    onConnect: () ->
      for b in @config.buttons
        if not b.retain
          @plugin.mqttclient.publish(b.topic, null)
        if @stateTopic
          @plugin.mqttclient.subscribe(b.stateTopic, { qos: @config.qos })

    destroy: () ->
      for b in @config.buttons
        if b.stateTopic
          @plugin.mqttclient.unsubscribe(b.stateTopic)
      super()
