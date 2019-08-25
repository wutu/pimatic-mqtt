module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  match = require 'mqtt-wildcard'
  flatten = require 'flat'

  class MqttContactSensor extends env.devices.ContactSensor

    constructor: (@config, @plugin, lastState) ->
      assert(@plugin.brokers[@config.brokerId])

      @id = @config.id
      @name = @config.name
      @_contact = lastState?.contact?.value or false
      @mqttclient = @plugin.brokers[@config.brokerId].client

      if @mqttclient.connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      triggerState = (value) =>
        switch value
          when @config.onMessage
            @_setContact(true)
          when @config.offMessage
            @_setContact(false)
          else
            env.logger.debug "#{@name} with id:#{@id}: Message is not in harmony with onMessage or offMessage in config.json or with default values"

      @mqttclient.on('message', (topic, message) =>
        if match(topic, @config.topic)?
          try data = JSON.parse(message) if @config.stateValueKey?
          if typeof data is 'object' and Object.keys(data).length != 0
            for key, data of flatten(data)
              if key == @config.stateValueKey
                triggerState("#{data}")
                found = true
            if not found
              env.logger.debug "{@name} with id:#{@id}: State topic payload does not contain the given key #{@config.stateValueKey}"
          else
            triggerState(message.toString())

      )

      super()

    onConnect: () ->
      @mqttclient.subscribe(@config.topic, { qos: @config.qos })

    getContact: () -> Promise.resolve(@_contact)

    destroy: () ->
      @mqttclient.unsubscribe(@config.topic)
      super()
