public without sharing class BuilderProjectMgmtCmn {

	public static Set<String> getProjectFields() {
		Set<String> objectFields = new Set<String>();

		Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Project__c.fields.getMap();
		for(String fieldName : mapFields.keySet()) {
		   if(mapFields.get(fieldName).getDescribe().isUpdateable()) {
		       objectFields.add(fieldName.toLowerCase());
		   }
		}
		return objectFields;
	}

	public static Set<String> getProjectUpdateRequestFields() {
		Set<String> objectFields = new Set<String>();

		Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Project_Update_Request__c.fields.getMap();
		for(String fieldName : mapFields.keySet()) {
		   if(mapFields.get(fieldName).getDescribe().isUpdateable()) {
		       objectFields.add(fieldName.toLowerCase());
		   }
		}
		return objectFields;
	}

	public static Map<String, String> getProjectToPURFieldMap() {
		Map<String, String> mapProjectFieldToPurPreviousField = new Map<String, String>();
		Set<String> projectFields = getProjectFields();
		Set<String> purFields = getProjectUpdateRequestFields();
		for (String projectFieldName : projectFields) {
			String previousFieldName = 'previous_'+projectFieldName;
			if (purFields.contains(previousFieldName)) {
				mapProjectFieldToPurPreviousField.put(projectFieldName, previousFieldName);
			}
		}

		return mapProjectFieldToPurPreviousField;
	}

	public static String getUserType(String userId) {
		Schema.DescribeSObjectResult r = Data_User__c.sObjectType.getDescribe();
		String dataUserPrefix = r.getKeyPrefix();
		
		r = User.sObjectType.getDescribe();
		String userPrefix = r.getKeyPrefix();

		r = Project_Contact__c.sObjectType.getDescribe();
		String projectContactPrefix = r.getKeyPrefix();

		String currentUserPrefix = userId.left(3);
		
		if (currentUserPrefix == dataUserPrefix) {
			return 'dataUser';
		} else if (currentUserPrefix == userPrefix) {
			return 'user';
		} else if (currentUserPrefix == projectContactPrefix) {
			return 'projectContact';
		} else {
			return 'unknown';
		}
	}

	public static String getUserName(String userId) {
		String userType = getUserType(userId);
		if (userType == 'dataUser') {
			Data_User__c theUser = [SELECT Name FROM Data_User__c WHERE Id = :userId LIMIT 1];
			if (null != theUser) {
				return theUser.Name;	
			} else {
				return 'user not found';
			}
		} else if (userType == 'user') {
			User theUser = [SELECT Name FROM User WHERE Id = :userId LIMIT 1];
			if (null != theUser) {
				return theUser.Name;	
			} else {
				return 'user not found';
			}
		} else if (userType == 'projectContact') {
			Project_Contact__c theUser = [SELECT Name FROM Project_Contact__c WHERE Id = :userId LIMIT 1];
			if (null != theUser) {
				return theUser.Name;	
			} else {
				return 'user not found';
			}
		} else {
			return 'unknown';	
		}
	}

	public static List<Project_Update_Request__c> getProjectUpdateRequests(Set<Id> purIDs) {
		List<Project_Update_Request__c> thePURs = new List<Project_Update_Request__c>();

		String query = 'SELECT';
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Project_Update_Request__c').getDescribe().fields.getMap();
		 
		// Grab the fields from the describe method and append them to the query string one by one.
		for(String s : objectFields.keySet()) {
		   query += ' ' + s + ', ';
		}
		 
		// Strip off the last comma if it exists.
		if (query.subString(query.Length()-2,query.Length()) == ', '){
		    query = query.subString(0,query.Length()-2);
		}
		 
		// Add FROM statement
		query += ' FROM Project_Update_Request__c WHERE Id IN :purIDs';
		system.debug('query: '+query);
		thePURs = Database.Query(query);

		return thePURs;
	}

	public static List<Project__c> getProjects(Set<Id> projectIds) {
		List<Project__c> theProjects = new List<Project__c>();

		String query = 'SELECT';
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Project__c').getDescribe().fields.getMap();
		 
		// Grab the fields from the describe method and append them to the query string one by one.
		for(String s : objectFields.keySet()) {
		   query += ' ' + s + ', ';
		}
		 
		// Strip off the last comma if it exists.
		if (query.subString(query.Length()-2,query.Length()) == ', '){
		    query = query.subString(0,query.Length()-2);
		}
		 
		// Add FROM statement
		query += ' FROM Project__c WHERE Id IN :projectIds';
		system.debug('query: '+query);
		theProjects = Database.Query(query);

		return theProjects;
	}
}