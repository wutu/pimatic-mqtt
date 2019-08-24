# Release History

* 20190824, V0.9.12
    * Added predicate to trigger rules by a received MQTT message, PR #44, thanks @crycode-de
    * Allow for client connection with username/password authentication if broker allows
      anonymous access
       
* 20190820, V0.9.11
    * Added peer dependency to ensure pimatic plugin manager will pickup the latest release
    * Minor fixes to auto resetting presence, PR #41, thanks @qistoph