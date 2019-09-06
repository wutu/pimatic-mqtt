# Release History

* 20190906, V0.9.13
    * Fixture: Add lastValue parameter to MqttSensor constructor to be able to restore 
      attributes from database on startup
    * Added default initialization for MqttSensor attributes values in case the values cannot be 
      restored from database
    * Added experimental device discovery for Tasmota switch and dimmer devices, issue #42
    * Added support for wildcards (#/+) on state topics, issue #11
    * Added JSON payload filtering for MqttSwitch state values, issue #34
    * Added JSON payload filtering for MqttPresenceSensor state values, issue #45
    * Added JSON payload filtering for MqttDimmer, MqttButtons, MqttContactSensor, and MqttShutter 
      state values
    * Added recovery of last state from database for MqttButtons device on startup
    * Added support for displaying the status (last button pressed) for MqttButtons device, issue #43
    * Fixed setting of default brokerId in case no brokerId has been set in the plugin config

* 20190824, V0.9.12
    * Added predicate to trigger rules by a received MQTT message, PR #44, thanks @crycode-de
    * Allow for client connection with username/password authentication if broker allows
      anonymous access
       
* 20190820, V0.9.11
    * Added peer dependency to ensure pimatic plugin manager will pickup the latest release
    * Minor fixes to auto resetting presence, PR #41, thanks @qistoph