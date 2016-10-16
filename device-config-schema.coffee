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
        required: ["name", "topic", "type"]
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
              description: "Should be set to true if the value does not change continuously over time."
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
}
