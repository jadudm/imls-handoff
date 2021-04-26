# Project repositories

This project has three major pieces:

1. [**Sensors**](#sensors). The wifi session "sensors" are Raspberry Pis running a locked-down Debian 9 and custom software from 18F. These are complex in their own right, because they need to be set up by non-expert users and operate safely in a potentially hostile environment.
2. [**Backend**](#backend). The data must be collected, stored, and backed up. This is the backend. For the pilot, it is a software stack running under provisional ATO on **cloud.gov**.
3. [**Presentation**](#presentation). What does the data look like? While IMLS has a full Tableau stack, the rest of the world does not. We will mock up some minimal examples in pure JS and (possibly) Jupyter Notebooks (Google Collab) for end-users to explore/use as starting points for checking their own library's data. (Not yet started.)
4. [**Documentation**](#documentation). The documentation for the tools is interspersed throughout the repositories, but the bulk of the docs are centralized in the Federalist site, which was stood up to support librarians taking part in the pilot.

## Sensor repositories

These repositories are directly related to the Raspberry Pi "sensors."

### imls-client-pi-playbook

The [imls-client-pi-playbook](https://github.com/jadudm/imls-client-pi-playbook) repository bootstraps the RPi from a default state to being fully operational as a participant in the data collection network.

To use the playbook, a librarian first installs the Raspberry Pi OS. This is, for all intents and purposes, Debian 9. They then run our bootstrap:

```
bash <(curl -s https://raw.githubusercontent.com/jadudm/imls-client-pi-playbook/main/bootstrap.sh)
```

This runs a go application for reading in (and verifying) their setup parameters, updates the RPi to the most recent version of Ansible, and then pulls the playbook itself (`git clone`) and runs it. As part of this, the playbook installs the data collection software, locks down the system (amongst other things, running DevSec hardening profiles, disabling all external network access, and disabling interactive login users), and sets itself up to pull and rerun the playbook once per day. (This way, we can update the playbook and update the devices if needed.)

That said, once the devices are set up, it is not possible for us, or a librarian, to get back in and make changes. The playbook is a "one way trip to lockdown."

### input-initial-configuration

One of the first programs that is executed is [input-initial-configuration](https://github.com/jadudm/input-initial-configuration). This Golang program does three things:

1. It reads in the api.data.gov key as a series of two-word phrases. Each two-word phrase is mapped to three ASCII characters. We deemed this less error prone than having the librarian type a 40-character API key manually, because we cannot check the key. However, we can verify that each two-word phrase is a valid phrase, and as a result, there is more integrity in the key entry process at setup time.
2. It reads in the FCFS Seq Id for where the sensor will be installed; it checks that the state is valid, and that the right number of digits are provided. For the future, it might be good to have a complete list of valid Seq Ids, but the danger would be if that falls out of date...
3. It asks for a "hardware tag," which is a freeform (255-character) field. The librarian might say the device is "Device001," or "reference desk." Either way, it is intended as a local identifier.

Once this data is read in, the API key is encrypted and written to disk for use by other tools in the stack at a later point.

`input-initial-configuration` does not communicate with the outside world. We have debated whether or not it should record an event after it is done, so that we know when a librarian has attempted the setup process.

### find-ralink

As part of setup, [find-ralink](https://github.com/jadudm/find-ralink) is used to discover valid wifi adapters for sensing. This custom Golang program can both determine whether or not a valid USB wifi adapter is present (`find-ralink --exists`) as well as read specific properties about the hardware (`find-ralink --extract mac`). This utility is used as part of the playbook for device setup and configuration at the OS level. 

`find-ralink` does not communicate with the outside world.

### go-session-counter

[session-counter](https://github.com/jadudm/go-session-counter) is a Golang application that runs "forever." It spends 45 seconds monitoring for devices, anonymizes things, and then sends a report once per minute to the backend. It relies on the encrypted API key laid down by `input-initial-configuration`. 

If `session-counter` encounters too many HTTPS errors in a given timeframe, we quit. This way, the `systemd` unit installed by the playbook can restart `session-counter`, and hopefully data collection can resume uninterrupted. (There are many, many reasons data collection could be interrupted, and may require more thought if scaling to additional participants is being considered.)

## Backend

The [backend is a cloud.gov buildpack](https://github.com/cantsin/10x-rabbit/). This stands up our database (Postgres), the API provider (Directus), and the validation framework (ReVaL). cloud.gov is otherwise known as Cloud Foundry, an open source hosting framework inspired by Hiroku (and similar).

We have not, at this time, automated the configuration and management of api.data.gov. However, there are not enough participants in the pilot to have made this level of automation a priority. For scaling, thinking about how to make it easy to add/remove keys from the set "allowed to store data" is something that we would need to design/develop.

## Presentation

We have not yet developed any scripts to present the data being collected. Accessing data can either be public (a download), a public API (open for read via api.data.gov), or by permission. 

If by API, it is possible to use a single GET command to extract/query data; Directus provides a rich API interface, and for the pilot makes it easy to extract some or all of the data matching simple query parameters.

## Documentation

The documentation for the project lives (in part) in the component repositories, and in part in two additional website-based repositories.

1. [imls-handoff](https://github.com/jadudm/imls-handoff) is a `mkdocs` site. It can be used directly, and provides markdown-based documentation of the stack. This page is part of `imls-handoff`.
2. [10x-shared-components-phase-3](https://github.com/cantsin/10x-shared-components-phase-3) is a Federalist site. Federalist is a platform developed/provided by 18F/TTS/GSA intended to provide a low bar for secure, static-site hosting. Underneath, it is Jekyll, a static site generator. This portion of the documentation was developed for informing the IMLS/library community about the work, as well as documenting the setup process of the RPis for participating libraries. It embeds the `imls-handoff` docs as a submodule.

