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

<!-- A version number. This README describes version 0. -->

A high-level `"description"` of the tests in the file.

An optional `"ref"` containing a reference to the MIDI 1.0 specification or book or paper which
describes this behaviour.

A boolean `"standard"`, denoting whether the tests are for behaviour specified in the MIDI standard.
If this is absent a default of `true` should be assumed.

An optional `"source"` hash indicating the source of the data, containing:

- `"name"`    (string): The source name, and ideally a short description
- `"URL"`     (string - optional): The canonical URL for the source

An array of hashes named `"tests", containing:

- `"description"` (string): A description of what this test intends to assert
- `"data"` (MIDI events or byte string): Input data
- `"expect"`(MIDI events or byte string): Expected output

A single string of MIDI bytes may be mapped to zero or more events. Tests may
also influence each other for, e.g. testing of running status. That is, the
unit is a complete JSON file, not a single test within it.

Ordinarily binary data within JSON would be encoded as base64. The hex value
strings described here should allow for easy reading and editing of test data.

### Example

This is a simple encoding test (this would be denoted by its presence in
`MIDI_1/encoding`), describing some simple performance channel messages without
consideration for running status. Channels are zero-indexed.

```json
{
   "description" : "Example test file (check your harness works!)",
   "ref" : "MIDI 1.0 Detailed Specification, Details -> Channel Voice Messages",
   "standard" : true,
   "tests" : [
      {
         "data" : "90 45 7f 90 46 7f",
         "description" : "Two full note-on messages",
         "expect" : [
            {
               "channel" : 0,
               "name" : "note_on",
               "note" : 69,
               "velocity" : 127
            },
            {
               "channel" : 0,
               "name" : "note_on",
               "note" : 70,
               "velocity" : 127
            }
         ]
      },
      {
         "data" : "81 45 7f 81 46 7f",
         "description" : "Two full note-off messages, channel 1",
         "expect" : [
            {
               "channel" : 1,
               "name" : "note_off",
               "note" : 69,
               "velocity" : 127
            },
            {
               "channel" : 1,
               "name" : "note_off",
               "note" : 70,
               "velocity" : 127
            }
         ]
      }
   ]
}
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
my $midi_bytestream = pack 'H*', $json_bytes =~ y/ //dr;
```

### Python

```python
midi_bytestream = bytes.fromhex( json_bytes )
```

### Your favourite programming language

...contributions welcome

## License

I dunno, is this even copyrightable?

