module.exports = (env) ->

  Promise = env.require 'bluebird'

  class MqttPresenceSensor extends env.devices.PresenceSensor

    constructor: (@config, @plugin, lastState) ->
      @id = config.id
      @name = config.name
      @_presence = lastState?.presence?.value or false

      @plugin.mqttclient.on('connect', =>
        @plugin.mqttclient.subscribe(config.topic)
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

    getPresence: () -> Promise.resolve(@_presence)