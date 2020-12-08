# GeoIP2 API

A very simple API built with NGINX + GeoIP2 module to provide geolocation information based on an IP 

### Features

- Language agnostic with minimal dependencies (Nginx & GeoIP2 module)
- Support for these databases
    - GeoIP2-City
    - GeoIP2-Country 
    - GeoLite2-ASN 
    - GeoIP2-City 
    - GeoLite2-Country
- What info can you get? 
    - Continent
    - Country
    - City
    - Location (accuracy, latitude, altitude, time-zone)
- Customizable schedule for auto-update MMDB.

### Start your own Geo-API

1. **required**: Set the `MAXMIND_ACCOUNT` & `MAXMIND_KEY` variables.
1. *optional*: Set the `MAXMIND_PRODUCT` variable with the MMDB you want to use _(default GeoIP2-City)_
1. Build the docker image: `make build`
1. Start the service: `make run` _(default port `80`)_

#### Examples:
- Check the status of the database: `curl localhost/_status`
 ```json
{
    "build": 1607405176,
    "last_check": 1607445787,
    "last_change": 1607445787
}
```
- Check information for a given ip: `curl -H 'x-forwarded-for: 37.223.5.39' localhost`
```json
{
  "ip": "37.223.5.39",
  "continent": {
    "id": "6255148",
    "code": "EU",
    "name": "Europe"
  },
  "country": {
    "id": "2510769",
    "code": "ES",
    "name": "Spain"
  },
  "city": {
    "id": "3128760",
    "name": "Barcelona"
  },
  "location": {
    "accuracy_radius": "10",
    "latitude": "41.38880",
    "longitude": "2.15900",
    "time_zone": "Europe/Madrid"
  }
}
```

> You **MUST** add the `x-forwarded-for` header with the client real IP,
otherwise it will return the information of the direct client.