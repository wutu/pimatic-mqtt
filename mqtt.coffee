# Pimatic MQTT plugin
module.exports = (env) ->

  mqtt = require 'mqtt'
  Promise = env.require 'bluebird'

  deviceTypes = {}
  for device in [
    'mqtt-switch'
    'mqtt-dimmer'
    'mqtt-sensor'
    'mqtt-presence-sensor'
    'mqtt-contact-sensor'
  ]
    # convert kebap-case to camel-case notation with first character capitalized
    className = device.replace /(^[a-z])|(\-[a-z])/g, ($1) -> $1.toUpperCase().replace('-','')
    deviceTypes[className] = require('./devices/' + device)(env)

  # Pimatic MQTT Plugin class
  class MqttPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>

      host = "localhost"
      port = 1883

      # for broker, i in @config.brokers
      #   if broker.id is '0'
      #     @host = broker.host
      #     console.log  @host
      #     @port = broker.port
      #     @username = broker.username
      #     @password = broker.password

      Connection = new Promise( (resolve, reject) =>
        @mqttclient = new mqtt.connect('mqtt://' + host + ":" + port,
          # keepalive: 120
          clientId: 'pimatic_' + Math.random().toString(16).substr(2, 8)
          reconnectPeriod: 5000
          connectTimeout: 120000
        )
        @mqttclient.on("connect", resolve)
        @mqttclient.on('error', reject)
        return
      ).timeout(50000).catch( (error) ->
        env.logger.error "Error on connecting to MQTT Broker #{error.message}"
        env.logger.debug error.stack
        return
      )

      @mqttclient.on 'connect', (packet) ->
        if packet.returnCode is 0
          @connected = true
          env.logger.info "Successful connected to MQTT Broker"
        else
          if @config.debug
            env.logger.debug "Connection error #{packet.returnCode}"

      @mqttclient.on('offline', () =>
        env.logger.info "MQTT Broker is offline"
      )

      @mqttclient.on 'error', (error) =>
        env.logger.error "connection error: #{error}"
        env.logger.debug error.stack

      @mqttclient.on('message', (topic, message) =>
        env.logger.debug topic
      )

      # Simple Emit Device attributes to Mqtt broker - not working for now
      # @mqttclient.on("connect", () =>
      #   @framework.on('deviceAttributeChanged', (attrEvent) ->
      #     env.logger.debug attrEvent.device.config.id
      #     _name = attrEvent.attributeName.toLowerCase().replace(' ', '_')
      #     env.logger.debug _name
      #     _id = attrEvent.device.config.id.toLowerCase()
      #     env.logger.debug _id
      #     _value = attrEvent.value.toString()
      #     console.log _value
      #     @mqttclient.publish('pimatic/' + _id + '/' + _name, _value)
      #   )
      # )

      # register devices
      deviceConfigDef = require("./device-config-schema")

      for className, classType of deviceTypes
        env.logger.debug "Registering device class #{className}"
        @framework.deviceManager.registerDeviceClass(className, {
          configDef: deviceConfigDef[className],
          createCallback: @callbackHandler(className, classType)
        })

    callbackHandler: (className, classType) ->
      # this closure is required to keep the className and classType context as part of the iteration
      return (config, lastState) =>
        return new classType(config, @, lastState)

  # ###Finally
  # Create a instance of my plugin
  # and return it to the framework.
  return new MqttPlugin