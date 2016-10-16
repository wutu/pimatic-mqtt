module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'

  class MqttContactSensor extends env.devices.ContactSensor

    constructor: (@config, @plugin, lastState) ->
      assert(@plugin.brokers[@config.brokerId])

      @id = @config.id
      @name = @config.name
      @_contact = lastState?.contact?.value or false
      @mqttclient = @plugin.brokers[@config.brokerId].client

      if @plugin.brokers[@config.brokerId].connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      @mqttclient.on('message', (topic, message) =>
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
      @mqttclient.subscribe(@config.topic, { qos: @config.qos })

    getContact: () -> Promise.resolve(@_contact)

    destroy: () ->
      @mqttclient.unsubscribe(@config.topic)
      super()
