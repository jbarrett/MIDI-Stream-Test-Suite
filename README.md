# MIDI Stream Test Suite

## What?

A test suite for your MIDI 1.0 stream parser.

## Why?

I don't think this exists anywhere - happy to be corrected!

MIDI stream test suites tend to live in source code, meaning their reusability
is low - they are effectively tied to their target project.

## How?

Tests are taken from MIDI stream handling projects (e.g. ALSA), and are
encoded as JSON in this repository.

Some tests are also hand-crafted to exercise edge cases in the MIDI spec,
or address common deviations from the spec by hardware manufacturers.

## What about MIDI 2?

There's a placeholder for MIDI 2 tests - contributions welcome!

There isn't a format described as-yet for MIDI 2 tests.

## Format

Each JSON file in this repository should contain the following:

A version number. This README describes version 0.

An optional "source" hash indicating the source of the data, containing:

- `project` (string): The source name, and a short description
- `URL`     (string): The canonical URL for the source

An array of hashes named `test_encoding` or `test_decoding`, containing:

- `description` (string): A description of what this test intends to assert.
- `spec` (string - optional): A reference to the MIDI 1.0 specification
- `events` (array): An array of event hashes with the following keys:
    - `name` (string): The event name, e.g. `"note_on"`, `"note_off"`, `"control_change"`...
    - `data` (array): An array of 8-bit integers representing the event's data
- `bytes`  (string) : A space-delimited string of readable hex values, e.g. `"91 3c 5d"`

A single string of bytes may be mapped to zero or more events. Tests may also
influence each other for, e.g. testing of running status. That is, the unit is
a complete JSON file, not a single test within it.

## Usage

Clone this repo, make the files available to your MIDI stream project using
your preferred method (copy, git submodule ...)
Then build a test harness for your library which pulls tests from files in the
repo.

Tests denoted as `test_encoding` are intended to test converting an event
description into hex strings. The `test_decoding` tests are intended to test
converting hex strings into event descriptions.

If the event descriptors in the test data do not match those in your library
you may convert them with a simple lookup table.

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
