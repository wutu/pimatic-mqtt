module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  match = require 'mqtt-wildcard'
  flatten = require 'flat'

  class MqttButtons extends env.devices.ButtonsDevice

    constructor: (@config, @plugin, lastState) ->
      assert(@plugin.brokers[@config.brokerId])

      @name = @config.name
      @id = @config.id
      super(@config)

      @_lastPressedButton = lastState?.button?.value or null
      @mqttclient = @plugin.brokers[@config.brokerId].client

      if @mqttclient.connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      triggerState = (button, value) =>
        if value == button.message
          @_lastPressedButton = button.id
          @emit 'button', button.id

      @mqttclient.on 'message', (topic, message) =>
        for b in @config.buttons
          if match(topic, b.stateTopic)?
            try data = JSON.parse(message.toString()) if b.stateValueKey?
            if typeof data is 'object' and Object.keys(data).length != 0
              for key, data of flatten(data)
                if key == b.stateValueKey
                  triggerState(b, "#{data}")
                  found = true
              if not found
                env.logger.debug "{@name} with id:#{@id}: State topic payload does not contain the given key #{b.stateValueKey}"
            else
              triggerState(b, message.toString())




    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          @_lastPressedButton = buttonId
          @emit 'button', b.id
          @mqttclient.publish(b.topic, b.message, { qos: b.qos or 0 })
          return Promise.resolve()
      Promise.reject(new Error("No button with the id #{buttonId} found"))


    onConnect: () ->
      for b in @config.buttons
        if b.stateTopic
          @mqttclient.subscribe(b.stateTopic, { qos: b.qos or 0 })

    destroy: () ->
      for b in @config.buttons
        if b.stateTopic
          @mqttclient.unsubscribe(b.stateTopic)
      super()
