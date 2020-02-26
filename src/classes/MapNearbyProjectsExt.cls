global class MapNearbyProjectsExt {

	private final Project__c theProject;

    public MapNearbyProjectsExt(ApexPages.StandardController stdController) {
        this.theProject = (Project__c)stdController.getRecord();
    }

    @RemoteAction
    // Find projects nearest a geolocation
    global static List<Project__c> getNearby(String lat, String lon) {

        // If geolocation isn't set, use San Francisco
        if(lat == null || lon == null || lat.equals('') || lon.equals('')) {
            lat = '37.77493';
            lon = '-122.419416';
        }

        // SOQL query to get the nearest warehouses
        String queryString =
            'SELECT Id, Name, Location__Longitude__s, Location__Latitude__s, ' +
                'Status__c, Phone_Number__c, City__c ' +
            'FROM Project__c ' +
            'WHERE DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') < 20 ' +
            'ORDER BY DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') ' +
            'LIMIT 200';

        // Run and return the query results
        return(database.Query(queryString));
    }
}