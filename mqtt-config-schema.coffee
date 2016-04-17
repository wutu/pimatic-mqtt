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
    keepalive:
      description: "keepalive in seconds"
      type: "integer"
      default: 180
    clientId:
      description: "Client Id"
      type: "string"
      default: ""
    protocolId:
      description: "MQTT protocol ID"
      type: "string"
      default: "MQTT"
    protocolVer:
      description: "MQTT protocol version"
      type: "integer"
      default: 4
    reconnect:
      description: "reconnectPeriod in milliseconds"
      type: "integer"
      default: 5000
    timeout:
      description: "connectTimeout in milliseconds"
      type: "integer"
      default: 30000
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
    certPath:
      description: "Path to the certificate of the client in PEM format, required for TLS connection"
      type: "string"
      default: ""
    keyPath:
      description: "Path to the key of the client in PEM format, required for TLS connection"
      type: "string"
      default: ""
    rejectUnauthorized:
      description: "Whether to reject self signed certificates"
      type: "boolean"
      default: true
    ca:
      description: "Path to the trusted CA list"
      type: "string"
      default: ""
}