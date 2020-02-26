global class BatchMaintProjectFields implements Database.Batchable<sObject>, Schedulable {
	
	String query;

	// Schedulable Bit:
	global void execute(SchedulableContext SC) {
		BatchMaintProjectFields theBatch = new BatchMaintProjectFields();
		Database.executeBatch(theBatch);
	}

	// Batchable Bits:
	global BatchMaintProjectFields() {
		query = 'SELECT Id, Total_Units_Sold__c, Total_Units_Planned__c, Sales_Rate_Last_3_Months_calc__c, Open_Date__c, Sold_Out_Date__c, CreatedDate, Last_Updated_Date_Sales__c FROM Project__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Project__c> scope) {
   		List<Project__c> projectsToUpdate = MaintProjectFields.updateThreeMonthSalesRate(scope);
		if (null != projectsToUpdate && !projectsToUpdate.isEmpty()) {
			update projectsToUpdate;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}