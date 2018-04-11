# Pimatic MQTT plugin
module.exports = (env) ->

  mqtt = require 'mqtt'
  Promise = env.require 'bluebird'
  pluginConfigDef = require './mqtt-config-schema'

  deviceTypes = {}
  for device in [
    'mqtt-switch'
    'mqtt-dimmer'
    'mqtt-sensor'
    'mqtt-presence-sensor'
    'mqtt-contact-sensor'
    'mqtt-buttons'
    'mqtt-shutter'
    'mqtt-input'
  ]
    # convert kebap-case to camel-case notation with first character capitalized
    className = device.replace /(^[a-z])|(\-[a-z])/g, ($1) -> $1.toUpperCase().replace('-','')
    deviceTypes[className] = require('./devices/' + device)(env)

  # import preadicares and actions
  MqttActionProvider = require('./predicates_and_actions/mqtt_action')(env)

  # Pimatic MQTT Plugin class
  class MqttPlugin extends env.plugins.Plugin

    # transfer config - from single Broker to multiple Brokers
    prepareConfig: (config) =>
      try
        if not config.brokers?
          keys = Object.keys pluginConfigDef.properties.brokers.items.properties
          broker = {}
          keys.forEach (key) =>
            if config[key]?
              broker[key] = config[key]
              delete config[key]
          config.brokers = []
          broker["brokerId"] = "default"
          config.brokers.push broker
      catch error
        env.logger.error "Unable to migrate config: " + error

    init: (app, @framework, @config) =>

      @brokers = { }

      for brokerConfig in @config.brokers
        broker = {
          id: brokerConfig.brokerId
          client: null
        }

        options = (
          host: brokerConfig.host
          port: brokerConfig.port
          username: brokerConfig.username
          password: if brokerConfig.password then new Buffer(brokerConfig.password) else false
          keepalive: brokerConfig.keepalive
          clientId: brokerConfig.clientId or 'pimatic_' + Math.random().toString(16).substr(2, 8)
          protocolId: brokerConfig.protocolId
          protocolVersion: brokerConfig.protocolVer
          clean: brokerConfig.cleanSession
          reconnectPeriod: brokerConfig.reconnect or 10000
          connectTimeout: brokerConfig.timeout
          queueQoSZero: brokerConfig.queueQoSZero
          certPath: brokerConfig.certPath
          keyPath: brokerConfig.keyPath
          rejectUnauthorized: brokerConfig.rejectUnauthorized
          ca: brokerConfig.ca
          debug: @config.debug
        )

        if brokerConfig.ca or brokerConfig.certPath or brokerConfig.keyPath or brokerConfig.ssl
          options.protocol = 'mqtts'

        mqttClient = null

        Connection = new Promise( (resolve, reject) =>
          mqttClient = new mqtt.connect(options)
          id = broker.id
          mqttClient.on("connect", () =>
            resolve()
          )
          mqttClient.on('error', reject)

          broker.client = mqttClient

          mqttClient.on "connect", () =>
            env.logger.info "Successfully connected to MQTT Broker #{id}"

          mqttClient.on 'reconnect', () =>
            env.logger.info "Reconnecting to MQTT Broker #{id}"

          mqttClient.on 'offline', () =>
            env.logger.info "MQTT Broker #{id} is offline"

          mqttClient.on 'error', (error) ->
            env.logger.error "Broker #{id} #{error}"
            env.logger.debug error.stack

          mqttClient.on 'close', () ->
            env.logger.info "Connection with MQTT Broker #{id} was closed"
        )

        @brokers[brokerConfig.brokerId] = broker
        env.logger.debug(broker)


      # register devices
      deviceConfigDef = require("./device-config-schema")

      for className, classType of deviceTypes
        env.logger.debug "Registering device class #{className}"
        @framework.deviceManager.registerDeviceClass(className, {
          configDef: deviceConfigDef[className],
          createCallback: @callbackHandler(className, classType)
        })

      @framework.ruleManager.addActionProvider(new MqttActionProvider(@framework, @))

    callbackHandler: (className, classType) ->
      # this closure is required to keep the className and classType context as part of the iteration
      return (config, lastState) =>
        return new classType(config, @, lastState)

  # ###Finally
  # Create a instance of my plugin
  # and return it to the framework.
  return new MqttPlugin
