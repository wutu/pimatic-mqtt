
# pimatic-mqtt

Pimatic plugin for Mqtt

## Status of implementation

This version supports the following

* General sensor (numeric and text data from payload)
* Switch
* PresenceSensor
* ContactSensor
* Dimmer
* Buttons

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
      "host": "127.0.0.1",
      "port": 1883,
      "username": "test",
      "password": "test"
    }

The configuration for a broker is an object comprising the following properties.

| Property  | Default     | Type    | Description                                                                           |
|:----------|:------------|:--------|:--------------------------------------------------------------------------------------|
| host      | "127.0.0.1" | String  | Broker hostname or IP                                                                 |
| port      | 1883        | Integer | Broker port                                                                           |
| username  | -           | String  | The login name                                                                        |
| password  | -           | String  | The Password                                                                          |


## Device Configuration

Devices must be added manually to the device section of your pimatic config.

### Generic sensor

`MqttSensor` is based on the Sensor device class. Handles numeric and text data from the payload.
Code comes from the module pimatic-mqtt-simple. The author is Andre Miller (https://github.com/andremiller).

    {
      "name": "Mosquitto MQTT broker",
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
      ]
    },
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
      "name": "ESP8266 12E monitoring",
      "id": "esp8266-12",
      "class": "MqttSensor",
      "attributes": [
        {
          "name": "uptime",
          "topic": "esp8266/system/uptime",
          "type": "number",
          "unit": "m",
          "acronym": "Uptime"
        },
        {
          "name": "wifi-rssi",
          "topic": "esp8266/system/wifi-rssi",
          "type": "number",
          "unit": "dB",
          "acronym": "WiFi-RSSI"
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

Accepts flat JSON MQTT message

Sample mqtt message: {"rel_pressue": "30.5015", "wind_ave": "0.00", "rain": "0", "rainin": "0", "hum_in": "64", "temp_in_f": "66.4", "dailyrainin": "0", "wind_dir": "225", "temp_in_c": "19.1", "hum_out": "81", "dailyrain": "0", "wind_gust": "0.00", "idx": "2015-10-22 21:41:03", "temp_out_f": "49.6", "temp_out_c": "9.8"}

    {
      "class": "MqttSimpleSensor",
      "id": "weatherstation",
      "name": "Weather Station",
      "mqtturl": "mqtt://localhost",
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

Accepts JSON MQTT message with hierarchy

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

### Switch Device

`MqttSwitch` is based on the PowerSwitch device class.

    {
      "name": "MQTT Switch",
      "id": "switch",
      "class": "MqttSwitch",
      "topic": "wemosd1r2/gpio/2",
      "onMessage": "1",
      "offMessage": "0"
    }

It has the following configuration properties:

| Property   | Default  | Type    | Description                                 |
|:-----------|:---------|:--------|:--------------------------------------------|
| topic      | -        | String  | Topic for device state           |
| onMessage  | "1"      | String  | Message to switch on                  |
| offMessage | "0"      | String  | Message to switch off                  |
| stateTopic | -        | String  | Topic that communicates state, if exists          |

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

| Property   | Default  | Type    | Description                                 |
|:-----------|:---------|:--------|:--------------------------------------------|
| topic      | -        | String  | Topic for device state           |
| onMessage  | "1"      | String  | Message that invokes positive status                  |
| offMessage | "0"      | String  | Message that invokes negative status                  |

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

| Property   | Default  | Type    | Description                                 |
|:-----------|:---------|:--------|:--------------------------------------------|
| topic      | -        | String  | Topic for device state           |
| onMessage  | "1"      | String  | Message that invokes positive status                  |
| offMessage | "0"      | String  | Message that invokes negative status                  |

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
      "resolution": 4096
    },
    {
      "name": "MQTT Dimmer",
      "id": "mqtt-dimmer",
      "class": "MqttDimmer",
      "topic": "wemosd1r2/gpio/15/brightness",
      "resolution": 256
    }

It has the following configuration properties:

| Property   | Default  | Type    | Description                                 |
|:-----------|:---------|:--------|:--------------------------------------------------|
| topic      | -        | String  | Topic for control dimmer brightness.             |
| resolution | 256      | Integer | Resolution of this dimmer. For percent set 101. |

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

| Property   | Default  | Type    | Description                                 |
|:-----------|:---------|:--------|:--------------------------------------------|
| topic      | -        | String  | Topic for device state           |
| message    | -        | String  | Publish message when pressed              |

The Button Action Provider

* press [the] device

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

- [x] Reflecting external condition for dimmer
- [x] Reflecting external condition for buttons
- [ ] QoS
- [x] Processing JSON-encoded object
- [x] Make payload configurable for all device
- [x] Buttons Device
- [x] Configurable PWM range for Dimmer
- [ ] Configurable CIE1931 correction for Dimmer
- [ ] Support for more then one Broker
- [ ] Sending all variables from Pimatic to Broker/s
- [ ] Control Pimatic over MQTT
- [x] Integration with ActionProvider

## Credits

<a href="https://github.com/sweetpi">sweet pi</a> for his work on best automatization software <a href="http://pimatic.org/">Pimatic</a> and all men from the pimatic community.

<a href="https://github.com/andremiller">Andre Miller</a> for for his module <a href="https://github.com/andremiller/pimatic-mqtt-simple/">pimatic-mqtt-simple</a> from which it comes also part of the code.

<a href="https://github.com/mwittig">Marcus Wittig</a> for his nice module <a href="https://github.com/mwittig/pimatic-johnny-five">pimatic-johnny-five</a> which was a big inspiration.