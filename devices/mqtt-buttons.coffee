module.exports = (env) ->

  Promise = env.require 'bluebird'

  class MqttButtons extends env.devices.ButtonsDevice

    constructor: (@config, @plugin) ->
      @name = @config.name
      @id = @config.id

      if @plugin.connected
        @onConnect()

      @plugin.mqttclient.on('connect', =>
        @onConnect()
      )

      for b in @config.buttons
        if b.stateTopic
          @plugin.mqttclient.on 'message', (topic, message) =>
            if b.stateTopic == topic
              payload = message.toString()
            if payload == b.message
              @emit 'button', b.id

      super(@config)


    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          @emit 'button', b.id
          @plugin.mqttclient.publish(b.topic, b.message, { qos: b.qos or 0 })
          return Promise.resolve()


    onConnect: () ->
      for b in @config.buttons
        if b.stateTopic
          @plugin.mqttclient.subscribe(b.stateTopic, { qos: b.qos or 0 })

    destroy: () ->
      for b in @config.buttons
        if b.stateTopic
          @plugin.mqttclient.unsubscribe(b.stateTopic)
      super()
