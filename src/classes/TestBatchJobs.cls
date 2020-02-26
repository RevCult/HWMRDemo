@isTest
private class TestBatchJobs { 
	static void setupTestData() {
		Account a1 = new Account(
			Name = 'the account'
		,	Industry = 'Other'
		, BillingPostalCode='560028'
			);
		insert a1;
		 
		Builder__c b1 = new Builder__c(
			Name = 'the builder'
		);
		insert b1;

		Data_User__c du1 = new Data_User__c(
			Name = 'test user'
			);
		insert du1;

		Project__c p1 = new Project__c(
			Name = 'the project'
		,	Builder__c = b1.Id
		,	Data_User__c = du1.Id
		,	Open_Date__c = Date.newInstance(2015, 1, 1)
		,	Total_Units_Planned__c = 90
		,	Total_Units_Sold__c = 20
			);
		insert p1;

		Project__c p2 = new Project__c(
			Name = 'the other project'
		,	Builder__c = b1.Id
		,	Data_User__c = du1.Id
			);
		insert p2;

		Project_Contact__c pc1 = new Project_Contact__c(
			Name = 'the guy'
		,	Project__c = p1.Id
			);
		insert pc1;

		Plan__c plan1 = new Plan__c(
			Name = 'the plan'
		,	Project__c = p1.Id
			);
		insert plan1;

		p1.Total_Units_Sold__c = 25;
		update p1;
	}
	
	
	@isTest static void testBatchDeleteSusbcriberActivity() {
		BatchDeleteSubscriberActivity theBatch = new BatchDeleteSubscriberActivity();
		Database.executeBatch(theBatch);
	}
	
	@isTest static void testBatchMaintProjectFields() {
        
		setupTestData();
		Project__c p1 = [SELECT Id, Total_Units_Planned__c, Total_Units_Sold__c FROM Project__c LIMIT 1];
		p1.Total_Units_Sold__c = 30;
		update p1;
		BatchMaintProjectFields theBatch = new BatchMaintProjectFields();
		Database.executeBatch(theBatch);
	}
    public static testMethod void testschedule() {
         Test.StartTest();
             BatchMaintProjectFields testsche = new BatchMaintProjectFields();
             String sch = '0 0 23 * * ?';
             system.schedule('Test status Check', sch, testsche );
       Test.stopTest();
    }
	
}