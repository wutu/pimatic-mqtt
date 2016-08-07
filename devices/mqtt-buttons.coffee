module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'

  class MqttButtons extends env.devices.ButtonsDevice

    constructor: (@config, @plugin) ->
      assert(@plugin.brokers[@config.brokerId])

      @name = @config.name
      @id = @config.id
      @mqttclient = @plugin.brokers[@config.brokerId].client

      if @plugin.brokers[@config.brokerId].connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      for b in @config.buttons
        if b.stateTopic
          @mqttclient.on 'message', (topic, message) =>
            if b.stateTopic == topic
              payload = message.toString()
            if payload == b.message
              @emit 'button', b.id

      super(@config)


    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          @emit 'button', b.id
          @mqttclient.publish(b.topic, b.message, { qos: b.qos or 0 })
          return


    onConnect: () ->
      for b in @config.buttons
        if b.stateTopic
          @mqttclient.subscribe(b.stateTopic, { qos: b.qos or 0 })

    destroy: () ->
      for b in @config.buttons
        if b.stateTopic
          @mqttclient.unsubscribe(b.stateTopic)
      super()
