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
https://developer.expediapartnersolutions.com/documentation/rapid-content-docs-2-4/
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

### Shopping API
The EPS Rapid Shopping API provides you with access to live rates and availability for over 500,000 properties globally.
https://developer.expediapartnersolutions.com/documentation/rapid-shopping-docs-2-4/
#### Methods
```ruby
EpsRapid::Content.availability(occupancy: '2-9,4;2-8,6', property_id: '12345,567899', country_code: 'US', sales_environment: 'hotel_package', sales_channel: 'website', checkin: '2021-05-01', checkout: '2021-05-03', currency: 'USD', rate_plan_count: '1')
```
Returns rates on available room types for specified properties (maximum of 250 properties per request). The response includes rate details such as promos, whether the rate is refundable, cancellation penalties and a full price breakdown to meet the price display requirements for your market.
Note: If there are no available rooms, the response will be an empty array.
Multiple rooms of the same type may be requested by including multiple instances of the `occupancy` parameter.
The `nightly` array includes each individual night’s charges. When the total price includes fees, charges, or adjustments that are not divided by night, these amounts will be included in the stay rate array, which details charges applied to the entire stay (each check-in).

Method accept arguments:
- `checkin` Check-in date, in ISO 8601 format (YYYY-MM-DD).
Required: true.
- `checkout` Check-out date, in ISO 8601 format (YYYY-MM-DD). Availability can be searched up to 500 days in advance of this date. Total length of stay cannot exceed 28 nights.
Required: true.
- `currency` Requested currency for the rates, in ISO 4217 format. Currency Options: https://developer.expediapartnersolutions.com/reference/currency-options/
Required: true.
- `country_code` The country code of the traveler’s point of sale, in ISO 3166-1 alpha-2 format. This should represent the country where the shopping transaction is taking place. For more information see: https://www.iso.org/obp/ui/#search/code/ .
Required: true.
- `occupancy` Defines the requested occupancy for a single room. Each room must have at least 1 adult occupant.
Format: `numberOfAdults[-firstChildAge[,nextChildAge]]`
To request multiple rooms (of the same type), include one instance of occupancy for each room requested. Up to 8 rooms may be requested or booked at once. Examples:
1) 2 adults, one 9-year-old and one 4-year-old would be represented by `occupancy=2-9,4`.
2) A multi-room request to lodge an additional 2 adults would be represented by `occupancy=2-9,4;occupancy=2`.
Required: true.
- `property_id` The ID of the property you want to search for. You can provide 1 to 250 property_id parameters.
Required: true.
- `sales_channel` You must provide the sales channel for the display of rates. EPS dynamically provides the best content for optimal conversion on each sales channel. If you have a sales channel that is not currently supported in this list, please contact our support team.
1) `website` - Standard website accessed from the customer’s computer
2) `agent_tool` - Your own agent tool used by your call center or retail store agent
3) `mobile_app` - An application installed on a phone or tablet device
4) `mobile_web` - A web browser application on a phone or tablet device
5) `meta` - Rates will be passed to and displayed on a 3rd party comparison website
6) `cache` - Rates will be used to populate a local cache.
Required: true.
- `sales_environment` You must provide the sales environment in which rates will be sold. EPS dynamically provides the best content for optimal conversion. If you have a sales environment that is not currently supported in this list, please contact our support team.
1) `hotel_package` - Use when selling the hotel with a transport product, e.g. flight & hotel.
2) `hotel_only` - Use when selling the hotel as an individual product.
3) `loyalty` - Use when you are selling the hotel as part of a loyalty program and the price is converted to points.
Required: true.
- `filter` Single filter type. Send multiple instances of this parameter to request multiple filters.
1) `refundable` - Filters results to only show fully refundable rates.
2) `expedia_collect` - Filters results to only show rates where payment is collected by Expedia at the time of booking. These properties can be eligible for payments via Expedia Affiliate Collect(EAC).
3) `property_collect` - Filters results to only show rates where payment is collected by the property after booking. This can include rates that require a deposit by the property, dependent upon the deposit policies.
Required: false.
- `rate_plan_count` The number of rates to return per property. The rate’s price determines which rates are returned e.g. a rateplancount=4 will return the lowest 4 rates, but the rates are not ordered from lowest to highest or vice versa in the response. The lowest rate has been proven to provide the best conversion rate and so a value of 1 is recommended.
The value must be greater than 0.
Required: true.
- `rate_option` Request specific rate options for each property. Send multiple instances of this parameter to request multiple rate options.
Accepted values:
1) `member` - Return member rates for each property. This feature must be enabled and requires a user to be logged in to request these rates.
2) `net_rates` - Return net rates for each property. This feature must be enabled to request these rates.
3) `cross_sell` - Identify if the traffic is coming from a cross sell booking. Where the traveler has booked another service (flight, car, activities…) before hotel.
Required: false.
- 'test' Shop calls have a test header that can be used to return set responses with the following keywords: https://developer.expediapartnersolutions.com/reference/rapid-shopping-test-request/ under keyword `Shop`.
Required: false.

```ruby
EpsRapid::Shopping.price_check('properties/599536/rooms/201125633/rates/234071214?token=C~Oj46Zz8xJD', test: 'matched')
```
Confirms the price returned by the Property Availability response. Use this API to verify a previously-selected rate is still valid before booking. If the price is matched, the response returns a link to request a booking. If the price has changed, the response returns new price details and a booking link for the new price. If the rate is no longer available, the response will return a new Property Availability request link to search again for different rates. In the event of a price change, go back to Property Availability and book the property at the new price or return to additional rates for the property.
Method accept two arguments:
- `path` A link to price check, should be taken from `availability` response under key `...{'links': {'price_check': {'href': 'price check link'}` without EPS API version in the path.
Required: true.
- `test` Price check calls have a test header that can be used to return set responses with the following keywords: https://developer.expediapartnersolutions.com/reference/rapid-shopping-test-request/ under keyword `Price Check`.
Required: false.

```ruby
EpsRapid::Shopping.payment_options('properties/599536/payment-options?token=C~Oj46Zz8xJD')
```
Returns the accepted payment options. Use this API to power your checkout page and display valid forms of payment, ensuring a smooth booking.
Method accept one argument:
- `path` A link to payment options, should be taken from `availability` response under key `...{'links': {'payment_options': {'href': 'payment options link'}` without EPS API version in the path.
Required: true.

```ruby
EpsRapid::Shopping.deposit_policies('properties/12345/deposit-policies?token=REhZAQsABAE', test: 'all')
```
This link will be available in the shop response when rates require a deposit. It returns the amounts and dates for when any deposits are due. Deposit information is obtained by making a deposit-policies API call using this link.
Method accept two arguments:
- `path` A link to deposit policy, should be taken from `availability` response under key `...{'links': {'deposit_policies': {'href': 'deposit policies link'}` without EPS API version in the path.
Required: true.
- `test` Deposit Policy calls have a test header that can be used to return set responses with the following keywords: https://developer.expediapartnersolutions.com/reference/rapid-shopping-test-request/ under keyword `Deposit Policy`.
Required: false.

```ruby
EpsRapid::Shopping.additional_rates('properties/12345/availability?token=REhZAQsAB')
```
Returns additional rates.
Method accept one argument:
- `path` A link to additional rates, should be taken from `availability` response under key `...{'links': {'additional_rates': {'href': 'additional rates link'}` without EPS API version in the path.
Required: true.

```ruby
EpsRapid::Shopping.recommendation_rates('properties/12345/availability?token=REhZAQsAB')
```
Returns recommendation rates.
Method accept one argument:
- `path` A link to recommendation rates, should be taken from `availability` response under key `...{'links': {'recommendations': {'href': 'additional rates link'}` without EPS API version in the path.
Required: true.

### Booking API
The EPS Rapid Booking API allows you to book rooms & rates confirmed by the price check response.
https://developer.expediapartnersolutions.com/documentation/rapid-booking-docs-2-4/
#### Methods
```ruby
EpsRapid::Booking.register_payment('payment-sessions?token=ABSDBV', {version": "1", "browser_accept_header": "*/*", ...}, customer_ip: '127.0.0.1')
```
This method only applies to transactions where EPS takes the customer’s payment information. This includes both Expedia Collect and Property Collect transactions.
This link will be available in the Price Check response if payment registration is required. It returns a payment session ID and a link to create a booking. This will be the first step in the booking flow only if you’ve opted into Two-Factor Authentication to comply with the September 2019 EU Regulations for PSD2.
Method accept arguments:
- `path` A link to open payment session. This link will be available in the Price Check response if payment registration is required.
Required: true.
- `body` Json object. Requirements check under `PaymentSessionsRequestBody` in https://developer.expediapartnersolutions.com/documentation/rapid-booking-docs-2-4/#/Booking/post_payment_sessions .
Required: true.
- `customer_ip` IP address of the customer, as captured by your integration. Send IPV4 addresses only. Ensure your integration passes the customer’s IP, not your own. This value helps determine their location and assign the correct payment gateway.
Required: true.

```ruby
EpsRapid::Booking.create_booking('itineraries/7562428514179?token=QldfCGlcUA4DVVhW', {affiliate_reference_id: "4480ABC", hold: false, email: "john@example.com",...}, customer_ip: '127.0.0.1')
```
The link will be available in the Price Check response or in the register payments response when Two-Factor Authentication is used. It returns an itinerary id and links to retrieve reservation details, cancel a held booking, resume a held booking or complete payment session. Please note that depending on the state of the booking, the response will contain only the applicable link(s).
Method accept arguments:
- `path` A link to create booking, should be taken from `EpsRapid::Shopping.price_check` response under key `...{'links': {'book': {'href': 'create booking link'}` without EPS API version in the path.
Required: true.
- `body` Json object. Requirements check under `ItineraryRequestBody` in https://developer.expediapartnersolutions.com/documentation/rapid-booking-docs-2-4/#/Booking/post_itineraries
Required: true.
- `customer_ip` IP address of the customer, as captured by your integration. Send IPV4 addresses only. Ensure your integration passes the customer’s IP, not your own. This value helps determine their location and assign the correct payment gateway.
Required: true.

```ruby
EpsRapid::Booking.resume_booking('itineraries/7562428514179?token=ABE3TYUj23', customer_ip: '127.0.0.1')
```
This link will be available in the booking response after creating a held booking.
Method accept arguments:
- `path` A link to resume booking, should be taken from `EpsRapid::Booking.create_booking` response under key `href` from `...{'links': [{'rel': 'resume', method: 'put', 'href': 'resume booking link'}]}` without EPS API version in the path.
Required: true.
- `customer_ip` IP address of the customer, as captured by your integration. Send IPV4 addresses only. Ensure your integration passes the customer’s IP, not your own. This value helps determine their location and assign the correct payment gateway.
Required: true.

```ruby
EpsRapid::Booking.complete_payment_session('itineraries/7562428514179/payment-sessions?token=ABE3TYUj23', customer_ip: '127.0.0.1')
```
This link will be available in the booking response only if you’ve opted into Two-Factor Authentication to comply with the September 2019 EU Regulations for PSD2.
Method accept arguments:
- `path` A link to complete payment session.
Required: true.
- `customer_ip` IP address of the customer, as captured by your integration. Send IPV4 addresses only. Ensure your integration passes the customer’s IP, not your own. This value helps determine their location and assign the correct payment gateway.
Required: true.

### Manage Booking API
The EPS Rapid Manage Booking API allows you to discover how to use the Retrieve, Change and Cancel API calls to manage existing itineraries.
https://developer.expediapartnersolutions.com/documentation/rapid-manage-booking-docs-2-4/
#### Methods
```ruby
EpsRapid::ManageBooking.retrieve_bookings(email: 'test@example.com', affiliate_reference_id: '4480ABCQXCZS', customer_ip: '127.0.0.1')
```
This can be called directly without a token when an affiliate reference id is provided. It returns details about bookings associated with an affiliate reference id, along with cancel links to cancel the bookings.
Method accept arguments:
- `email` Email associated with the booking.
Required: true
- `affiliate_reference_id` The affilliate reference id value. This field supports a maximum of 28 characters.
Required: true.
- `customer_ip` IP address of the customer, as captured by your integration. Send IPV4 addresses only. Ensure your integration passes the customer’s IP, not your own. This value helps determine their location and assign the correct payment gateway.
Required: true.

```ruby
EpsRapid::ManageBooking.retrieve_booking('7372514319381', token: 'ABDE34Tj', email: 'test@example.com', customer_ip: '127.0.0.1')
```
This call returns itinerary details and links to resume or cancel the booking.
Method accept arguments:
- `itinerary_id` This parameter is used only to prefix the token value - no ID value is used.
Required: true.
- `token` Provided as part of the link object and used to maintain state across calls. This simplifies each subsequent call by limiting the amount of information required at each step and reduces the potential for errors. Token values cannot be viewed or changed.
Required: false.
- `email` Email associated with the booking.
Required: true if the token is not provided the request.
- `customer_ip` IP address of the customer, as captured by your integration. Send IPV4 addresses only. Ensure your integration passes the customer’s IP, not your own. This value helps determine their location and assign the correct payment gateway.
Required: true.

```ruby
EpsRapid::ManageBooking.cancel_held_booking('itineraries/7562428514179?token=ABE3TYUj23', customer_ip: '127.0.0.1')
```
This link will be available in a held booking response.
Method accept arguments:
- `path` A link to cancel held booking, should be taken from `retrieve` response under key `...{'links': {'cancel': {'href': 'cancel booking link'}` without EPS API version in the path.
Required: true.
- `customer_ip` IP address of the customer, as captured by your integration. Send IPV4 addresses only. Ensure your integration passes the customer’s IP, not your own. This value helps determine their location and assign the correct payment gateway.
Required: true.

```ruby
EpsRapid::ManageBooking.cancel_room('itineraries/7372514319381/rooms/512dab07-c9b7-494c-a517-05763aed4768?token=QFlCEVhQR', customer_ip: '127.0.0.1')
```
This link will be available in the retrieve response.
Method accept arguments:
- `path` A link to cancel room booking, should be taken from `retrieve` response under key `...{'links': {'cancel': {'href': 'cancel room link'}` without EPS API version in the path.
Required: true.
- `customer_ip` IP address of the customer, as captured by your integration. Send IPV4 addresses only. Ensure your integration passes the customer’s IP, not your own. This value helps determine their location and assign the correct payment gateway.
Required: true.

```ruby
EpsRapid::ManageBooking.change_room('itineraries/7372514319381/rooms/512dab07-c9b7-494c-a517-05763aed4768?token=QFlCEVhQR', {given_name: 'Jhon', family_name: 'Smith', ...}, customer_ip: '127.0.0.1')
```
This link will be available in the retrieve response. Changes in smoking preference and special request will be passed along to the property and are not guaranteed.
Method accept arguments:
- `path` A link to cancel room booking, should be taken from `retrieve` response under key `...{'links': {'change': {'href': 'cancel room link'}` without EPS API version in the path.
Required: true.
- `body` Json object. Requirements check under `RoomDetailsRequestBody` in https://developer.expediapartnersolutions.com/documentation/rapid-manage-booking-docs-2-4/#/Manage_Bookings/put_itineraries__itinerary_id__rooms__room_id_
Required: true.
- `customer_ip` IP address of the customer, as captured by your integration. Send IPV4 addresses only. Ensure your integration passes the customer’s IP, not your own. This value helps determine their location and assign the correct payment gateway.
Required: true.

### Recommendations API
Data-driven personalized property recommendations.
https://developer.expediapartnersolutions.com/documentation/rapid-recommendations-2-4/
#### Methods
```ruby
EpsRapid::Recommendations.recommendations(checkin: '2021-05-20', checkout: '2021-05-22', destination_iata_airport_code: 'SEA', currency: 'USD', country_code: 'US', occupancy: '2', sales_channel: 'website', sales_environment: 'hotel_package', rate_plan_count: 1)
```
Calculates recommended properties based on the provided flight itinerary. Returns a sorted list of available properties; the first property in the response is the “strongest recommendation”. For each property, rates on available room types for properties is returned.
Method accept arguments:
- `checkin` Check-in date, in ISO 8601 format (YYYY-MM-DD).
Required: true.
- `checkout` Check-out date, in ISO 8601 format (YYYY-MM-DD). Availability can be searched up to 500 days in advance of this date. Total length of stay cannot exceed 28 nights.
Required: true.
- `destination_iata_airport_code' 3-character IATA airport code of the destination airport. The code must be upper case.
Required: true.
- `origin_iata_airport_code` 3-character IATA airport code of the origin airport. The code must be upper case.
Required: false.
- `cabin_class` The cabin class of the ticket. Use the highest cabin class if the journey inclues multiple cabin classes.
Accepted values:
1) `economy` - Economy cabin class.
2) `premium_economy` - Premium economy cabin class.
3) `business` - Business cabin class.
4) `first` - First cabin class.
Required: false.
- `iata_airline_code` 2-character IATA airline code.
Required: false.
- `arrival` Arrival date and time, in extended ISO 8601 format.
Required: false.
- `currency` Requested currency for the rates, in ISO 4217 format. Currency Options: https://developer.expediapartnersolutions.com/reference/currency-options/
Required: true.
- `country_code` The country code of the traveler’s point of sale, in ISO 3166-1 alpha-2 format. This should represent the country where the shopping transaction is taking place. For more information see: https://www.iso.org/obp/ui/#search/code/ .
Required: true.
- `occupancy` Defines the requested occupancy for a single room. Each room must have at least 1 adult occupant.
Format: `numberOfAdults[-firstChildAge[,nextChildAge]]`
To request multiple rooms (of the same type), include one instance of occupancy for each room requested. Up to 8 rooms may be requested or booked at once. Examples:
1) 2 adults, one 9-year-old and one 4-year-old would be represented by `occupancy=2-9,4`.
2) A multi-room request to lodge an additional 2 adults would be represented by `occupancy=2-9,4;occupancy=2`.
Required: true.
- `sales_channel` You must provide the sales channel for the display of rates. EPS dynamically provides the best content for optimal conversion on each sales channel. If you have a sales channel that is not currently supported in this list, please contact our support team.
1) `website` - Standard website accessed from the customer’s computer
2) `agent_tool` - Your own agent tool used by your call center or retail store agent
3) `mobile_app` - An application installed on a phone or tablet device
4) `mobile_web` - A web browser application on a phone or tablet device
5) `meta` - Rates will be passed to and displayed on a 3rd party comparison website
6) `cache` - Rates will be used to populate a local cache.
Required: true.
- `sales_environment` You must provide the sales environment in which rates will be sold. EPS dynamically provides the best content for optimal conversion. If you have a sales environment that is not currently supported in this list, please contact our support team.
1) `hotel_package` - Use when selling the hotel with a transport product, e.g. flight & hotel.
2) `hotel_only` - Use when selling the hotel as an individual product.
3) `loyalty` - Use when you are selling the hotel as part of a loyalty program and the price is converted to points.
Required: true.
- `filter` Single filter type. Send multiple instances of this parameter to request multiple filters.
1) `refundable` - Filters results to only show fully refundable rates.
2) `expedia_collect` - Filters results to only show rates where payment is collected by Expedia at the time of booking. These properties can be eligible for payments via Expedia Affiliate Collect(EAC).
3) `property_collect` - Filters results to only show rates where payment is collected by the property after booking. This can include rates that require a deposit by the property, dependent upon the deposit policies.
Required: false.
- `rate_plan_count` The number of rates to return per property. The rate’s price determines which rates are returned e.g. a rateplancount=4 will return the lowest 4 rates, but the rates are not ordered from lowest to highest or vice versa in the response. The lowest rate has been proven to provide the best conversion rate and so a value of 1 is recommended.
The value must be greater than 0.
Required: true.
- `rate_option` Request specific rate options for each property. Send multiple instances of this parameter to request multiple rate options.
Accepted values:
1) `member` - Return member rates for each property. This feature must be enabled and requires a user to be logged in to request these rates.
2) `net_rates` - Return net rates for each property. This feature must be enabled to request these rates.
3) `cross_sell` - Identify if the traffic is coming from a cross sell booking. Where the traveler has booked another service (flight, car, activities…) before hotel.
Required: false.