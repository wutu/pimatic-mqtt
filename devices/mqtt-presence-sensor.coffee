module.exports = (env) ->

  Promise = env.require 'bluebird'

  class MqttPresenceSensor extends env.devices.PresenceSensor

    constructor: (@config, @plugin, lastState) ->
      @id = config.id
      @name = config.name
      @_presence = lastState?.presence?.value or false

      if @plugin.connected
        @onConnect()

      @plugin.mqttclient.on('connect', =>
        @onConnect()
      )

      @plugin.mqttclient.on('message', (topic, message) =>
        if config.topic == topic
          switch message.toString()
            when "on", "true", "1", "1.00"
              @_setPresence(yes)
            else
              @_setPresence(no)
        )
      super()

    onConnect: () ->
      @plugin.mqttclient.subscribe(@config.topic)

    getPresence: () -> Promise.resolve(@_presence)