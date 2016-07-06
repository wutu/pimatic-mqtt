module.exports = (env) ->

  Promise = env.require 'bluebird'
  M = env.matcher

  class MqttActionHandler extends env.actions.ActionHandler

    constructor: (@framework, @mqttclient, @stringTopic, @stringMessage, @stringQoS, @stringRetain) ->

    executeAction: (simulate) ->
      @framework.variableManager.evaluateStringExpression(@stringTopic).then( (strTopic) =>
        @framework.variableManager.evaluateStringExpression(@stringMessage).then( (strMessage) =>
          @framework.variableManager.evaluateExpression(@stringQoS).then( (strQoS) =>
            @framework.variableManager.evaluateExpression(@stringRetain).then( (strRet) =>
              if simulate
                return Promise.resolve("publish mqtt message " + strMessage + " on topic " + strTopic + " qos: " + strQoS + " retain: " + strRet)
              else
                retFlag = if strRet is "true" then true else false
                numQoS = Number(strQoS)
                @mqttclient.publish(strTopic, strMessage, { qos: numQoS, retain: retFlag})
                return Promise.resolve("publish mqtt message " + strMessage + " on topic " + strTopic + " qos: " + strQoS + " retain: " + strRet)
            )
          )
        )    
      )

  # action provider for publishing mqtt messages
  class MqttActionProvider extends env.actions.ActionProvider

    constructor: (@framework, @mqttclient) ->

    parseAction: (input, context) ->

      strToTokens = (str) => ["\"#{str}\""]

      stringMessage = null
      stringTopic = null
      stringQoS = strToTokens '0'
      stringRetain = strToTokens "false"
      match = null

      setMessageString = (m, tokens) => stringMessage = tokens
      setTopicString = (m, tokens) => stringTopic = tokens

      m = M(input, context)
        .match('publish mqtt message ').matchStringWithVars(setMessageString)
        .match(' on topic ').matchStringWithVars(setTopicString)

      next = m.match(' qos: ').match(['0','1','2'], (next, q) =>
        stringQoS = strToTokens(q)
        if next.hadMatch() then m = next
      )

      next = m.match(' retain: ').match(['false','true'], (next, r) =>
        stringRetain = strToTokens(r)
        if next.hadMatch() then m = next
      )

      if m.hadMatch()
        match = m.getFullMatch()
        console.log match
        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new MqttActionHandler(
            @framework, @mqttclient, stringTopic, stringMessage, stringQoS, stringRetain
          )
        }

  return MqttActionProvider