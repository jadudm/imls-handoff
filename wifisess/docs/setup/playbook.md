# Ansible Playbook

We attempted to bootstrap the device using as little `bash` as possible. While ubiquitous as a shell/programming language, it is fragile and error prone. Therefore, we do as little in `bash` as possible, and immediately bootstrap to `ansible`, a widely used open source server automation framework supported by Red Hat.

## Roles 

Ansible arranges automation into "playbooks," which are YAML documents describing actions to be taken on a server. We have one playbook arranged into multiple "roles." Each role is responsible for a different aspect of the Raspberry Pi configuration.

1. `input-initial-configuration`: Installs and runs our tool for gathering the FCFS Seq Id and API token from the librarian.
2. `packages`: We begin with a role that takes responsibility for installing, updating, and removing packages from the Pi. For example, we install `lshw`, a tool for reporting on the hardware connected to the Pi, but remove packages like `apache` and `nginx`, because we do not want any externally visible services running on the device.
3. `unattended-upgrades`: This role makes sure that unattended upgrades are enabled on the Raspberry Pi. This way, the device automatically gets critical service updates from the Debian package repositories.
4. `session-counter`: Configures and installs the software for monitoring wifi usage.
5. `configure-monitor-mode`: Configures the Raspberry Pi hardware for sensing and data collection.
6. `lockdown`: This package makes a few changes. One, it brings up a firewall that prohibits **all** external connections to the Raspberry Pi. Two, it disables login for all accounts. At this point, it becomes impossible to log into the Pi ever again. In short, *configuring a Raspberry Pi for use with our tools is a one-way trip, and not even the librarian can access the device after configuration.*
7. `devsec.hardening.os_hardening`: Uses an externally provided playbook that is intended to be compliant with the Inspec DevSec Baselines. This particular playbook is written against the Linux baseline.
8. `devsec.hardening.ssh_hardening`: Uses an externally provided playbook that is intended to be compliant with the Inspec DevSec Baselines. This particular playbook is written against the SSH baseline.

Between 6, 7, and 8, the Raspberry Pi is now:

1. **Inaccessible**: there are no open ports, and even if the device is plugged in, no accounts can log in interactively.
2. **Hardened**: we have run playbooks that intend to be compliant against baselines in order to limit access to the Pi.

## Maintenance

When the playbook is done, the Pi is ready for use. This same playbook is then run periodically (daily), and in this way, we can later update the devices in production. We might add packages, change configuration, and so on... but we can do so knowing that no one has modified the device without our knowledge.

To modify the playbook, someone would need commit access to a Github repository. Therefore, managing who has access to the playbook is critical to managing the security of the Raspberry Pis in production. We think this is reasonable.

## Caveats

We believe we have brought a healthy level of paranoia to our development process. As configured by the playbook, are very close to completely meeting the [Iot Device Cybersecurity Capability Core Baseline](https://nvlpubs.nist.gov/nistpubs/ir/2020/NIST.IR.8259A.pdf) (NISTIR 8259A). 

However, we want to highlight two caveats:

1. **Ownership**. If this were to scale, it is important to remember that the Pis being used are not owned or controlled by the federal government. They will be devices purchased and set up by libraries, and whether or not NIST or other controls apply is potentially a subject for debate. Our intent is that they use the tools we've developed, as a result we believe that the resulting "hardened" Pi is no longer an easily hacked device that might become part of an attack surface/vector within a library. 

2. **Theft**. If someone steals a Pi from the library, *all bets are off*. Someone could remove the microSD card from the Pi and read it/modify it/etc. At that point, our access controls do not matter. Further, because of how the Pi is designed, *we cannot encrypt the filesystem of the Raspberry Pi*. This is just one of many reasons that we do not store any data on the local filesystem.

There are ways we could encrypt the Pis. Most of those solutions will require a librarian to physically interact with the device in case of a power outage, the device being unplugged, and so on. At that point, the utility of the Raspberry Pi as an "automatic" and "autonomous" sensor is greatly reduced. We believe we have made appropriate trade-offs in terms of security and utility in our design, and are not putting libraries or our communities at risk through our design.