# WiFi

<img src="/img/pau06.png" align="right" width="300px" style="padding: 1em;" alt="a pau-06 adapter; CC0"/>

The wifi chipset built into the Raspberry Pi is not capable of listening (generally) to ambient wifi due to BIOS limitations. For that reason, we chose to use an external wifi device. The Ralink chipset is widely supported under Linux, and low cost devices can easily be found from many retailiers. We used the PAU06 and PAU09 devices (2.4GHz and 5GHz, respectively) for testing in the pilot.

## For the future

We developed a small application (`find-ralink`) that searches out and provides configuration about these devices when they are plugged into the RPi. It is a "hardware search tool" of sorts, and can be extended to support/find additional chipsets and hardware in the future. As additional devices are confirmed to work, the search list can be extended, and the utility of the tool improved.