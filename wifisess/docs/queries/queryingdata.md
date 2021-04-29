# Querying data

There are two interfaces for querying data: GraphQL and a RESTful interface. The API is being provided by [directus.io](https://directus.io/); therefore, the API documentation for Directus applies here, and reviewing it is worthwhile. Here, we will provide a high-level summary of how to extract data from the IMLS WIFISESS pilot.

## Obtain an API key

First, you will need an API key. Go to [api.data.gov's signup page](https://api.data.gov/signup/) and sign up for a key. Shortly after signup, you should receive an API key via email.

All requests are routed through api.data.gov. It provides us with a layer of security, key management, rate limiting, and other services we felt no need to develop (since they already existed). We recommend it highly.

## Test your key

FIXME the explore page

## Using graphql (GQL)

On your own service backend, querying the data via graphql is straight-forward (if you understand GQL). We do not have expertise with GQL, but it is essentially an endpoint that lets you submit queries as JSON documents. On our team, we have used [GraphiQL](https://www.electronjs.org/apps/graphiql) as an open source application for testing queries before embedding them into applications.

Here is an example query:

```
{
  items {
    wifi_v1(filter: {fcfs_seq_id:{_eq:"<THESEQID>"}, device_tag: {_eq: "<THETAG>"}}) {
		device_tag
        session_id
        event_id
        manufacturer_index
        patron_index
    }
  }
}
```

This query will, when executed, return an array of objects (or an empty array). Each object will have five fields as specified in the query (`device_tag`, `session_id`, etc.). It will only return objects that meet the constraints; in this case, where the `fcfs_seq_id` is equal to the ID passed in, and the `device_tag` is similarly a match. (This is the `WHERE` clause of the query). There are additional constraints/filters that can be placed on a query, and we would refer you to the Directus documentation for more info. 

Once you have tested the query ([GraphiQL](https://www.electronjs.org/apps/graphiql)), you can embed it in your application as an HTTPS POST. Your target endpoint is (during the pilot) `https://api.data.gov/TEST/10x-imls/v1/graphql/`.

Here is an example from the client side in Javascript. (Do not embed your key in a Javascript application. You know this.)

```
    // Because of CORs, we need to pass the API key as a URL
    // parameter. The COR constraints can be lifted, but
    // for now we have chosen to leave them in place.
    function gqlUrl (key) {
        return `https://api.data.gov/TEST/10x-imls/v1/graphql/?api_key=${key}`;
    }

    // The query options need to wrap the query in an object.
    // That is, the JSON submitted to the server must have 
    // the form:
    //   { query: ... }
    // where the `...` is a valid query as assembled in 
    // GraphiQL or similar.
    function gqlOptions(query) {
        const options = {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                query: query
            })
        };
        return options;
    }

    // Here, we have parameterized the wifiQuery string
    // using several variables that were set earlier in the 
    // code. That code is not shown in this example; it
    // pulls the values from some text fields on a webpage.
    // It would be safe to embed query parameters in a page,
    // but not the key itself!
    var wifiQuery = `
    {
        items {
            wifi_v1(limit: ${SEARCH_LIMIT}, filter: {fcfs_seq_id:{_eq:"${fcfs_seq_id}"}, device_tag: {_eq: "${device_tag}"}}) {
                device_tag
                session_id
                event_id
                manufacturer_index
                patron_index
            }
        }
    }`;

    // Now we do the fetch, handling success and failure
    // as appropriate for the application at hand.
    await fetch(gqlUrl(api_key), gqlOptions(eventQuery))
        .then(res => res.json())
        .then(eventsResult)
        .catch(eventFailHandler);
```

In Python, Go, or any other language, the steps are the same:

1. Formulate and test a valid GQL query.
2. Wrap the query in a JSON object of the form `{query: ...}`
3. POST that query to `https://api.data.gov/TEST/10x-imls/v1/graphql/`

**The trailing slash on that URL matters**.

If the query is successful, you will get back something that looks like:

```
{ "data": 
    { "items": 
        "events_v1": [
            ... objects ...
        ]
    }
}
```

where `events_v1` will be whichever table you have queried; for the pilot, `events_v1` and `wifi_v1` are the only tables available. 

The objects returned will be JSON objects containing the fields you specified. If you only indicated you wanted `device_tag`, then each object will contain one field only: `device_tag`. 

**NOTE**: We have left the `pi_serial` field out of the results that come back from all queries; why? An over-abundance of caution. It is not PII (because we own the RPis in question, and it does not indicate anything about an *individual*), but we left it out of queries just the same. This applies to GQL and RESTful queries alike.

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

## That's It

In summary:

1. Obtain an API key from api.data.gov.
2. Formulate queries using GQL or RESTful `GET`s.
3. Process the resulting JSON.

