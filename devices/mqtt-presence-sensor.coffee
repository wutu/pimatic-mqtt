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
      @_triggerAutoReset()

      if @mqttclient.connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      @mqttclient.on('message', (topic, message) =>
        if @config.topic == topic
          switch message.toString()
            when @config.onMessage
               @_setPresence(yes)
            when @config.offMessage
               @_setPresence(no)
            else
              env.logger.debug "#{@name} with id:#{@id}: Message is not harmony with onMessage or offMessage in config.json or with default values"
          @_triggerAutoReset()
        )
      super()

    onConnect: () ->
      @mqttclient.subscribe(@config.topic, { qos: @config.qos })

    getPresence: () -> Promise.resolve(@_presence)

    _triggerAutoReset: ->
      if @config.autoReset and @_presence
        clearTimeout(@_resetPresenceTimeout)
        @_resetPresenceTimeout = setTimeout(@_resetPresence, @config.resetTime)

    _resetPresence: =>
      @_setPresence(no)

    destroy: () ->
     @mqttclient.unsubscribe(@config.topic)
     super()
