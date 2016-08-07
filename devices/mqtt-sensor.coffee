module.exports = (env) ->

  Promise = env.require 'bluebird'
  flatten = require 'flat'
  assert = env.require 'cassert'

  # Code comes from the module pimatic-mqtt-simple. The author is Andre Miller (https://github.com/andremiller).
  class MqttSensor extends env.devices.Sensor

    constructor: (@config, @plugin) ->
      assert(@plugin.brokers[@config.brokerId])

      @name = @config.name
      @id = @config.id
      @attributes = {}
      @mqttvars = []
      @mqttclient = @plugin.brokers[@config.brokerId].client

      if @plugin.brokers[@config.brokerId].connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      @mqttclient.on('message', (topic, message) =>
        for attr, i in @config.attributes
          do (attr) =>
            if attr.topic == topic
              @mqttvars[topic] = message.toString()
              try data = JSON.parse(message)
              if typeof data is 'object' and Object.keys(data).length != 0
                flat = flatten(data)
                for key, value of flat
                  if key == attr.name
                    if attr.type == 'number'
                      if attr.division
                        @emit attr.name, Number("#{value}") / attr.division
                        return
                      if attr.multiplier
                        @emit attr.name, Number("#{value}") * attr.multiplier
                        return
                      else
                        @emit attr.name, Number("#{value}")
                    else
                      @emit attr.name, "#{value}"
              else
                if attr.type == 'number'
                  if attr.division
                    @emit attr.name, Number(message) / attr.division
                    return
                  if attr.multiplier
                    @emit attr.name, Number(message) * attr.multiplier
                    return
                  else
                    @emit attr.name, Number(message)
                else
                  if attr.messageMap && attr.messageMap[message]
                    @emit attr.name, attr.messageMap[message]
                    return
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
          _qos = attr.qos or 0
          @mqttclient.subscribe(attr.topic, { qos: _qos })

    destroy: () ->
     for attr, i in @config.attributes
        do (attr) =>
          @mqttclient.unsubscribe(attr.topic)
     super()
