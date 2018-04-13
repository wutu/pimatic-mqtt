module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'

  class MqttPresenceSensor extends env.devices.PresenceSensor

    constructor: (@config, @plugin, lastState) ->
      assert(@plugin.brokers[@config.brokerId])

      @id = @config.id
      @name = @config.name
      @_presence = lastState?.presence?.value or false
      @mqttclient = @plugin.brokers[@config.brokerId].client

      if @mqttclient.connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      resetPresence = ( =>
        @_setPresence(no)
      )

      @mqttclient.on('message', (topic, message) =>
        if @config.topic == topic
          clearTimeout(@_resetPresenceTimeout)
          if @config.autoReset is true
            @_resetPresenceTimeout = setTimeout(resetPresence, @config.resetTime)
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
      @mqttclient.subscribe(@config.topic, { qos: @config.qos })

    getPresence: () -> Promise.resolve(@_presence)

    destroy: () ->
     @mqttclient.unsubscribe(@config.topic)
     super()
