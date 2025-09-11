# MIDI Stream Test Suite

## What?

A test suite for your MIDI 1.0 stream parser.

## Why?

I don't think this exists anywhere - happy to be corrected!

MIDI stream test suites tend to live in source code, meaning their reusability
is low - they are effectively tied to their target project.

## How?

Tests are taken from MIDI stream handling projects (e.g. ALSA), and are encoded
as JSON in this repository. Some tests are also hand-crafted to exercise edge
cases in the MIDI spec, or address common deviations from the spec by hardware
manufacturers.

You should pick and choose which test cases fit your needs - running the entire
suite may be an ambitious endeavour.

## What about MIDI 2?

There's a placeholder for MIDI 2 tests - contributions welcome!

There isn't a format described as-yet for MIDI 2 tests.

## Format

Each JSON file in this repository should contain the following:

A version number. This README describes version 0.

A high-level `"file_description"` of the tests in the file.

An optional `"source"` hash indicating the source of the data, containing:

- `project` (string): The source name, and a short description
- `URL`     (string): The canonical URL for the source

An array of hashes named `"test_encoding"` or `"test_decoding"`, containing:

- `description` (string): A description of what this test intends to assert.
- `standard` (boolean): Is the asserted behaviour as described in the MIDI specs?
- `ref` (string - optional): A reference to the MIDI 1.0 specification or book or paper which describes this behaviour.
- `events` (array): An array of event hashes with the following keys:
    - `name` (string): The event name, e.g. `"note_on"`, `"note_off"`, `"control_change"`...
    - `data` (hash): Named values for this event, e.g. `"channel"`, `"velocity"`
    - `bytes`  (string) : A space-delimited string of readable hex values, e.g. `"91 3c 5d"`

A single string of MIDI bytes may be mapped to zero or more events. Tests may
also influence each other for, e.g. testing of running status. That is, the
unit is a complete JSON file, not a single test within it.

Ordinarily binary data within JSON would be encoded as base64. The hex value
strings described here should allow for easy reading and editing of test data.

### Examples

```json

```

## Usage

Clone this repo, make the files available to your MIDI stream project using
your preferred method (copy, git submodule ...), then build a test harness for
your library which pulls tests from files in this repo.

Tests denoted as `test_encoding` are intended to test converting an event
description into hex strings. The `test_decoding` tests are intended to test
converting hex strings into event descriptions.

If the event descriptors in the test data do not match those in your library
you may convert them with a simple lookup table. A specific case which may also
require attention is `"note_on"` messages with velocity 0. These are treated as
`"note_off"` in decoded messages (this is done so note off can be sent as a 
single running-status byte).

You will also need to convert the `bytes` hex string to a MIDI byte stream.
Some examples follow.

### Perl

```perl
my $midi_bytestream = join '', map { chr hex } split " ", $json_bytes;
```

or

```perl
my $midi_bytestream = pack 'H*', $json_bytes =~ y/ //dr;;
```

### Python

```python
midi_bytestream = bytes.fromhex( json_bytes );
```

### Your favourite programming language

...contributions welcome

## License

I dunno, is this even copyrightable?

