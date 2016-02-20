module.exports = {
  title: "pimatic-mqtt device config schemas"
  MqttSwitch: {
    title: "MqttSwitch config options"
    type: "object"
    properties:
      topic:
        description: "Topic to control switch"
        type: "string"
      onMessage:
        description: "Message to switch on"
        type: "string"
        default: "on"
      offMessage:
        description: "Message to switch off"
        type: "string"
        default: "off"
      stateTopic:
        description: "Topic that communicates state"
        type: "string"
        default: ""
  }
  MqttDimmer: {
    title: "MqttDimmer config options"
    type: "object"
    properties:
      topic:
        description: "Topic to control dimmer state"
        type: "string"
      onMessage:
        description: "Message to switch on"
        type: "string"
        default: "on"
      offMessage:
        description: "Message to switch off"
        type: "string"
        default: "off"
      brightness:
        description: "Message to change brightness"
        type: "number"
        default: 0
      stateTopic:
        description: "Topic that communicates state"
        type: "string"
        default: ""
  }
  MqttSensor: {
    title: "MqttSensor config options"
    type: "object"
    properties:
      attributes:
        description: "Attributes of device"
        type: "array"
  }
  MqttPresenceSensor: {
    title: "MqttPresenceSensor config options"
    type: "object"
    extensions: ["xLink", "xPresentLabel", "xAbsentLabel"]
    properties:
      topic:
        description: "Topic of device state"
        type: "string"
      inverted:
        description: "LOW = present?"
        type: "boolean"
        default: false
  }
  MqttContactSensor: {
    title: "MqttContactSensor config options"
    type: "object"
    extensions: ["xLink", "xOpenedLabel", "xClosedLabel"]
    properties:
      topic:
        description: "Topic of device state"
        type: "string"
      inverted:
        description: "LOW = closed?"
        type: "boolean"
        default: false
  }
}
