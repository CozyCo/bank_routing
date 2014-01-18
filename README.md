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

## Configuration

By default, the routing number database is loaded from a local copy of the Federal Reserve dump file and stored in memory (it's not really that big). To change that behavior:

```ruby
RoutingNumber.init!( store_in: :redis, store_opts: { host: "localhost", db: 15 }, fetch_fed_data: true )
```

This will store the routing number database, after being loaded from the Federal Reserve website, into Redis in database number 15. Access works exactly the same.

You can also configure the service independently of loading the routing database. This works especially well in systems where there are child processes connecting to the same store (Redis, for example). In this case, the routing database will be loaded on first access (by the first child process of a Unicorn web server, for example) - it's essentially lazy-loaded, so a priming call is suggested after system startup. It is worth noting that if a shared data store is used (Redis), it will load the database only once, no matter how many processes attempt access.

```ruby
RoutingNumber.options = { store_in: :redis, store_opts: { host: "localhost", db: 15 }, fetch_fed_data: true }
```

## Copyright

Copyright (c) 2014 Cozy Services Ltd.

See {file:LICENSE.txt} for details.
