module.exports = {
  title: "pimatic-mqtt device config schemas"
  MqttSwitch: {
    title: "MqttSwitch config options"
    type: "object"
    extensions: ["xLink", "xConfirm", "xOnLabel", "xOffLabel"]
    properties:
      brokerId:
        description: "Id of the broker"
        type: "string"
        default: "default"
      topic:
        description: "Topic for control switch"
        type: "string"
      onMessage:
        description: "Message to switch on"
        type: "string"
        default: "1"
      offMessage:
        description: "Message to switch off"
        type: "string"
        default: "0"
      stateTopic:
        description: "Topic that communicates state, if exists"
        type: "string"
        default: ""
      qos:
        description: "The QoS level of the topic and stateTopic(if exist). Default is 0 and also be used to publishing messages."
        type: "number"
        default: 0
        enum: [0, 1, 2]
      retain:
        description: "If the published message should have the retain flag on or not."
        type: "boolean"
        default: false
  }
  MqttDimmer: {
    title: "MqttDimmer config options"
    type: "object"
    extensions: ["xLink"]
    properties:
      brokerId:
        description: "Id of the broker"
        type: "string"
        default: "default"
      topic:
        description: "Topic for control dimmer brightness"
        type: "string"
      resolution:
        description: "Device resolution"
        type: "integer"
        default: 256
      message:
        description: "Format for outgoing messages"
        type: "string"
        default: "value"
      stateTopic:
        description: "Topic that communicates state, if exists"
        type: "string"
        default: ""
      qos:
        description: "The QoS level of the topic and stateTopic(if exist). Default is 0 and also be used to publishing messages."
        type: "number"
        default: 0
        enum: [0, 1, 2]
      retain:
        description: "If the published message should have the retain flag on or not."
        type: "boolean"
        default: false
  }
  MqttSensor: {
    title: "MqttSensor config options"
    type: "object"
    extensions: ["xLink", "xAttributeOptions"]
    properties:
      brokerId:
        description: "Id of the broker"
        type: "string"
        default: "default"
      attributes:
        description: "Attributes of device"
        required: ["name", "topic"]
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            name:
              description: "Attribute name"
              type: "string"
            topic:
              description: "Attribute topic"
              type: "string"
            qos:
              description: "The QoS level of the topic and stateTopic(if exist). Default is 0 and also be used to publishing messages."
              type: "number"
              default: 0
              enum: [0, 1, 2]
            type:
              description: "The type of the variable."
              type: "string"
              default: "number"
              enum: ["string", "number"]
            unit:
              description: "Attribute unit"
              type: "string"
              default: ""
            acronym:
              description: "Acronym to show as value label in the frontend"
              type: "string"
              default: ""
            discrete:
              description: "Should be set to true if the value does not change continuously over time."
              type: "boolean"
              default: false
            division:
              description: "Constant that will divide the value obtained."
              type: "number"
              default: ""
            multiplier:
              description: "Constant that will multiply the value obtained."
              type: "number"
              default: ""
            messageMap:
              type: "object"
              default: {}
  }
  MqttPresenceSensor: {
    title: "MqttPresenceSensor config options"
    type: "object"
    extensions: ["xLink", "xPresentLabel", "xAbsentLabel"]
    required: ["topic"]
    properties:
      brokerId:
        description: "Id of the broker"
        type: "string"
        default: "default"
      topic:
        description: "Device state topic"
        type: "string"
      onMessage:
        description: "Message that invokes positive status"
        type: "string"
        default: "1"
      offMessage:
        description: "Message that invokes negative status"
        type: "string"
        default: "0"
      qos:
        description: "The QoS level of the topic and stateTopic(if exist). Default is 0 and also be used to publishing messages."
        type: "number"
        default: 0
        enum: [0, 1, 2]
      autoReset:
        type: "boolean"
        default: false
      resetTime:
        type: "integer"
        default: 30000
  }
  MqttContactSensor: {
    title: "MqttContactSensor config options"
    type: "object"
    extensions: ["xLink", "xOpenedLabel", "xClosedLabel"]
    required: ["topic"]
    properties:
      brokerId:
        description: "Id of the broker"
        type: "string"
        default: "default"
      topic:
        description: "Device state topic"
        type: "string"
      onMessage:
        description: "Message that invokes positive status"
        type: "string"
        default: "1"
      offMessage:
        description: "Message that invokes negative status"
        type: "string"
        default: "0"
      qos:
        description: "The QoS level of the topic and stateTopic(if exist). Default is 0 and also be used to publishing messages."
        type: "number"
        default: 0
        enum: [0, 1, 2]
  }
  MqttButtons: {
    title: "MqttButtons config options"
    type: "object"
    extensions: ["xLink"]
    properties:
      brokerId:
        description: "Id of the broker"
        type: "string"
        default: "default"
      buttons:
        description: "Buttons to display"
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            id:
              description: "Button id"
              type: "string"
            text:
              description: "Button text"
              type: "string"
            topic:
              description: "The MQTT topic to publish commands"
              type: "string"
            message:
              description: "Message"
              type: "string"
              default: "1"
            stateTopic:
              description: "Topic that communicates state, if exists"
              type: "string"
              default: ""
            qos:
              description: "The QoS level of the topic and stateTopic(if exist). Default is 0 and also be used to publishing messages."
              type: "number"
              default: 0
              enum: [0, 1, 2]
            confirm:
              description: "Ask the user to confirm the button press"
              type: "boolean"
              default: false
  }
  MqttShutter: {
    title: "MqttShutterController config options"
    type: "object"
    extensions: ["xLink", "xConfirm"]
    properties:
      brokerId:
        description: "Id of the broker"
        type: "string"
        default: "default"
      topic:
        description: "Topic for control Shutter"
        type: "string"
      upMessage:
        description: "Custom Up message"
        type: "string"
        default: "up"
      downMessage:
        description: "Custom Down message"
        type: "string"
        default: "down"
      stopMessage:
        description: "Custom Stop message"
        type: "string"
        default: "stop"
      rollingTime:
        description: "Approx. amount of time (in seconds) for shutter to close or open completely."
        type: "number"
        default: 10
      stateTopic:
        description: "Topic that communicates state, if exists"
        type: "string"
        default: ""
      qos:
        description: "The QoS level of the topic and stateTopic(if exist). Default is 0 and also be used to publishing messages."
        type: "number"
        default: 0
        enum: [0, 1, 2]
      retain:
        description: "If the published message should have the retain flag on or not."
        type: "boolean"
        default: false
  }
  MqttInput: {
    title: "MQTT InputDevice config"
    type: "object"
    extensions: ["xLink"]
    properties:
      brokerId:
        description: "Id of the broker"
        type: "string"
        default: "default"
      topic:
        description: "Topic for control Shutter"
        type: "string"
      type:
        description: "The type of the input"
        type: "string"
        default: "string"
        enum: ["string", "number"]
      min:
        description: "Minimum value for numeric values"
        type: "number"
        required: false
      max:
        description: "Maximum value for numeric values"
        type: "number"
        required: false
      step:
        description: "Step size for minus and plus buttons for numeric values"
        type: "number"
        default: 1
      qos:
        description: "The QoS level of the topic and stateTopic(if exist). Default is 0 and also be used to publishing messages."
        type: "number"
        default: 0
        enum: [0, 1, 2]
      retain:
        description: "If the published message should have the retain flag on or not."
        type: "boolean"
        default: false
  }
}
