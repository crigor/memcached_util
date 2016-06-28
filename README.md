Memcached Util
==============

A chef recipe for installing memcached on a utility instance. Specify the name of the utility instance on `memcached_util/attributes/default.rb`.

```
default[:memcached] = {
  :utility_name => "memcached",
  # ...
}
```

This recipe also creates `/data/APPNAME/shared/config/memcached_util.yml` on the app master, app, and solo instances. During deploys, that file gets symlinked from `/data/APPNAME/current/config/memcached_util.yml`.

On your application you can read the file to get the hostname of the utility instance.

```
memcached_config = YAML.load_file(Rails.root.join("config", "memcached_util.yml"))

{
    "production" => {
        "servers" => [
            [0] "ip-10-109-190-114.ec2.internal:11211"
        ]
    }
}
```

If you're using [dalli] on Rails,

```
config.cache_store = :dalli_store, memcached_config["production"]["servers"].first,
  { :namespace => NAME_OF_RAILS_APP, :expires_in => 1.day, :compress => true }
```

This works on stable-v2 and stable-v4.

[dalli]: https://github.com/petergoldstein/dalli
