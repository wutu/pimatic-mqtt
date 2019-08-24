module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  match = require 'mqtt-wildcard'
  flatten = require 'flat'

  class MqttPresenceSensor extends env.devices.PresenceSensor

    constructor: (@config, @plugin, lastState) ->
      assert(@plugin.brokers[@config.brokerId])

      @id = @config.id
      @name = @config.name
      super()

      @_presence = lastState?.presence?.value or false
      @mqttclient = @plugin.brokers[@config.brokerId].client

      if @mqttclient.connected
        @onConnect()

      if @config.autoReset and @_presence
        @_resetPresenceTimeout = setTimeout(@resetPresence, @config.resetTime)

      @mqttclient.on('connect', =>
        @onConnect()
      )

      triggerState = (value) =>
        switch value
          when @config.onMessage
            @_setPresence(yes)
          when @config.offMessage
            @_setPresence(no)
          else
            env.logger.debug "#{@name} with id:#{@id}: Message is not in harmony with onMessage or offMessage in config.json or with default values"

      @mqttclient.on('message', (topic, message) =>
        if match(topic, @config.topic)?
          if @_resetPresenceTimeout?
            clearTimeout(@_resetPresenceTimeout)
            @_resetPresenceTimeout = null

          try data = JSON.parse(message) if @config.stateValueKey?
          if typeof data is 'object' and Object.keys(data).length != 0
            flat = flatten(data)
            for key, data of flat
              if key == @config.stateValueKey
                triggerState("#{data}")
                found = true
            if not found
              env.logger.debug "{@name} with id:#{@id}: State topic payload does not contain the given key #{@config.stateValueKey}"
          else
            triggerState(message.toString())

          if @config.autoReset and @_presence
            @_resetPresenceTimeout = setTimeout(@resetPresence, @config.resetTime)
        )

    onConnect: () ->
      @mqttclient.subscribe(@config.topic, { qos: @config.qos })

    getPresence: () -> Promise.resolve(@_presence)

    resetPresence: () =>
      @_setPresence(no)

    destroy: () ->
     @mqttclient.unsubscribe(@config.topic)
     super()
