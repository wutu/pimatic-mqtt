module.exports = (env) ->

  Promise = env.require 'bluebird'
  M = env.matcher

  class MqttPredicateProvider extends env.predicates.PredicateProvider
    constructor: (@framework, @plugin) ->

    parsePredicate: (input, context) ->

      brokersId = []
      for id of @plugin.brokers
        brokersId.push id

      message = null
      topic = null
      brokerId = "default"
      qos = "0"

      m = M(input, context)
        .match("mqtt received ")
        .matchString( (m,expr) =>
          message = expr
        )
        .match(" on topic ")
        .matchString( (m,expr) =>
          topic = expr
        )
        .optional( (m) =>
          next = m
          m.match(" via broker ")
          .match(brokersId , (m, expr) =>
            brokerId = expr
          )
        )
        .optional( (m) =>
          next = m
          m.match(" qos: ")
          .match(["0","1","2"], (m, expr) =>
            next = m
            qos = parseInt expr
          )
          return next
        )

      if m.hadMatch()
        match = m.getFullMatch()
        return {
          token: match
          nextInput: input.substring(match.length)
          predicateHandler: new MqttPredicateHandler(@framework, @plugin, brokerId, topic, message, qos)
        }
      else
        return null

  class MqttPredicateHandler extends env.predicates.PredicateHandler
    constructor: (@framework, @plugin, @brokerId, @topic, @message, @qos) ->
      @mqttclient = @plugin.brokers[@brokerId].client
      super()

    setup: ->
      env.logger.debug "PredicateHandler", @brokerId, @topic, @message

      # handle received messages
      @mqttclient.on('message', @recvListener = (topic, message) =>
        message = message.toString()
        # check topic
        return if topic isnt @topic

        # check message
        return if message isnt @message and @message isnt "*"

        @emit 'change', 'event'
      )

      @mqttclient.subscribe @topic, { qos: @qos }

      super()

    destroy: ->
      @mqttclient.removeListener 'received', @recvListener
      @mqttclient.unsubscribe @topic
      super()

    getValue: -> Promise.resolve false
    getType: -> 'event'

  return MqttPredicateProvider
