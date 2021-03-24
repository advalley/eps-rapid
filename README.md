# eps-rapid
Ruby gem for the eps-rapid 2.4 API

## Installation

Add this line to your application's Gemfile:

```ruby
 gem 'eps-rapid'
```

And then execute:

```$ bundle install```

## Configuration
```ruby
EpsRapid.configure do |c|
  c.api_key = 'YOUR_API_KEY'
  c.secret_key = 'YOUR_SECRET_KEY'
  c.base_path = 'BASE_PATH'
  c.language = 'en-US'
end
```
Base path depends of environment and can be `https://test.ean.com/2.4` or `https://api.ean.com/2.4`
Language is desired language for the response as a subset of BCP47 format that only uses hyphenated pairs of two-digit language and country codes. Supported languages: https://developer.expediapartnersolutions.com/reference/language-options/

### Geography API
The EPS Rapid Geography APIs provide you with access to geographic definitions and property mappings for over 600,000 regions and airports.
#### Methods
```ruby
EpsRapid::Geography.get_regions_list(2, 'standard, property_ids')
```
Returns the geographic definition and property mappings of regions matching the specified parameters.

Method accept two arguments:
- `ancestor_id` ID of the ancestor of regions to retrieve. Refer to the list of top level of regions https://developer.expediapartnersolutions.com/reference/geography-reference-lists-2-2/ .
Required: false, default: 0.
- `includes` Options for which content to return in the response. This parameter can be supplied multiple times with different values. The standard and details options cannot be requested together. The value must be lower case. Supported values: `standard, details, property_ids, property_ids_expanded`.
Required: false, default: 'standard'.

```ruby
EpsRapid::Geography.get_region(602962, 'details, property_ids')
```
Returns the geographic definition and property mappings for the requested Region ID. The response is a single JSON formatted region object.

Method accept two arguments:
- `region_id` ID of the region to retrieve.
Required: true.
- `includes` Options for which content to return in the response. This parameter can be supplied multiple times with different values. The value must be lower case. Supported values: `details, property_ids, property_ids_expanded`.
Required: false, default: 'details'.

```ruby
EpsRapid::Geography.create_polygon([[-93.446782, 37.169329],[-93.4244,37.169432]])
```
Returns the properties within an custom polygon that represents a multi-city area or smaller.
The coordinates of the polygon should be in GeoJSON format and the polygon must conform to the following restrictions:
Polygon size - diagonal distance of the polygon must be less than 500km
Polygon type - only single polygons are supported
Number of coordinates - must be <= 2000

Method accept one argument:
- `body` Array of coordinates.
Required: true.