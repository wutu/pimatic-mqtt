module.exports = {
  title: "pimatic-mqtt device config schemas"
  MqttSwitch: {
    title: "MqttSwitch config options"
    type: "object"
    extensions: ["xLink", "xConfirm"]
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
    properties:
      topic:
        description: "Topic of device state"
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
        description: "Attributes of device"
        type: "array"
  }
}
