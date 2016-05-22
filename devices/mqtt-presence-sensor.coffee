module.exports = (env) ->

  Promise = env.require 'bluebird'

  class MqttPresenceSensor extends env.devices.PresenceSensor

    constructor: (@config, @plugin, lastState) ->
      @id = @config.id
      @name = @config.name
      @_presence = lastState?.presence?.value or false

      if @plugin.connected
        @onConnect()

      @plugin.mqttclient.on('connect', =>
        @onConnect()
      )

      @plugin.mqttclient.on('message', (topic, message) =>
        if @config.topic == topic
          switch message.toString()
            when @config.onMessage
               @_setPresence(yes)
            when @config.offMessage
               @_setPresence(no)
            else
              env.logger.debug "#{@name} with id:#{@id}: Message is not harmony with onMessage or offMessage in config.json or with default values"
        )
      super()

    onConnect: () ->
      @plugin.mqttclient.subscribe(@config.topic, { qos: @config.qos })

    getPresence: () -> Promise.resolve(@_presence)

    destroy: () ->
     @plugin.mqttclient.unsubscribe(@config.topic)
     super()
