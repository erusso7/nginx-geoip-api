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

### How to start your own Geo-API

#### Method 1: Only using the docker image
```
docker run --rm -d -p 80:80 \
	-e MAXMIND_ACCOUNT="<your_maxmind_account>" \
	-e MAXMIND_KEY="<your_maxmind_key>" \
	-e MAXMIND_PRODUCTS="GeoIP2-City" \
	-e JOB_SCHEDULE="0 10 * * 2,4,7" \
	erusso/nginx-geoip-api
```

#### Method 2: From Github repository
1. `git clone https://github.com/erusso7/nginx-geoip-api && cd nginx-geoip-api`
1. [**required**]: Set the `MAXMIND_ACCOUNT` & `MAXMIND_KEY` variables.
1. Build the docker image: `make build`
1. Start the service: `make run`. You can customize:
    1. `PORT` Your local port where the service will be published _(default `80`)_
    1. `JOB_SCHEDULE` Using cron syntax you can change how often you want to check for updates.
    1. `MAXMIND_PRODUCTS` Which Maxmind database you want to use _(default `GeoLite2-City`)_

#### Examples:
- Check the status of the database: `curl http://127.0.0.1/_status`
 ```json
{
    "build": 1607405176,
    "last_check": 1607445787,
    "last_change": 1607445787
}
```
- Check information for a given ip: `curl -H 'x-forwarded-for: 37.223.5.39' http://127.0.0.1`

> You **MUST** add the `x-forwarded-for` header with the client real IP,
otherwise it will return the information of the direct client.

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