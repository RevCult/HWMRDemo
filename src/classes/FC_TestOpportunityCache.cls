@isTest
private class FC_TestOpportunityCache {

    @isTest
    private static void testClearCache() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, Opportunity> results = FC_OpportunityCache.findByIds(new Set<Id>{
                testOpportunity.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_OpportunityCache.findByIds(new Set<Id>{
                testOpportunity.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        FC_OpportunityCache.clearCache();
        results = FC_OpportunityCache.findByIds(new Set<Id>{
                testOpportunity.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(2, Limits.getQueries());
        Test.stopTest();
    }

    @isTest
    private static void testFindByIds() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, Opportunity> results = FC_OpportunityCache.findByIds(new Set<Id>{
                testOpportunity.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_OpportunityCache.findByIds(new Set<Id>{
                testOpportunity.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();
    }
    
    @testSetup
    private static void setup() {

        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '12345');
        insert testAccount;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',
                AccountId = testAccount.Id, Amount = 100,
                StageName = 'New Opportunity', CloseDate = Date.today());
        insert testOpportunity;

    }

}