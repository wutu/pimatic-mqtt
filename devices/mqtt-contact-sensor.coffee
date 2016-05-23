module.exports = (env) ->

  Promise = env.require 'bluebird'

  class MqttContactSensor extends env.devices.ContactSensor

    constructor: (@config, @plugin, lastState) ->
      @id = @config.id
      @name = @config.name
      @_contact = lastState?.contact?.value or false

      if @plugin.connected
        @onConnect()

      @plugin.mqttclient.on('connect', =>
        @onConnect()
      )

      @plugin.mqttclient.on('message', (topic, message) =>
        if @config.topic == topic
          switch message.toString()
            when @config.onMessage
              @_setContact(true)
            when @config.offMessage
              @_setContact(false)
            else
              env.logger.debug "#{@name} with id:#{@id} - Message is not harmony with onMessage or offMessage in config.json or with default values"
      )

      super()

    onConnect: () ->
      @plugin.mqttclient.subscribe(@config.topic, { qos: @config.qos })

    getContact: () -> Promise.resolve(@_contact)

    destroy: () ->
      @plugin.mqttclient.unsubscribe(@config.topic)
      super()
