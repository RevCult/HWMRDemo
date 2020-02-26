@isTest
private class TestTriggers {
	static void setupTestData() { 
		
        Account a1 = new Account(
			Name = 'the account'
		,	Industry = 'Other'
		,	BillingPostalCode ='560029'
			);
		insert a1;
        
        Account a2 = new Account(
			Name = 'the other account'
		,	Industry = 'Other'
		,	BillingPostalCode ='560029'
			);
		insert a2;
        
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
		,	Total_Units_Planned__c = 40
		,	Total_Units_Sold__c = 0
			);
		insert p1;

		Project__c p2 = new Project__c(
			Name = 'the other project'
		,	Builder__c = b1.Id
		,	Data_User__c = du1.Id
		,	Total_Units_Planned__c = 40
		,	Total_Units_Sold__c = 0
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

		Land_Listing__c listing1 = new Land_Listing__c(
			Name = 'the listing'
		,	County__c = 'San Diego'
		,	Location__Latitude__s = 33
		,	Location__Longitude__s = -78
		,	State__c = 'CA'
		,	Zip__c = '92129'
			);
		insert listing1;

		Land_Listing__c listing2 = new Land_Listing__c(
			Name = 'the listing'
		,	County__c = 'San Diego'
		,	Location__Latitude__s = 33
		,	Location__Longitude__s = -78
		,	State__c = 'CA'
		,	Zip__c = '92129'
			);
		insert listing2;

		Land_Listing__c listing3 = new Land_Listing__c(
			Name = 'the listing'
		,	County__c = 'San Diego'
		,	Location__Latitude__s = 33
		,	Location__Longitude__s = -78
		,	State__c = 'CA'
		,	Zip__c = '92129'
			);
		insert listing3;
	}
	
	@isTest static void TestProjectTrigger() {
		setupTestData();
		Project__c theProject = [SELECT Id, Website__c, Name, Total_Units_Planned__c, Total_Units_Sold__c FROM Project__c LIMIT 1];
		theProject.Name = 'updated!!!!!';
		theProject.Website__c = 'http://www.google.com';
		theProject.Total_Units_Sold__c = 2;
        theProject.Update_Cycle__c = '27';
		update theProject;
		List<Project__c> allTheProjects = [SELECT Id, Website__c, Name FROM Project__c];
		update allTheProjects;

		theProject = [SELECT Id, Website__c, Name FROM Project__c WHERE Name = 'the other project' LIMIT 1];
		delete theProject;
	}
    
	@isTest static void TestProjectTriggerGoogleBatch() {
        // Create test accounts to be updated by batch
        List<Project__c> lstProject = new List<project__c>();
        for(Integer i=0; i<10; i++){
            Project__c p = new Project__c();
            p.Name = 'Name'+i;
            p.Website__c = 'http://www.google.com';
            p.Location__Latitude__s = 33;
            p.Location__Longitude__s = -78;
            lstProject.add(p);
        }
        Test.startTest();
        	insert lstProject;
        Test.stopTest();
    }

	@isTest static void TestPlanTrigger() {
		setupTestData();
		Project__c theProject = [SELECT Id, Name FROM Project__c LIMIT 1];
		Plan__c thePlan = [SELECT Id, Name, Price__c FROM Plan__c LIMIT 1];
		thePlan.Name = 'updated!!!!!';
		thePlan.Price__c = 500;
		update thePlan;
	}

	@isTest static void TestBuilderTrigger() {
		setupTestData();
		Builder__c theBuilder = [SELECT Id, Name, Account__c FROM Builder__c LIMIT 1];
		update theBuilder;
		Account theAccount = [SELECT Id FROM Account LIMIT 1];
		theBuilder.Account__c = theAccount.Id;
		update theBuilder;

		delete theBuilder;
	}

	@isTest static void TestLandListingTrigger() {
		setupTestData();
		Land_Listing__c theListing = [SELECT Id, Listing_URL__c, Name FROM Land_Listing__c LIMIT 1];
		theListing.Name = 'updated!!!!!';
		theListing.Listing_URL__c = 'http://www.google.com';
		update theListing;
		List<Land_Listing__c> allTheListings = [SELECT Id, Listing_URL__c, Name FROM Land_Listing__c];
		update allTheListings;
	}

    @isTest static void TestAccountTrigger() {
		setupTestData();
		Account theAccount = [SELECT Id, Name, Industry, BillingPostalCode FROM Account LIMIT 1];
		theAccount.Name = 'Updated Account';
        theAccount.Industry = 'Other';
        theAccount.BillingPostalCode = '02474';
		update theAccount;
        
        List<Account> allTheAccounts = [SELECT Id, Name, Industry, BillingPostalCode FROM Account];
        update allTheAccounts;
	}
    
	@isTest static void TestAccountTriggerGoogleBatch() {
        // Create test accounts to be updated by batch
        List<Account> lstAccount = new List<Account>();
        for(Integer i=0; i<10; i++){
            Account a = new Account();
            a.Name = 'Name'+i;
            a.Industry = 'Other';
            a.BillingPostalCode ='10123';
            lstAccount.add(a);
        }
        Test.startTest();
        	insert lstAccount;
        Test.stopTest();
    }
    
}