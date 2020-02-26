public class TestUptime {
	public String theResponse {get; set;}
	public List<Check> theChecks = new List<Check>();
	private Map<String, Check> mapNameToCheck = new Map<String, Check>();

	public void getData() {
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint('http://meyers:meyersllc123@162.209.38.121:3080/api/checks');
		req.setHeader('Content-Type','application/json');
		req.setMethod('GET');
		HttpResponse rsp = h.send(req);
		theResponse = String.valueOf(rsp.getBody());
		system.debug(rsp);

		JSONParser parser = JSON.createParser(rsp.getBody());
        String currentName = '';
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'name')) {
                // Get the value.
                parser.nextToken();
                // do something with it
                currentName = parser.getText();
                Check c = new Check();
                c.name = currentName;//parser.getText();
                mapNameToCheck.put(c.name, c);
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'isUp')) {
                // Get the value.
                parser.nextToken();
                // do something with it
                Check c = mapNameToCheck.get(currentName);
                Boolean up = parser.getBooleanValue();
                if (up == true) {
                	c.isUp = 'UP';
                } else {
                	c.isUp = 'DOWN';
                }
                mapNameToCheck.put(c.name, c);
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'availability')) {
                // Get the value.
                parser.nextToken();
                // do something with it
                Check c = mapNameToCheck.get(currentName);
                c.availability = parser.getDecimalValue().setScale(4).stripTrailingZeros();
                mapNameToCheck.put(c.name, c);
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'responseTime')) {
                // Get the value.
                parser.nextToken();
                // do something with it
                Check c = mapNameToCheck.get(currentName);
                c.responseTime = parser.getDecimalValue().setScale(2).stripTrailingZeros();
                mapNameToCheck.put(c.name, c);
            }
        }
        theChecks.clear();
        theChecks.addAll(mapNameToCheck.values());
        theChecks.sort();
	}


	private class Check implements Comparable {
		public String name {get; set;}
		public String isUp {get; set;}
		public Decimal availability {get; set;}
        public Decimal responseTime {get; set;}

		public Integer compareTo(Object compareTo) {
	        Check check = (Check) compareTo;
	        if (Name == check.Name) return 0;
	        if (Name > check.Name) return 1;
	        return -1;        
	    }
	}

	public List<Check> getTheChecks() {
		return theChecks;
	}
}