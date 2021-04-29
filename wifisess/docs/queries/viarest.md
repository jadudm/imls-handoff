## Using RESTful queries

Directus [also has a REST api](https://docs.directus.io/reference/api/introduction/) for queries. We have provided two endpoints for read-only queries:

1. `https://api.data.gov/TEST/10x-imls/v1/search/events/`
2. `https://api.data.gov/TEST/10x-imls/v1/search/wifi/`

These route to the appropriate endpoints in Directus, with permissions that limit the queries to being read-only. 

Like the GQL queries, a query to the backend is `GET`able via HTTPS. The key is passed in the `X-Api-Key` header (as per the api.data.gov documentation), and the query itself is formed as part of the URL. 

When we route the above URLs to Directus, we are rewriting `/events` to `/items/events_v1/`, and `/wifi/` to `/items/wifi_v1`. This means you cannot use the Directus API in a *general* sense; you can only use it to extract *items* from the data we've collected. (More of the Directus API can be exposed easily, but we have chosen to open the door *just wide enough* for the moment.)

For example, to extract objects from the `events_v1` table, we would `GET` our query to 

`https://api.data.gov/TEST/10x-imls/v1/search/events/`

and the last 100 events from that table would be returned. If we want to [restrict the query](https://docs.directus.io/reference/api/query/) in some way, we can use global query parameters from Directus.

`https://api.data.gov/TEST/10x-imls/v1/search/events/?fields=session_id`

will return the last 100 events, but only the `session_id` field. It is also [possible to filter events](https://docs.directus.io/reference/api/query/#filter):


`https://api.data.gov/TEST/10x-imls/v1/search/events/?filter[fcfs_seq_id][_eq]="ME0064-001`

would return events from one of the two dev/test RPis. Here is a `curl` command that uses this interface:

```
FILTER1="filter\[tag\]\[_eq\]=startup"
FILTER2="filter\[fcfs_seq_id\]\[_eq\]=ME0064-001"
curl \
    -X GET \
    -H "X-Api-Key: $APIDATAGOVKEY" \
    "https://api.data.gov/TEST/10x-imls/v1/search/events/?$FILTER1&$FILTER2"
```

That query should, if the environment variable `APIDATAGOVKEY` is set, return the last 100 events for the matching `fcfs_seq_id` and with the tag `startup`. (The `tag` is an *event tag*, and tells us *what kind* of event was being logged.) As with GQL, the results come back as an array of JSON objects. 

For testing, we pipe the results through `jq` for prettying. And, if you grab some additional tools, you can even convert the JSON into CSV. Assuming you `go get` the program [json2csv](https://github.com/jehiah/json2csv) and put the above code into a file called `q.curl`:

```
./q.curl | jq -c -r ".data[]" | ~/go/bin/json2csv -k servertime,session_id,tag
```

you can get a CSV version of the same data. (Of course, in an application, you could either use a library to do this, or you would walk the resulting JSON objects and convert them to CSV yourself -- if you needed the data in a tabular form. Libraries like `pandas` have tooling built-in to convert arrays of JSON objects to dataframes, for example.)

Note, when working with `curl` on the command line, that significant escaping of brackets becomes necessary. In other languages, "your mileage may vary."
