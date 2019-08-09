# Crystal Object#send

[![Build Status](https://cloud.drone.io/api/badges/j8r/crystal-object-send/status.svg)](https://cloud.drone.io/j8r/crystal-object-send)
[![ISC](https://img.shields.io/badge/License-ISC-blue.svg?style=flat-square)](https://en.wikipedia.org/wiki/ISC_license)

Interpret a String to an Object method call.

Similar to the Ruby's `Object#send`.

Here macros are used to build a pseudo interpreter.

## Disclaimer

There are lots of limitations, this library is mainly an experiment.

Usually you better avoid using it and interpret the string on your own. It would be more performant and safer.

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  object-send:
    github: j8r/crystal-object-send
```

## Examples

```cr
"abc".send "chars"         #=> ['a', 'b', 'c']
"abc".send "lchop('a')"    #=> "bc"
"abc".send "insert 1, 'z'" #=> "azbc"
2.send("+ 3.0")            #=> 5

var = "first 2"
[0, 1, 3].send(var)        #=> [0, 1]
[0, 1, 2].send("[-1]?")    #=> eq 2
[0, 1, 2].send("[..]")     #=> eq [0, 1, 2]
```

See more in the [specs](spec/object_send_spec.cr)

## License

Copyright (c) 2019 Julien Reichardt - ISC License
