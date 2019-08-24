module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  match = require 'mqtt-wildcard'
  flatten = require 'flat'

  class MqttSwitch extends env.devices.PowerSwitch

    constructor: (@config, @plugin, lastState) ->
      assert(@plugin.brokers[@config.brokerId])

      @name = @config.name
      @id = @config.id
      super()

      @_state = lastState?.state?.value or off
      @mqttclient = @plugin.brokers[@config.brokerId].client

      if @mqttclient.connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      if @config.stateTopic
        triggerState = (value) =>
          switch value
            when @config.onMessage
              @_setState(on)
            when @config.offMessage
              @_setState(off)
            else
              env.logger.debug "#{@name} with id:#{@id}: Message is not harmony with onMessage or offMessage in config.json or with default values"

        @mqttclient.on('message', (topic, message) =>
          if match(topic, @config.stateTopic)?
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
        )

    onConnect: () ->
      if @config.stateTopic
        @mqttclient.subscribe(@config.stateTopic, { qos: @config.qos })

    changeStateTo: (state) ->
      message = (if state then @config.onMessage else @config.offMessage)
      @mqttclient.publish(@config.topic, message, { qos: @config.qos, retain: @config.retain })
      @_setState(state)
      return Promise.resolve()

    destroy: () ->
      if @config.stateTopic
        @mqttclient.unsubscribe(@config.stateTopic)
      super()
