module.exports = {
  title: "MQTT plugin config options"
  type: "object"
  properties:
    brokers:
      description: "Brokers"
      type: "array"
      default: []
      items:
        type: "object"
        properties:
          id:
            type: "string"
            description: "A unique identifier used a reference to the broker"
            default: "0"
          name:
            description: "Just name for MQTT broker"
            type: "string"
            default: ""
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
}