public class FC_InstanceUtils {
    
    private static final Map<Integer, Integer> PART_LENGTH_TO_INDEX_MAP = new Map<Integer, Integer> { 3 => 0, 5 => 1 };
        
	// Returns the Salesforce Instance that is currently being run on,
 	// e.g. na12, cs5, etc.
	public static String instance {
    	get {
            if (instance == null) {
                //
                // Possible Scenarios:
                //
                // (1) ion--test1--nexus.cs0.visual.force.com  --- 5 parts, Instance is 2nd part
                // (2) na12.salesforce.com      --- 3 parts, Instance is 1st part
                // (3) ion.my.salesforce.com    --- 4 parts, Instance is not determinable
    
                // Split up the hostname using the period as a delimiter
                List<String> parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api','').split('\\.');
                Integer indexLocation = PART_LENGTH_TO_INDEX_MAP.get(parts.size());
                if (indexLocation != null) {
                    instance = parts[indexLocation];
                }
            } 
            return instance;
        } 
        private set;
    }

	// And you can then get the Salesforce base URL like this:
	public static String getBaseUrlForInstance() {
		return 'https://' + instance + '.salesforce.com';
	}
    
}