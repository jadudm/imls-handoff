
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
            wifi_v1(limit: ${SEARCH_LIMIT}, 
                    filter: { fcfs_seq_id: {_eq: "${fcfs_seq_id}"}, 
                              device_tag:  {_eq: "${device_tag}"}
                    ) {
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
