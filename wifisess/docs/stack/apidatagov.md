# Overview

[api.data.gov](https://api.data.gov) provides free API management services for federal agencies. (The underlying framework is [API Umbrella](https://apiumbrella.io/)). We use this service primarily for managing users and API keys. Using an API layer in this way allows us to provide transparent and seamless (to the user) backend updates.

As a secondary benefit, we also get rate limiting and usage statistics.

Please note that all API calls to `api.data.gov` must have a `X-Api-Key` request header with a valid API key for the path in question. Otherwise, the user will get an `API_KEY_INVALID` response.

## Configuration

We have set up a predefined path at `/TEST/10x-imls/`.

To route the API call properly, we want to specify the Rabbit and Directus hosts to use. Since everything goes through Rabbit first (for validation purposes), we have configured Rabbit to read Directus configuration data via request headers.

- Our application sends a request to `api.data.gov/TEST/10x-imls/v1/` with the appropriate `X-Api-Key` header and key
- `api.data.gov` looks up `/TEST/10x-imls/`, and routes the request to our configuration
- `api.data.gov` looks up `/v1/` in our API backend list
    - The backend host is identified as `10x-rabbit-demo.app.cloud.gov`
    - Our "Global Request Settings" configuration tells `api.data.gov` to add these Rabbit-specific headers:
        - `X-Magic-Header`
        - `X-Directus-Host`
        - `X-Directus-Token`
        - `X-Directus-Schema-Version`
    - Finally, the modified request is proxied (passed on) to the backend host with the path `/validate/`

Thus, a request to `https://api.data.gov/TEST/10x-imls/v1/` is routed to `https://10x-rabbit-demo.app.cloud.gov/validate/` with additional headers.

## Updates

Currently we only offer the `/v1/` path, but further revisions to our server stack are quite likely. Should we add `/v2/` in the future, we will push an ansible update that configures our application to hit `/v2/` instead. Because the backend beyond `api.data.gov` is essentially invisible to the user, the new endpoint could use entirely new backend services if needed.
