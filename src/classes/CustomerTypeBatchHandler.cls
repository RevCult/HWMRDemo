/************************************************************************
*
* @description	CustomerTypeBatchHandler - Updates Account Customer Type fields
* @author		10KView
* @date			2nd June 2017
*
*************************************************************************/

global class CustomerTypeBatchHandler implements Database.Batchable<sObject> {

	global final String Query;


	global CustomerTypeBatchHandler() {
		 	Query = 'SELECT Id FROM Account';
		        
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(Query);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope) {
		
		ManageCustomerType.UpdateCustomerType((List<Account>)scope);
	}

	global void finish(Database.BatchableContext BC) {	
		// Nothing to do here
	
	}

}