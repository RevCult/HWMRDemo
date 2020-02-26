@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {      
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "results" : [ { "address_components" : [ { "long_name" : "11211", "short_name" : "11211", "types" : [ "postal_code" ] }, { "long_name" : "Brooklyn", "short_name" : "Brooklyn", "types" : [ "political", "sublocality", "sublocality_level_1" ] }, { "long_name" : "New York", "short_name" : "New York", "types" : [ "locality", "political" ] }, { "long_name" : "New York", "short_name" : "NY", "types" : [ "administrative_area_level_1", "political" ] }, { "long_name" : "United States", "short_name" : "US", "types" : [ "country", "political" ] } ], "formatted_address" : "Brooklyn, NY 11211, USA", "geometry" : { "bounds" : { "northeast" : { "lat" : 40.7280089, "lng" : -73.9207299 }, "southwest" : { "lat" : 40.7008331, "lng" : -73.9644697 } }, "location" : { "lat" : 40.7093358, "lng" : -73.9565551 }, "location_type" : "APPROXIMATE", "viewport" : { "northeast" : { "lat" : 40.7280089, "lng" : -73.9207299 }, "southwest" : { "lat" : 40.7008331, "lng" : -73.9644697 } } }, "place_id" : "ChIJvbEjlVdZwokR4KapM3WCFRw", "types" : [ "postal_code" ] } ], "status" : "OK" }') ;                   
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
}