global class BatchGoogleIntegrationHelper implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
	List<Id> theIncomingIds = new List<Id>();
	String theEntityType;
	String query;
	
	global BatchGoogleIntegrationHelper(List<Id> projectIdsThatNeedUpdates) {
		theEntityType = 'Project__c';
		theIncomingIds = projectIdsThatNeedUpdates;
		query = 'SELECT Id FROM Project__c WHERE Id IN :theIncomingIds';
	}

	global BatchGoogleIntegrationHelper(List<Id> entityIdsThatNeedUpdates, String entityType) {
		theEntityType = entityType;
		theIncomingIds = entityIdsThatNeedUpdates;
		if (entityType == 'Land_Listing__c') {
			query = 'SELECT Id FROM Land_Listing__c WHERE Id IN :theIncomingIds';
		} else if (entityType == 'Project__c') {
			query = 'SELECT Id FROM Project__c WHERE Id IN :theIncomingIds';
        } else if (entityType == 'Account'){
            query = 'SELECT Id FROM Account WHERE Id IN :theIncomingIds';
        } else if (entityType == 'Contact'){
            query = 'SELECT Id FROM Contact WHERE Id IN :theIncomingIds';
        }
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		if (theEntityType == 'Project__c') {
   			GoogleIntegrationHelper.UpdateProjectFieldsFromGoogle(scope);
		} else if (theEntityType == 'Land_Listing__c') {
			GoogleIntegrationHelper.UpdateLandListingFieldsFromGoogle(scope);
        } else if (theEntityType == 'Account'){
            GoogleIntegrationHelper.UpdateAccountFieldsFromGoogle(scope);
        }else if (theEntityType == 'Contact'){
            GoogleIntegrationHelper.UpdateContactFieldsFromGoogle(scope);
        }
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}