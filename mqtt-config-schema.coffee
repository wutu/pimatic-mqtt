module.exports = {
  title: "MQTT plugin config options"
  type: "object"
  properties:
    host:
      description: "The IP or hostname of the MQTT broker (Default: 127.0.0.1)"
      type: "string"
      default: "127.0.0.1"
    port:
      description: "The port of the MQTT broker (Default: 1883)"
      type: "integer"
      default: 1883
    username:
      description: "The login name"
      type: "string"
      default: ""
    password:
      description: "The password"
      type: "string"
      default: ""
    emit:
      description: "Emit Pimatic data to the Broker"
      type: "boolean"
      default: false
}