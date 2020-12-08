# GeoIP2 API

A very simple API built with NGINX + GoeIP2 module to provide geolocation information from the IP 

##### TO-DO:

- Finish makefile with CI tasks.
- travis.yml
- documentation
- implement the endpoint for cities
- auto-update the database binary 
  
For the moment just copy the DB from Phoenix: 
```
cp <PHOENIX_PATH>/app/Resources/geoip/GeoIP2-Country.mmdb ./database/GeoIP2-Country.mmdb
```

### How it works? 
**NOTE:** You **MUST** add the header `x-forwarded-for` with the customer IP,
otherwise it will return the country for the direct client.

Make a `GET` request to the endpoint `/country` and it will return a `json` response with this payload:
```json
{
  "code": "US",
  "name": "United States"
}
```
