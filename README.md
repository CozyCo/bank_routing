# bank_routing

* [Homepage](https://github.com/cozy-oss/bank_routing)
* [Documentation](http://rubydoc.info/gems/bank_routing/frames)
* [Email](mailto:oss at cozy.co)

## Description

Getting information about bank routing numbers is a huge pain. The authoritative source for this information is the Federal Reserve, and they only offer this information in a size-delimited text file available from their web site (that, by the way, has an iffy SSL certificate). This gem allows access to all of that information, plus a bunch of translations (mostly prettifying bank names) and extra metadata about the numbers and their corresponding institutions. This is an ongoing effort, and contributions are encouraged either in the code or in the JSON-encoded mapping and metadata files included in this repository.

## Example

```ruby
require 'bank_routing'
RoutingNumber.get(121000358)["name"] # => "Bank of America"
```

## Install

    $ gem install bank_routing

## Copyright

Copyright (c) 2014 Cozy Services Ltd.

See {file:LICENSE.txt} for details.
