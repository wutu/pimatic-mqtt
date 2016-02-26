module.exports = (env) ->

  Promise = env.require 'bluebird'

  # Code comes from the module pimatic-mqtt-simple. The author is Andre Miller (https://github.com/andremiller).
  class MqttSensor extends env.devices.Sensor

    constructor: (@config, @plugin) ->
      @name = config.name
      @id = config.id
      @attributes = {}
      @mqttvars = []


      if @plugin.connected
        @onConnect()

      @plugin.mqttclient.on('connect', =>
        @onConnect()
      )

       
      @plugin.mqttclient.on('message', (topic, message) =>
        # message is Buffer
        # Get the right name for this topic
        for attr, i in @config.attributes
          do (attr) =>
            if attr.topic == topic
              # Update value in local array
              @mqttvars[topic] = message.toString()
              # Emit the new value
              if attr.type == 'number'
                if attr.division
                  @emit attr.name, Number(message) / attr.division
                else
                  @emit attr.name, Number(message)
              else
                if attr.messageMap && attr.messageMap[message]
                  @emit attr.name, attr.messageMap[message]
                else
                  @emit attr.name, message.toString()
      )

      for attr, i in @config.attributes
        do (attr) =>
          name = attr.name
          @attributes[name] = {
            description: name
          }

          @attributes[name].description = name
          @attributes[name].type = attr.type
          @attributes[name].unit = attr.unit or ''
          @attributes[name].discrete = attr.discrete or false
          @attributes[name].acronym = attr.acronym or null
          @attributes[name].division = attr.division or 1

          getter = ( =>
            if attr.type == 'number'
              value = Number(@mqttvars[attr.topic])
            else
              value = @mqttvars[attr.topic]
            Promise.resolve(value)
          )

          @_createGetter(name, getter)

      super()

    onConnect: () ->
      # Subscribe to the topics
      for attr, i in @config.attributes
        do (attr) =>
          @plugin.mqttclient.subscribe(attr.topic)
          env.logger.debug("subscribe: " + attr.topic)
