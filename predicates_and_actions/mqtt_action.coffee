module.exports = (env) ->

  Promise = env.require 'bluebird'

  class MqttActionHandler extends env.actions.ActionHandler

    constructor: (@framework, @mqttclient, @stringTopic, @stringMessage) ->

    executeAction: (simulate) ->
      @framework.variableManager.evaluateStringExpression(@stringTopic).then( (strTopic) =>
        @framework.variableManager.evaluateStringExpression(@stringMessage).then( (strMessage) =>
          if simulate
            return Promise.resolve("publish mqtt message " + strMessage + " on topic " + strTopic)
          else
            #env.logger.info "publish mqtt message " + strMessage + " on topic " + strTopic
            @mqttclient.publish(strTopic, strMessage)
            return Promise.resolve("publish mqtt message " + strMessage + " on topic " + strTopic)
        )
      )

  # action provider for publishing mqtt messages
  class MqttActionProvider extends env.actions.ActionProvider

    constructor: (@framework, @mqttclient) ->

    parseAction: (input, context) ->
      stringMessage = null
      stringTopic = null
      match = null
      fullMatch = no

      setMessageString = (m, tokens) => stringMessage = tokens
      setTopicString = (m, tokens) => stringTopic = tokens

      m = env.matcher(input, context)
        .match("publish mqtt message ")
        .matchStringWithVars(setMessageString)
        .match(" on topic ")
        .matchStringWithVars(setTopicString)

      if m.hadMatch()
        match = m.getFullMatch()
        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new MqttActionHandler(@framework, @mqttclient, stringTopic, stringMessage)
        }
      else
        return null

  return MqttActionProvider