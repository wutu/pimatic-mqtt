module.exports = {
  title: "pimatic-mqtt device config schemas"
  MqttSwitch: {
    title: "MqttSwitch config options"
    type: "object"
    extensions: ["xLink", "xConfirm", "xOnLabel", "xOffLabel"]
    properties:
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
  }
  MqttDimmer: {
    title: "MqttDimmer config options"
    type: "object"
    extensions: ["xLink"]
    properties:
      topic:
        description: "Topic for control dimmer brightness"
        type: "string"
      resolution:
        description: "Device resolution"
        type: "integer"
        default: 256
  }
  MqttSensor: {
    title: "MqttSensor config options"
    type: "object"
    extensions: ["xLink", "xAttributeOptions"]
    properties:
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
            type:
              description: "Attribute type: number or string"
              type: "string"
            unit:
              description: "Attribute unit"
              type: "string"
              default: ""
            acronym:
              description: "Attribute acronym"
              type: "string"
              default: ""
            discrete:
              type: "boolean"
              default: false
            division:
              type: "number"
              default: ""
            displaySparkline:
              type: "boolean"
              default: true
            messageMap:
              type: "object"
              default: ""

  }
  MqttPresenceSensor: {
    title: "MqttPresenceSensor config options"
    type: "object"
    extensions: ["xLink", "xPresentLabel", "xAbsentLabel"]
    required: ["topic"]
    properties:
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
  }
  MqttContactSensor: {
    title: "MqttContactSensor config options"
    type: "object"
    extensions: ["xLink", "xOpenedLabel", "xClosedLabel"]
    required: ["topic"]
    properties:
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
  }
  MqttButtons: {
    title: "MqttButtons config options"
    type: "object"
    extensions: ["xLink"]
    properties:
      buttons:
        description: "Buttons to display"
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            id:
              type: "string"
            text:
              type: "string"
            topic:
              description: "Device topic"
              type: "string"
            message:
              description: "Message"
              type: "string"
              default: "1"
            confirm:
              description: "Ask the user to confirm the button press"
              type: "boolean"
              default: false
  }
}
