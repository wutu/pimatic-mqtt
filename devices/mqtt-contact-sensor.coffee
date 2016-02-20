module.exports = (env) ->

  Promise = env.require 'bluebird'

  class MqttContactSensor extends env.devices.ContactSensor

    constructor: (@config, @plugin, lastState) ->
      @id = config.id
      @name = config.name
      @_contact = lastState?.contact?.value or false

      @plugin.mqttclient.on('connect', =>
        @plugin.mqttclient.subscribe(config.topic)
      )

      @plugin.mqttclient.on('message', (topic, message) =>
        if config.topic == topic
          switch message.toString()
            when "on", "true", "1", "1.00", "closed"
              @_setContact(true)
            else
              @_setContact(false)
      )

      super()

    getContact: () -> Promise.resolve(@_contact)