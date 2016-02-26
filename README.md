
# pimatic-mqtt

Pimatic Plugin for Mqtt

## Status of implementation

This version supports the following

* General sensor (numeric and text data from payload)
* Switch
* PresenceSensor, ContactSensor
* Dimmer

## Getting Started

This section is still work in progress.

## Plugin Configuration

While run MQTT broker on localhost and on a standard port, without autentification, you can load the plugin by editing your `config.json` to include the following
in the `plugins` section.

    {
        "plugin": "mqtt"
    }

Full config

    {
      "plugin": "mqtt",
        "brokers": [
        {
          "id": "0",
          "name": "Broker"
          "host": "127.0.0.1",
          "port": 1883,
          "username": "test",
          "password": "test"
        }
      ]
    }

The configuration for a broker is an object comprising the following properties.

| Property  | Default     | Type    | Description                                                                           |
|:----------|:------------|:--------|:--------------------------------------------------------------------------------------|
| id        | "0"         | String  | Unique identifier used as a reference by a device configuration. Must be "0" for now. |
| name      | -           | String  | Currently not used                                                                    |
| host      | "127.0.0.1" | String  | Broker hostname or IP                                                                 |
| port      | 1883        | integer | Broker port                                                                           |
| username  | -           | String  | The login name                                                                        |
| password  | -           | String  | The Password                                                                          |


## Device Configuration

Devices must be added manually to the device section of your pimatic config.

### Generic sensor

`MqttSensor` is based on the Sensor device class. Handles numeric and text data from the payload.
Code comes from the module pimatic-mqtt-simple. The author is Andre Miller (https://github.com/andremiller).
Also supports lookup table to translate received message to another value.

    {
      "class": "MqttSensor",
      "id": "deep-space-nine-temp",
      "name": "Deep Space Nine Temp :)",
      "attributes": [
        {
          "name": "temp-kelvin",
          "topic": "pimatic/deep-space-nine-temp/kelvin",
          "type": "number",
          "unit": "K",
          "acronym": "T"
        },
        {
          "name": "temp-celsius",
          "topic": "pimatic/deep-space-nine-temp/celsius",
          "type": "number",
          "unit": "°C",
          "acronym": "t"
        }
      ]
    },
    {
      "class": "MqttSensor",
      "id": "wemosd1r2-2",
      "name": "Soil Hygrometer analog reading",
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
      "class": "MqttSensor",
      "id": "esp01-power-meter",
      "name": "Energiemonitor",
      "attributes": [
        {
          "name": "pulses",
          "topic": "pimatic/pulsecounter/count",
          "type": "number",
          "acronym": "Pulses"
        },
        {
          "name": "total",
          "topic": "pimatic/pulsecounter/total",
          "type": "number",
          "unit": "Wh",
          "acronym": "Total"
        }
      ]
    },
    {
      "class": "MqttSensor",
      "id": "esp01",
      "name": "ESP01 monitoring",
      "attributes": [
        {
          "name": "uptime",
          "topic": "esp01/system/uptime",
          "type": "number",
          "unit": "m",
          "acronym": "Uptime"
        },
        {
          "name": "freeram",
          "topic": "esp01/system/freeram",
          "type": "number",
          "unit": "B",
          "acronym": "FreeRAM"
        },
        {
          "name": "wifi-rssi",
          "topic": "esp01/system/wifi-rssi",
          "type": "number",
          "unit": "dB",
          "acronym": "WiFi-RSSI"
        }
      ]
    },
    {
      "class": "MqttSensor",
      "id": "mosquitto",
      "name": "Mosquitto MQTT broker",
      "attributes": [
        {
          "name": "connected-clients",
          "topic": "$SYS/broker/clients/connected",
          "type": "number",
          "acronym": "Clients"
        },
        {
          "name": "ram-usage",
          "topic": "$SYS/broker/heap/current",
          "type": "number",
          "unit": "B",
          "acronym": "RAM usage"
        },
        {
          "name": "mosquitto-msg-sent",
          "topic": "$SYS/broker/publish/messages/sent",
          "type": "number",
          "acronym": "Msg-sent"
        },
        {
          "name": "mosquitto-msg-received",
          "topic": "$SYS/broker/publish/messages/received",
          "type": "number",
          "acronym": "Msg-received"
        },
        {
          "name": "mosquitto-bytes-sent",
          "topic": "$SYS/broker/bytes/sent",
          "type": "number",
          "unit": "B",
          "acronym": "Bytes-sent"
        },
        {
          "name": "mosquitto-bytes-received",
          "topic": "$SYS/broker/bytes/received",
          "type": "number",
          "unit": "B",
          "acronym": "Bytes-received"
        }
      ]
    },
    {
      "class": "MqttSensor",
      "id": "sensor-with-lookup",
      "name": "Sensor with lookup",
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



### Switch Device

`MqttSwitch` is based on the PowerSwitch device class.

    {
      "class": "MqttSwitch",
      "id": "switch",
      "name": "MQTT Switch",
      "topic": "wemosd1r2/gpio/2",
      "onMessage": "1.00",
      "offMessage": "0.00"
    }

It has the following configuration properties:

| Property   | Default  | Type    | Description                                 |
|:-----------|:---------|:--------|:--------------------------------------------|
| topic      | -        | String  | Topic for device state           |
| onMessage  | -        | String  | Message to switch on                  |
| offMessage | -        | String  | Message to switch off                  |
| stateTopic | -        | String  | Topic that communicates state           |

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
      "class": "MqttPresenceSensor",
      "id": "mqtt-pir-sensor",
      "name": "MQTT PIR Sensor",
      "topic": "wemosd1r2/pir/presence"
    }

Positively reacts to these states: "on", "true", "1", "1.00". Another payload invoke false/absent state.

It has the following configuration properties:

| Property  | Default  | Type    | Description                                 |
|:----------|:---------|:--------|:--------------------------------------------|
| topic     | -        | String  | Topic for device state           |

The presence sensor exhibits the following attributes:

| Property      | Unit  | Type    | Acronym | Description                            |
|:--------------|:------|:--------|:--------|:---------------------------------------|
| presence      | -     | Boolean | -       | Presence State, true is present, false is absent |

The following predicates are supported:

* {device} is present|absent

### Contact Sensor

`MqttContactSensor` is a digital input device based on the `ContactSensor` device class.

    {
      "class": "MqttContactSensor",
      "id": "mqtt-contact",
      "name": "MQTT Contact",
      "topic": "wemosd1r2/contact/state"
    }

Positively reacts to these states: "on", "true", "1", "1.00", "closed". Another payload invoke false/absent state.

It has the following configuration properties:

| Property  | Default  | Type    | Description                                 |
|:----------|:---------|:--------|:--------------------------------------------|
| topic     | -        | String  | Topic for device state           |

The presence sensor exhibits the following attributes:

| Property      | Unit  | Type    | Acronym | Description                            |
|:--------------|:------|:--------|:--------|:---------------------------------------|
| contact       | -     | Boolean | -       | Contact State, true is opened, false is closed |


The following predicates are supported:

* {device} is opened|closed

### Buttons Device

`MqttSwitch` is based on the ButtonsDevice device class.

    {
      "class": "MqttButtons",
      "id": "buttons-demo",
      "name": "Buttons",
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

| Property   | Default  | Type    | Description                                 |
|:-----------|:---------|:--------|:--------------------------------------------|
| topic      | -        | String  | Topic for device state           |
| message    | -        | String  | Publish message when pressed              |


##Rules

You can publish mqtt messages in rules with the action:

`publish mqtt message "<string with variables>" on topic "<string with variables>"`

    "rules": [
      {
        "id": "my-rule",
        "rule": "if every 1 minutes then publish mqtt message \"some message\" on topic \"my/topic\"",
        "active": true,
        "logging": false,
        "name": "Publish mqtt"
      }
    ]


##Install Mosquitto broker

For Deb wheezy:

~~~
wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
sudo apt-key add mosquitto-repo.gpg.key
cd /etc/apt/sources.list.d/
sudo wget http://repo.mosquitto.org/debian/mosquitto-wheezy.list
apt-get update
apt-get install mosquitto
sudo /etc/init.d/mosquitto start
~~~

## To Do

- [ ] Processing json string in payload
- [ ] Make payload configurable for all device
- [x] Buttons Device
- [ ] Configurable PWM range for Dimmer
- [ ] Configurable CIE1931 correction for Dimmer
- [ ] Support for more then one Broker
- [ ] Sending all variables from Pimatic to Broker/s
- [ ] Control Pimatic over MQTT
- [x] Integration with ActionProvider

## Credits

<a href="https://github.com/sweetpi">sweet pi</a> for his work on best automatization software <a href="http://pimatic.org/">Pimatic</a> and all men from the pimatic community.

<a href="https://github.com/andremiller">Andre Miller</a> for for his module <a href="https://github.com/andremiller/pimatic-mqtt-simple/">pimatic-mqtt-simple</a> from which it comes also part of the code.

<a href="https://github.com/mwittig">Marcus Wittig</a> for his nice module <a href="https://github.com/mwittig/pimatic-johnny-five">pimatic-johnny-five</a> which was a big inspiration.