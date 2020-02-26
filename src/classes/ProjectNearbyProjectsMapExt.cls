public class ProjectNearbyProjectsMapExt {
    private final Project__c project;
    public string prjid {get;set;}
    public ProjectNearbyProjectsMapExt(ApexPages.StandardController stdController) {
        this.project = (Project__c)stdController.getRecord();
        if(apexpages.currentPage().getparameters().get('id') != null)
        	prjid = [select id from project__c where id=:apexpages.currentPage().getparameters().get('id')].id;
    }

    public String getFoo() {
        return(project.Name + 'foo');
    }

    public List<Project__c> getNearbyProjects() {
        String lat = String.valueOf(project.Location__Latitude__s);
        String lon = String.valueOf(project.Location__Longitude__s);
		        
        // SOQL query to get the nearest projects
        String queryString; 
        if(lat!=null &&lon!=null){
        queryString= 'SELECT Id, Name, Location__Longitude__s, Location__Latitude__s, ' +
                'Status__c, Phone_Number__c, City__c ' +
            'FROM Project__c ' +
            'WHERE DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') < 20 ' +
            'ORDER BY DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') ' +
            'LIMIT 25';
			system.debug(queryString);
        }	else{
        
        		queryString= 'SELECT Id, Name, Location__Longitude__s, Location__Latitude__s, ' +
                'Status__c, Phone_Number__c, City__c ' +
            'FROM Project__c limit 1';
        }
        // Run and return the query results
        return(database.Query(queryString));
    }
}