# Querying data

There are two interfaces for querying data: GraphQL and a RESTful interface. The API is being provided by [directus.io](https://directus.io/); therefore, the API documentation for Directus applies here, and reviewing it is worthwhile. Here, we will provide a high-level summary of how to extract data from the IMLS WIFISESS pilot.

## Obtain an API key

First, you will need an API key. Go to [api.data.gov's signup page](https://api.data.gov/signup/) and sign up for a key. Shortly after signup, you should receive an API key via email.

All requests are routed through api.data.gov. It provides us with a layer of security, key management, rate limiting, and other services we felt no need to develop (since they already existed). We recommend it highly.
