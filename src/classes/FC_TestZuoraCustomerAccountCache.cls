@isTest
private class FC_TestZuoraCustomerAccountCache {

    @isTest
    private static void testFindByIds() {
        
        Zuora__CustomerAccount__c testCustomerAccount = [select Id, Zuora__External_Id__c 
                from Zuora__CustomerAccount__c where Zuora__External_Id__c = 'A-1' limit 1];    
        
        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<ID, Zuora__CustomerAccount__c> results = FC_ZuoraCustomerAccountCache.findByIds(new Set<Id> { testCustomerAccount.Id });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_ZuoraCustomerAccountCache.findByIds(new Set<Id> { testCustomerAccount.Id });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();
        
    }
    
    @isTest
    private static void testFindByZuoraIds() {
        
        Zuora__CustomerAccount__c testCustomerAccount = [select Id, Zuora__External_Id__c 
                from Zuora__CustomerAccount__c where Zuora__External_Id__c = 'A-1' limit 1];    
        
        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<String, Zuora__CustomerAccount__c> results = FC_ZuoraCustomerAccountCache.findByZuoraIds(new Set<String> { testCustomerAccount.Zuora__External_Id__c });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_ZuoraCustomerAccountCache.findByZuoraIds(new Set<String> { testCustomerAccount.Zuora__External_Id__c });
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
        
    }
    
}