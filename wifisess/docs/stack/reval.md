# ReVal

[ReVal](https://github.com/18F/ReVAL) (Reusable Validation Library) is a [Django](https://www.djangoproject.com/) application for validating data via an API and web interface. ReVal was originally  developed for the USDA FNS (Food and Nutrition Service) Data Validation Service in order to [validate National School Lunch and Breakfast data](https://18f.gsa.gov/2020/04/23/saving-time-and-improving-data-quality-for-the-national-school-lunch-breakfast-program/).

We have configured our ReVal instance, called [Rabbit](https://github.com/cantsin/10x-rabbit/), to be a stateless validation application deployed on [cloud.gov](https://cloud.gov/) at `10x-rabbit-demo.app.cloud.gov`.

## Configuration

Rabbit provides one endpoint: `/validate/<collection>/`. The only action allowed is `POST`. This endpoint takes an arbitrary array of JSON data, grabs the corresponding [validation schema](https://github.com/18F/ReVAL/blob/master/docs/customize.md) for that collection from the [Directus](https://directus.io/) host given, validates data against the schema, and returns the result of validation, successful or otherwise.

Rabbit requires three HTTP headers:

- `X-Magic-Header`: secret key for the rabbit instance
- `X-Directus-Host`: Directus host (currently `10x-rabbit-data.app.cloud.gov`)
- `X-Directus-Token`: Directus token

Errors from the Directus instance (if any) will be returned verbatim. Otherwise, the endpoint returns a standard [ReVal validation object in JSON](https://github.com/18F/ReVAL/blob/master/docs/api.md#validation).

## Usage

We proxy all `api.data.gov` requests through Rabbit for validation purposes: the data must be a JSON array of predefined objects.

We use the following validation schemas: [`events`](https://github.com/cantsin/10x-rabbit/blob/main/validator-events.json) and [`wifi`](https://github.com/cantsin/10x-rabbit/blob/main/validator-wifi.json).

All Rabbit requests are also logged to a separate, generic Directus table. Should the data not pass validation, the resulting validation errors are also stored in a separate table.

The current `v1` schema is defined [here](https://github.com/cantsin/10x-rabbit/blob/main/directus_tables.sql).

To avoid abuse of any Rabbit endpoint, we mandate a secret key to be passed in via the `X-Magic-Header`. This header is set on the `api.data.gov` backend configuration.
