
module.exports = (env) ->

  Promise = env.require 'bluebird'
  flatten = require 'flat'
  assert = env.require 'cassert'

  # Original code comes from the module pimatic-mqtt-simple.
  # The author is Andre Miller (https://github.com/andremiller).
  class MqttSensor extends env.devices.Sensor

    constructor: (@config, @plugin) ->
      assert(@plugin.brokers[@config.brokerId])

      @name = @config.name
      @id = @config.id
      @attributes = {}
      @mqttvars = {}
      @mqttclient = @plugin.brokers[@config.brokerId].client
      
      @attributeValue = {}

      if @mqttclient.connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      @mqttclient.on('message', (topic, message) =>
        for attr, i in @config.attributes
          do (attr) =>
            if attr.topic == topic
              name = attr.name
              try data = JSON.parse(message)
              if typeof data is 'object' and Object.keys(data).length != 0
                flat = flatten(data)
                for key, data of flat
                  if key == name
                    if attr.type == 'number'
                      if attr.division
                        payload = Number("#{data}") / attr.division
                        @setValue(payload, name)
                        return
                      if attr.multiplier
                        payload = Number("#{data}") * attr.multiplier
                        @setValue(payload, name)
                        return
                      else
                        payload = Number("#{data}")
                        @setValue(payload, name)
                        return
                    else
                      payload = ("#{data}")
                      @setValue(payload, name)
                      return
              else
                if attr.type == 'number'
                  if attr.division
                    payload = (Number(message) / attr.division)
                    @setValue(payload, name)
                    return
                  if attr.multiplier
                    payload = (Number(message) * attr.multiplier)
                    @setValue(payload, name)
                    return
                  if attr.messageMap && attr.messageMap[message]
                    payload = Number(attr.messageMap[message])
                    @setValue(payload, name)
                    return
                  else
                    payload = Number(message)
                    @setValue(payload, name)
                    return
                else
                  if attr.messageMap && attr.messageMap[message]
                    payload = attr.messageMap[message]
                    @setValue(payload, name)
                    return
                  else
                    payload = message.toString()
                    @setValue(payload, name)
                    return

      )

      for attr, i in @config.attributes
        do (attr) =>
          name = attr.name
          @attributes[name] = {
            description: name
          }

          @attributes[name].description = name
          @attributes[name].type = attr.type or 'number'
          @attributes[name].unit = attr.unit or ''
          @attributes[name].discrete = attr.discrete or false
          @attributes[name].acronym = attr.acronym or null
          @attributes[name].division = attr.division or null
          @attributes[name].multiplier = attr.multiplier or null
  
          @mqttvars[name] = lastState?[name]?.value
          @_createGetter name, ( => Promise.resolve @mqttvars[name] )

      super()

    setValue: (payload, name) ->
        @mqttvars[name] = payload
        @emit name, payload

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
