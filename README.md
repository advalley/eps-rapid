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
https://developer.expediapartnersolutions.com/documentation/rapid-geography-docs-2-4/
#### Methods
```ruby
EpsRapid::Geography.regions_list(ancestor_id: 2, include: 'standard, property_ids')
```
Returns the geographic definition and property mappings of regions matching the specified parameters.

Method accept two arguments:
- `ancestor_id` ID of the ancestor of regions to retrieve. Refer to the list of top level of regions https://developer.expediapartnersolutions.com/reference/geography-reference-lists-2-2/ .
Required: false.
- `include` Options for which content to return in the response. This parameter can be supplied multiple times with different values. The standard and details options cannot be requested together. The value must be lower case. Supported values: `standard, details, property_ids, property_ids_expanded`.
Required: false, default: 'standard'.

```ruby
EpsRapid::Geography.region(602962, include: 'details, property_ids')
```
Returns the geographic definition and property mappings for the requested Region ID. The response is a single JSON formatted region object.

Method accept two arguments:
- `region_id` ID of the region to retrieve.
Required: true.
- `include` Options for which content to return in the response. This parameter can be supplied multiple times with different values. The value must be lower case. Supported values: `details, property_ids, property_ids_expanded`.
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

### Content API
The EPS Rapid Content APIs provide you with access to content for all of EPS’s properties.
https://developer.expediapartnersolutions.com/documentation/rapid-content-docs-2-4/#/Content/get_properties_content
#### Methods
```ruby
EpsRapid::Content.content_list(property_id: '123456, 2345678', brand_id: '12345, 23456', business_model: 'expedia_collect')
```
Search property content for active properties in the requested language.
When searching with query parameter, property_id, you may request 1 to 250 properties at a time.
Method accept arguments:
- `brand_id` The ID of the brand you want to search for. This parameter can be supplied multiple times with different values, which will include properties that match any of the requested brand IDs.
Required: false.
- `business_model` Search for properties with the requested business model enabled. This parameter can be supplied multiple times with different values, which will return all properties that match any of the requested business models. The value must be lower case.
Required: false.
- `category_id_exclude` Search to exclude properties that do not have the requested category ID - https://developer.expediapartnersolutions.com/reference/content-reference-lists-2-4/. If this parameter is not supplied, all category IDs are included. This parameter can be supplied multiple times with different values, which will exclude properties that match any of the requested category IDs.
Required: false.
- `chain_id` The ID of the chain you want to search for. These chain IDs can be positive and negative numbers. This parameter can be supplied multiple times with different values, which will include properties that match any of the requested chain IDs.
Required: false.
- `country_code` Search for properties with the requested country code, in ISO 3166-1 alpha-2 format. This parameter can be supplied multiple times with different values, which will include properties that match any of the requested country codes.
Required: false.
- `date_added_end` Search for properties added on or before the requested UTC date, in ISO 8601 format (YYYY-MM-DD).
Required: false.
- `date_added_start` Search for properties added on or after the requested UTC date, in ISO 8601 format (YYYY-MM-DD).
Required: false.
- `date_updated_end` Search for properties updated on or before the requested UTC date, in ISO 8601 format (YYYY-MM-DD).
Required: false.
- `date_updated_start` Search for properties updated on or after the requested UTC date, in ISO 8601 format (YYYY-MM-DD).
Required: false.

```ruby
EpsRapid::Content.guest_review(123456)
```
Note: Property Guest Reviews are only available if your account is configured for access and all launch requirements have been followed. Please find the launch requirements here https://support.expediapartnersolutions.com/hc/en-us/articles/360008646799 and contact your Account Manager for more details.
The response is an individual Guest Reviews object containing up to 10 guest reviews for the requested active property.
To ensure you always show the latest guest reviews, this call should be made whenever a customer looks at the details for a specific property.

Method accept one argument:
- `property_id` Expedia Property ID.
Required: true.

```ruby
EpsRapid::Content.catalog_file
```
Returns a link to download the master list of EPS’s active properties in the requested language. The response includes high-level details about each property.

```ruby
EpsRapid::Content.content_file
```
Returns a link to download all content for all of EPS’s active properties in the requested language. The response includes property-level, room-level and rate-level information.

```ruby
EpsRapid::Content.chains
```
Returns a complete collection of chains recognized by the Rapid API.
Chains represent a parent company which can have multiple brands associated with it. A brand can only be associated with one chain. For example, Hilton Worldwide is a chain that has multiple associated brands including Doubletree, Hampton Inn and Embassy Suites.
The response is a JSON map where the key is the chain ID and the value is a chain object. Each chain object also contains a map of its related brands.
Note that the set of chain IDs and brand IDs are totally independent of one another. It is possible for a chain and a brand to both use the same number as their ID, but this is just a coincidence that holds no meaning.
Chain and brand names are provided in English only.
