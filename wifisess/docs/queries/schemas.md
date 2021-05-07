---
title: The Schema
layout: page
sidenav: false
blockerstep: 10
---

We don't claim the v1 tables are... *normalized*, or anything like that. But, they're going to work for the pilot.

# events_v1

We have an "events" table that we log a few different things to. Primarily, we capture **startup** events (so we know when the Pi goes live), and **logging_devices**, which tells us that we are starting a minute-long logging and reporting cycle.

The schema for this table is:

```
CREATE TABLE public.events_v1 (
    id serial PRIMARY KEY,
    pi_serial character varying(16),
    fcfs_seq_id character varying(16),
    device_tag character varying(32),
    session_id character varying(255),
    "localtime" timestamp with time zone,
    servertime timestamp with time zone DEFAULT current_timestamp,
    tag character varying(255),
    info text
);
```

When writing queries (via GQL or REST) these column names are what you'll want to use in your queries. *We envision this table could be replaced in the future by a proper logging framework*.

# wifi_v1

The "wifi" table captures device data every minute. The schema is:

```
CREATE TABLE public.wifi_v1 (
    id serial PRIMARY KEY,
    event_id integer,
    pi_serial character varying(16),
    fcfs_seq_id character varying(16),
    device_tag character varying(32),
    "localtime" timestamp with time zone,
    servertime timestamp with time zone DEFAULT current_timestamp,
    session-counter starts
    session_id character varying(255),
    manufacturer_index integer,
    patron_index integer
);
```

(The redundancy in these tables is impressive.)

Every time the Pi powers up, it gets a new `session_id`. This means that pulling all the wifi events from a single `session_id` will give you everything from a single power cycle. (Note that while we do reboot every night, it is possible the Pi could restart for other reasons at other times. These are sensors in the wild, and there are many, many reasons a device might reboot.)

We log data every minute. Each device seen gets a row in the table. (Disk is cheap?) To pull all the devices seen in a given minute, use the `event_id`. If 100 devices were seen in a given minute, then we will have 100 rows in the table with the same `event_id`. 


## Making sense of the data

Our next task is to develop some analyses that do low- and high-pass filtering on the data. That is, if we see a device every minute of every hour of the day, it is probably not a user of the wifi. Likewise, devices we see for 5-or-fewer-minutes could be considered transitory, and should be filtered out as well.

This is why we are doing the pilot: until now, the behavior of wifi users has been conjectural. We will now have 17 sensors reporting data that we can look at, compare, and attempt to make sense of. 
