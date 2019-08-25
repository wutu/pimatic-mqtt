
# pimatic-mqtt

[![npm version](https://badge.fury.io/js/pimatic-mqtt.png)](https://badge.fury.io/js/pimatic-mqtt)

MQTT plugin for <a href="https://pimatic.org">Pimatic</a>

## Screenshots
[![Screenshot 1][screen1_thumb]](https://github.com/wutu/pimatic-mqtt/raw/master/assets/screens/screen1.png)
[![Screenshot 2][screen2_thumb]](https://github.com/wutu/pimatic-mqtt/raw/master/assets/screens/screen2.png)
[![Screenshot 3][screen3_thumb]](https://github.com/wutu/pimatic-mqtt/raw/master/assets/screens/screen3.png)
[![Screenshot 4][screen4_thumb]](https://github.com/wutu/pimatic-mqtt/raw/master/assets/screens/screen4.png)
[![Screenshot 5][screen5_thumb]](https://github.com/wutu/pimatic-mqtt/raw/master/assets/screens/screen5.png)

[screen1_thumb]: https://github.com/wutu/pimatic-mqtt/raw/master/assets/screens/screen1_thumb.png?v=1
[screen2_thumb]: https://github.com/wutu/pimatic-mqtt/raw/master/assets/screens/screen2_thumb.png?v=1
[screen3_thumb]: https://github.com/wutu/pimatic-mqtt/raw/master/assets/screens/screen3_thumb.png?v=1
[screen4_thumb]: https://github.com/wutu/pimatic-mqtt/raw/master/assets/screens/screen4_thumb.png?v=1
[screen5_thumb]: https://github.com/wutu/pimatic-mqtt/raw/master/assets/screens/screen5_thumb.png?v=1

## Status of implementation

This version supports the following

* General sensor (numeric and text data from payload)
* Switch
* PresenceSensor
* ContactSensor
* Dimmer
* Buttons
* Shutter
* Input

## Sponsoring

Do you like this plugin? Then please consider a donation to support the development.

<span class="badge-paypal"><a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7K4NWJJPGV5MA" title="Donate to this project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal Donate Button" /></a></span>

## Getting Started

This section is still work in progress.

## Plugin Configuration

While run MQTT broker on localhost and on a standard port, without autentification, you can load the plugin by editing your `config.json` to include the following
in the `plugins` section.

    {
      "plugin": "mqtt",
      "active": true,
      "brokers": [
        {
          "brokerId": "default"
        }
      ]
    }

Configuration with two Brokers

    {
      "plugin": "mqtt",
      "active": true,
      "brokers": [
        {
          "brokerId": "default"
          "host": "localhost"
        },
        {
          "brokerId": "eclipse",
          "host": "iot.eclipse.org"
        }
      ]
    }

The configuration for a broker is an object comprising the following properties.

| Property            | Default     | Type    | Description                                                                             |
|:--------------------|:------------|:--------|:----------------------------------------------------------------------------------------|
| brokerId            | "default"   | String  | Id of the broker                                                                        |
| host                | "127.0.0.1" | String  | Broker hostname or IP                                                                   |
| port                | 1883        | Integer | Broker port                                                                             |
| keepalive           | 180         | Integer | Keepalive in seconds                                                                    |
| clientId            | pimatic*    | String  | *pimatic + random number or your own clientId                                           |
| protocolId          | "MQTT"      | String  | With broker that supports only MQTT 3.1 (not 3.1.1 compliant), you should pass "MQIsdp" |
| protocolVer         | 4           | Integer | With broker that supports only MQTT 3.1 (not 3.1.1 compliant), you should pass 3        |
| cleanSession        | true        | Boolean | Set to false to receive QoS 1 and 2 messages while offline                              |
| reconnect           | 5000        | Integer | Reconnect period in milliseconds                                                        |
| timeout             | 30000       | Integer | Connect timeout in milliseconds                                                         |
| queueQoSZero        | true        | Boolean | If connection is broken, queue outgoing QoS zero messages                               |
| username            | -           | String  | The login name                                                                          |
| password            | -           | String  | The Password                                                                            |
| certPath            | -           | String  | Path to the certificate of the client in PEM format, required for TLS connection        |
| keyPath             | -           | String  | Path to the key of the client in PEM format, required for TLS connection                |
| rejectUnauthorized  | true        | Boolean | Whether to reject self signed certificates                                              |
| ca                  | -           | String  | Path to the trusted CA list                                                             |


## Device Configuration

Devices must be added manually to the device section of your pimatic config.

### Generic sensor

`MqttSensor` is based on the Sensor device class. Handles numeric and text data from the payload.

    {
      "name": "Soil Hygrometer analog reading",
      "id": "wemosd1r2-2",
      "class": "MqttSensor",
      "attributes": [
        {
          "name": "soil-hygrometer",
          "topic": "wemosd1r2/moisture/humidity",
          "type": "number",
          "acronym": "rH"
        }
      ]
    },
    {
      "name": "ESP01 with battery",
      "id": "esp01",
      "class": "MqttSensor",
      "attributes": [
        {
          "name": "temperature",
          "topic": "myhome/firstfloor/office/esp01/dht11/temperature",
          "type": "number",
          "unit": "°C",
          "acronym": "DHT-11-Temperature"
        },
        {
          "name": "humidity",
          "topic": "myhome/firstfloor/office/esp01/dht11/humidity",
          "type": "number",
          "unit": "%",
          "acronym": "DHT-11-Humidity"
        }
      ]
    },
    {
      "name": "Mosquitto",
      "id": "mosquitto",
      "class": "MqttSensor",
      "attributes": [
        {
          "name": "connected-clients",
          "topic": "$SYS/broker/clients/connected",
          "type": "number",
          "acronym": "Clients",
          "discrete": true
        },
        {
          "name": "ram-usage",
          "topic": "$SYS/broker/heap/current",
          "type": "number",
          "unit": "B",
          "acronym": "RAM usage"
        }
      ],
      "xAttributeOptions": [
        {
          "name": "connected-clients",
          "displaySparkline": false
        },
        {
          "name": "ram-usage",
          "displaySparkline": false
        }
      ]
    }

Supports lookup table to translate received message to another value.

    {
      "name": "Sensor with lookup",
      "id": "sensor-with-lookup",
      "class": "MqttSensor",
      "attributes": [
        {
          "name": "state",
          "topic": "some/topic",
          "type": "string",
          "unit": "",
          "acronym": "",
          "messageMap": {
            "0": "Not ready",
            "1": "Ready",
            "2": "Completed"
          }
        }
      ]
    }

Accepts flat JSON message

Sample mqtt message: {"rel_pressue": "30.5015", "wind_ave": "0.00", "rain": "0", "rainin": "0", "hum_in": "64", "temp_in_f": "66.4", "dailyrainin": "0", "wind_dir": "225", "temp_in_c": "19.1", "hum_out": "81", "dailyrain": "0", "wind_gust": "0.00", "idx": "2015-10-22 21:41:03", "temp_out_f": "49.6", "temp_out_c": "9.8"}

    {
      "class": "MqttSensor",
      "id": "weatherstation",
      "name": "Weather Station",
      "attributes": [
        {
          "name": "temp_in_c",
          "topic": "weatherstation",
          "type": "number",
          "unit": "c",
          "acronym": "Inside Temperature"
        },
        {
          "name": "temp_out_c",
          "topic": "weatherstation",
          "type": "number",
          "unit": "c",
          "acronym": "Outside Temperature"
        }
      ]
    }

Accepts JSON message with hierarchy

Sample mqtt message: {"kodi_details": {"title": "", "fanart": "", "label": "The.Victorias.Secret.Fashion.Show.2015.720p.HDTV.x264.mkv", "type": "unknown", "streamdetails": {"video": [{"stereomode": "", "width": 1280, "codec": "h264", "aspect": 1.7777780294418335, "duration": 2537, "height": 720}], "audio": [{"channels": 6, "codec": "ac3", "language": ""}], "subtitle": [{"language": ""}]}}, "val": ""}

    {
      "name": "Kodi media info",
      "id": "kodi-media-info",
      "class": "MqttSensor",
      "attributes": [
        {
          "name": "kodi_details.label",
          "topic": "kodi/status/title",
          "type": "string",
          "acronym": "label"
        },
        {
          "name": "kodi_details.streamdetails.video.0.codec",
          "topic": "kodi/status/title",
          "type": "string",
          "acronym": "codec"
        }
      ]
    }

It has the following configuration properties:

| Property   | Default   | Type    | Description                                 |
|:-----------|:----------|:--------|:--------------------------------------------|
| brokerId   | "default" | String  | Id of the broker                 |
| topic      | -         | String  | Topic for device state           |
| qos        | 0         | Number  | The QoS level of the topic and stateTopic (if exist)           |
| type       | "number"  | String  | The type of the variable(string or number)                 |
| unit       | -         | String  | Attribute unit                  |
| acronym    | -         | String  | Acronym to show as value label in the frontend          |
| discrete   | false     | Boolean | Should be set to true if the value does not change continuously over time.          |
| division   | -         | Number  | Constants that will divide the value obtained          |
| multiplier | -         | Number  | Constant that will multiply the value obtained          |
| messageMap | -         | Object  | Even Pimatic 9, you must manually configure this. We're working on it.          |

### Switch Device

`MqttSwitch` is based on the PowerSwitch device class.

    {
      "name": "MQTT Switch",
      "id": "switch",
      "class": "MqttSwitch",
      "topic": "wemosd1r2/gpio/2/set",
      "stateTopic": "wemosd1r2/gpio/2/state"
      "onMessage": "1",
      "offMessage": "0"
    }

It has the following configuration properties:

| Property   | Default   | Type    | Description                                 |
|:-----------|:----------|:--------|:--------------------------------------------|
| brokerId   | "default" | String  | Id of the broker                 |
| topic      | -         | String  | Topic for device state           |
| onMessage  | "1"       | String  | Message to switch on                  |
| offMessage | "0"       | String  | Message to switch off                  |
| stateTopic | -         | String  | Topic that communicates state, if exists          |
| stateValueKey | -      | String  | The key or path to the state value, given that the payload contains a JSON object |
| qos        | 0         | Number  | The QoS level of the topic and stateTopic (if exist)           |
| retain     | false     | Boolean | If the published message should have the retain flag on or not.           |


Device exhibits the following attributes:

| Property      | Unit  | Type    | Acronym | Description                            |
|:--------------|:------|:--------|:--------|:---------------------------------------|
| state         | -     | Boolean | -       | Switch State, true is on, false is off |

The following predicates and actions are supported:

* {device} is turned on|off
* switch {device} on|off
* toggle {device}

### Presence Sensor

`MqttPresenceSensor` is a digital input device based on the `PresenceSensor` device class.

    {
      "name": "MQTT PIR Sensor",
      "id": "mqtt-pir-sensor",
      "class": "MqttPresenceSensor",
      "topic": "wemosd1r2/pir/presence",
      "onMessage": "1",
      "offMessage": "0"
    }

It has the following configuration properties:

| Property   | Default   | Type    | Description                                 |
|:-----------|:----------|:--------|:--------------------------------------------|
| brokerId   | "default" | String  | Id of the broker                 |
| topic      | -         | String  | Topic for device state           |
| stateValueKey | -      | String  | The key or path to the state value, given that the payload contains a JSON object |
| onMessage  | "1"       | String  | Message that invokes positive status                  |
| offMessage | "0"       | String  | Message that invokes negative status                  |
| qos        | 0         | Number  | The QoS level of the topic and stateTopic (if exist)           |

The presence sensor exhibits the following attributes:

| Property      | Unit  | Type    | Acronym | Description                            |
|:--------------|:------|:--------|:--------|:---------------------------------------|
| presence      | -     | Boolean | -       | Presence State, true is present, false is absent |

The following predicates are supported:

* {device} is present|absent

### Contact Sensor

`MqttContactSensor` is a digital input device based on the `ContactSensor` device class.

    {
      "name": "MQTT Contact",
      "id": "mqtt-contact",
      "class": "MqttContactSensor",
      "topic": "wemosd1r2/contact/state",
      "onMessage": "1",
      "offMessage": "0"
    }

It has the following configuration properties:

| Property   | Default   | Type    | Description                                 |
|:-----------|:----------|:--------|:--------------------------------------------|
| brokerId   | "default" | String  | Id of the broker                 |
| topic      | -         | String  | Topic for device state           |
| stateValueKey | -      | String  | The key or path to the state value, given that the payload contains a JSON object |
| onMessage  | "1"       | String  | Message that invokes positive status                  |
| offMessage | "0"       | String  | Message that invokes negative status                  |
| qos        | 0         | Number  | The QoS level of the topic and stateTopic (if exist)           |

The presence sensor exhibits the following attributes:

| Property      | Unit  | Type    | Acronym | Description                            |
|:--------------|:------|:--------|:--------|:---------------------------------------|
| contact       | -     | Boolean | -       | Contact State, true is opened, false is closed |


The following predicates are supported:

* {device} is opened|closed

### Dimmer Device

`MqttDimmer` is based on the Dimmer device class.

    {
      "name": "MQTT Dimmer",
      "id": "mqtt-dimmer",
      "class": "MqttDimmer",
      "topic": "wemosd1r2/pcapwm/5/brightness",
      "stateTopic": "wemosd1r2/pcapwm/5/state",
      "resolution": 4096
    },
        {
      "topic": "dimmer/cmd",
      "resolution": 1024,
      "id": "dimmer",
      "name": "Dimmer",
      "class": "MqttDimmer",
      "message": "pwm,15,value,2000"
    }

It has the following configuration properties:

| Property   | Default   | Type    | Description                                 |
|:-----------|:----------|:--------|:--------------------------------------------------|
| brokerId   | "default" | String  | Id of the broker                 |
| topic      | -         | String  | Topic for control dimmer brightness.             |
| resolution | 256       | Integer | Resolution of this dimmer. For percent set 101. |
| message    | "value"   | String  | Format for outgoing message. |
| stateTopic | -         | String  | Topic that communicates state, if exists          |
| stateValueKey | -      | String  | The key or path to the state value, given that the payload contains a JSON object |
| qos        | 0         | Number  | The QoS level of the topic and stateTopic (if exist)           |
| retain     | false     | Boolean | If the published message should have the retain flag on or not.           |

The Dimmer Action Provider:

* dim [the] device to value%

### Buttons Device

`MqttButtons` is based on the ButtonsDevice device class.

    {
      "name": "Buttons",
      "id": "buttons-demo",
      "class": "MqttButtons",
      "buttons": [
        {
          "id": "button1",
          "text": "Press me",
          "topic": "some/topic",
          "message": "1"
        }
      ]
    }

It has the following configuration properties for each button:

| Property   | Default   | Type    | Description                                 |
|:-----------|:----------|:--------|:--------------------------------------------|
| brokerId   | "default" | String  | Id of the broker                 |
| id         | -         | String  | Button id          |
| text       | -         | String  | Button text          |
| topic      | -         | String  | Topic for device state           |
| message    | -         | String  | Publish message when pressed              |
| stateTopic | -         | String  | Topic that communicates state, if exists          |
| stateValueKey | -      | String  | The key or path to the state value, given that the payload contains a JSON object |
| qos        | 0         | Number  | The QoS level of the topic and stateTopic (if exist)           |
| confirm    | false     | Boolean | Ask the user to confirm the button press           |

The Button Action Provider

* press [the] device

## Rules

You can publish mqtt messages in rules with the action:

`publish mqtt message "<string with variables>" on topic "<string with variables>" [on broker ListOfBrokers] [qos: 0|1|2] [retain: true|false]`

    "rules": [
      {
        "id": "my-rule",
        "rule": "when every 3 seconds then publish mqtt message \"msg\" on topic \"topic\" on broker default qos: 1 retain: true",
        "active": true,
        "logging": false,
        "name": "Publish mqtt"
      }
    ]

You can trigger rules by mqtt messages with the predicate:

`mqtt received "<message>" on topic "<topic>" [via broker ListOfBrokers] [qos: 0|1|2]`

    "rules": [
      {
        "id": "my-rule-2",
        "name": "Receive mqtt",
        "rule": "when mqtt received \"1\" on topic \"topic\" via broker default qos: 0 then log \"Yeah!\"",
        "active": true,
        "logging": true
      }
    ]

## To Do

'x' marks done To Do items

- [ ] Add RGB device
- [x] Reflecting external condition for dimmer
- [x] Reflecting external condition for buttons
- [x] QoS and retain flag
- [x] Processing JSON-encoded object
- [x] Make payload configurable for all device
- [x] Buttons Device
- [x] Configurable PWM range for Dimmer
- [ ] Configurable CIE1931 correction for Dimmer
- [x] Support for more then one Broker
- [ ] Sending all variables from Pimatic to Broker/s
- [ ] Control Pimatic over MQTT :)
- [x] Integration with ActionProvider
- [x] TLS support
- [x] Add shutter device
- [x] Add text and numeric input device
- [x] JSON filtering for state values

## Credits

<a href="https://github.com/sweetpi">sweet pi</a> for his work on best automatization software <a href="http://pimatic.org/">Pimatic</a> and all guys from the pimatic community.

<a href="https://github.com/andremiller">Andre Miller</a> for for his module <a href="https://github.com/andremiller/pimatic-mqtt-simple/">pimatic-mqtt-simple</a> from which it comes also part of the code.

<a href="https://github.com/mwittig">Marcus Wittig</a> for his nice module <a href="https://github.com/mwittig/pimatic-johnny-five">pimatic-johnny-five</a> which was a big inspiration.
