# Exometer InfluxDB reporter [![Build Status](https://travis-ci.org/travelping/exometer_influxdb.svg)](https://travis-ci.org/travelping/exometer_influxdb)

This reporter pushes data to [InfluxDB](https://influxdb.com/index.html).

## Usage

1. Add exometer_influxdb to your list of dependencies in rebar.config:

    ```erlang
    {deps, [
        {exometer_influxdb, ".*", {git, "https://github.com/travelping/exometer_influxdb.git", "master"}}
    ]}.
    ```

2. Ensure exometer_influxdb is started before your application:

    ```erlang
    {applications, [exometer_influxdb]}.
    ```

3. Configure it:

    ```erlang
    {exometer, 
        {reporters, [
            {exometer_report_influxdb, [{protocol, http}, 
                                        {host, <<"localhost">>},
                                        {port, 9090},
                                        {db, <<"exometer">>},
                                        {precision, n},
                                        {tags, [{region, ru}]}]}
        ]}
    }.
    ```

Available options:

* __host__ - InfluxDB host. `127.0.01` by default.
* __protocol__ - `http` or `udp` for operating with InfluxDB. `http` by default.
* __port__ - InfluxDB port. `8086` by default.
* __db__ - database on InfluxDB for writing data. `exometer` by default
* __username__ - username for authorization on InfluxDB. __Not implemented yet__.
* __password__ - password for authorization on InfluxDB. __Not implemented yet__.
* __precision__ = [n,u,ms,s,m,h] - sets the precision of the supplied Unix time values. `u` by default.
* __tags__ - list of default tags for each data point. Here always is `host` which local host name by default. 

There is possibility to extend the default tags list which only has `host` by default. Another possibility is is given by the `Extra` parameter of `exometer_report:subscribe/5` or via environment variables:

```erlang
{exometer, 
    {subscriptions, [
         {exometer_report_influxdb, [erlang, memory], total, 5000, true, [{tag, <<"value">>}]},
    ]}
}.

By default the name of the metric is derived from the exometer id: here `[erlang, memory]` is translated to `erlang_memory`. It is possible to remove an item from this list by naming itself or its position with the `from_name` keyword. A removed element is then used as tag:

```
exometer_report:subscribe(exometer_report_influxdb, [erlang, memory], total, 5000, true, [{tag, {from_name, 2}}]).
```

This will result in a name `erlang` with the tag `{tag, memory}` (plus the default tag `{host, Host}`).

# TODO

* UDP support
* Auth support
* Tests 
* Reconfiguration on runtime
