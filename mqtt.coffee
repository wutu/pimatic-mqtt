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
      host = '127.0.0.1'
      port = 1883
      username = false
      password = false

      for broker, i in @config.brokers
        if broker.id is '0'
          host = broker.host or '127.0.0.1'
          console.log host
          port = broker.port or 1883
          username = broker.username or false
          password = broker.password or false

      Connection = new Promise( (resolve, reject) =>
        @mqttclient = new mqtt.connect('mqtt://' + host + ":" + port,
          # keepalive: 120
          clientId: 'pimatic_' + Math.random().toString(16).substr(2, 8)
          reconnectPeriod: 5000
          connectTimeout: 50000
          if username
            username: username
          if password
            password: new Buffer(password)
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