# find-ralink

`find-ralink` is used from within the setup playbook. It must be run `sudo`, as only root has privs to read the hardware. (`find-ralink` relies on `lshw`, which it runs and then parses output from.)

Typical usage looks like:

`find-ralink` by itself will report back the logical device where the USB adapter is mounted; e.g. `wlan1`. 

`find-ralink --search ral --field all --extract logicaldevice` will search all hardware descriptor fields of all attached network devices for the string `ral`, and if found, return the logical device name.

`find-ralink --discover --extract mac` will attempt to discover a valid device, and after found, return the MAC address of that device.

These flags are used in the playbook for detecting the presence of an RAlink-based USB wifi adapter and extracting information about them. A file (`search.json`) is placed in `/etc` by the playbook; this file contains search parameters for finding possibly compatible USB wifi adapters. Currently, we know of two that can work, but in the future, more devices can be supported. If the file is not found, an embedded version of the same data serves as a fallback.

*This documentation may someday fall out of sync with the code. For long term maintenance, it may be that moving all documentation to the code bases themselves, and eliminating this site, is a good idea.*