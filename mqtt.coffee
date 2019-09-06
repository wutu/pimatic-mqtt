# Pimatic MQTT plugin
module.exports = (env) ->

  mqtt = require 'mqtt'
  match = require 'mqtt-wildcard'
  Promise = env.require 'bluebird'
  pluginConfigDef = require './mqtt-config-schema'
  configProperties = pluginConfigDef.properties.brokers.items.properties

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

  # import predicates and actions
  MqttActionProvider = require('./predicates_and_actions/mqtt_action')(env)
  MqttPredicateProvider = require('./predicates_and_actions/mqtt_predicate')(env)

  # Pimatic MQTT Plugin class
  class MqttPlugin extends env.plugins.Plugin

    # transfer config - from single Broker to multiple Brokers
    prepareConfig: (config) =>
      try
        if not config.brokers?
          keys = Object.keys configProperties
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
          id: brokerConfig.brokerId ? configProperties.brokerId.default
          client: null
        }

        options = (
          host: brokerConfig.host
          port: brokerConfig.port
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
        if brokerConfig.username? and brokerConfig.username isnt ""
          options.username = brokerConfig.username
          options.password = if brokerConfig.password then new Buffer(brokerConfig.password) else false

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

        @brokers[broker.id] = broker
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
      @framework.ruleManager.addPredicateProvider(new MqttPredicateProvider(@framework, @))

      @framework.deviceManager.on('discover', (eventData) =>
        @framework.deviceManager.discoverMessage 'pimatic-mqtt', 'Searching for devices'
        _seen = {}
        seen = (topic, deviceType) ->
          if _seen[topic]?
            if _seen[topic].hasOwnProperty deviceType
              return true
          else
            _seen[topic] = {}
          _seen[topic][deviceType] = ''
          return false

        for id, broker of @brokers
          client = broker.client

          onConnect = () =>
            client.subscribe('stat/+/RESULT', { qos: 0 })

          client.on('message', (topic, message) =>
            env.logger.debug "New message", topic, message.toString()
            if match(topic, 'stat/+/RESULT')?
              try data = JSON.parse(message)
              if typeof data is 'object' and Object.keys(data).length != 0
                if data.Dimmer? and not seen(topic, 'Dimmer')
                  device =
                    class: 'MqttDimmer'
                    name: 'MqttDimmer ' + topic
                    brokerId: broker.id
                    stateTopic: topic
                    stateValueKey: 'Dimmer'
                    topic: "cmnd/#{topic.match(/stat\/(\w+)\/RESULT/)?[1]}/DIMMER"
                    resolution: 100

                  process.nextTick(
                    @_discoveryCallbackHandler('pimatic-mqtt', device.name, device)
                  )

                if data.POWER? and not seen(topic, 'POWER')
                  device =
                    class: 'MqttSwitch'
                    name: 'MqttSwitch ' + topic
                    brokerId: broker.id
                    stateTopic: topic
                    stateValueKey: 'POWER'
                    topic: "cmnd/#{topic.match(/stat\/(\w+)\/RESULT/)?[1]}/POWER"
                    onMessage: 'ON'
                    offMessage: 'OFF'

                  process.nextTick(
                    @_discoveryCallbackHandler('pimatic-mqtt', device.name, device)
                  )
          )

          if client.connected
            onConnect()
          else
            @mqttclient.on('connect', => onConnect())

          setTimeout ->
            client.unsubscribe('stat/+/RESULT')
          , eventData.time
      )

    callbackHandler: (className, classType) ->
      # this closure is required to keep the className and classType context as part of the iteration
      return (config, lastState) =>
        return new classType(config, @, lastState)

    _discoveryCallbackHandler: (pluginName, deviceName, deviceConfig) ->
      return () =>
        @framework.deviceManager.discoveredDevice pluginName, deviceName, deviceConfig

  # ###Finally
  # Create a instance of my plugin
  # and return it to the framework.
  return new MqttPlugin
