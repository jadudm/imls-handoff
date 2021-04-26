# input-initial-configuration

This application provides a friendly interface to inputting three critical pieces of information. It is run from the bootstrap, before the playbook is executed.

```
input-initial-configuration --fcfs-seq --tag --word-pairs --write
```

is the typical use. This:

1. Prompts for the FCFS Seq Id, and checks it (against a pattern).
2. Reads in a hardware tag (e.g. "device 001" or "networking closet").
3. Reads in word pairs representing an api.data.gov key, checking the validity of each  wordpair, and converting it to its appropriate three-character counterpart.
4. Writes the data to `auth.yaml` in /etc/session-counter, encrypting and base64 encoding the API key along the way.

This application embeds a file containing 500K word pairs. The ordering of the pairs matters. We look up a wordpair, get its index, and then use that as an 18-bit binary value representing three ASCII characters. Because api.data.gov keys only use a limited character set, we can use 6 (as opposed to 8) bits per character to represent possible values in the key, and therefore use an 18-bit value to represent a 3-character "chunk" of the 40-character API key. Hence, we can encode a 40-character API key as 14 "word pairs," which are easier for a librarian to read/type and easier for us to verify the correctness of.

If that didn't make sense, the source code is your best bet. There is a corresponding encoder embedded in the setup documentation. That javascript implementation embeds the same 500K wordpair list; if those lists fall out of sync, the encoding *will not work*.