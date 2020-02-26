@isTest
private class FC_TestContractCache {

    @isTest
    private static void testClearCache() {

        Contract testContract = [
                select Id, AccountId, FC_Subscription_Number__c, FC_Subscription__c, FC_Price_Book__c
                from Contract
                where FC_Subscription_Number__c = 'S-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, Contract> results = FC_ContractCache.findByIds(new Set<Id>{
                testContract.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_ContractCache.findByIds(new Set<Id>{
                testContract.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        FC_ContractCache.clearCache();
        results = FC_ContractCache.findByIds(new Set<Id>{
                testContract.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(2, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByIds() {

        Contract testContract = [
                select Id, AccountId, FC_Subscription_Number__c, FC_Subscription__c, FC_Price_Book__c
                from Contract
                where FC_Subscription_Number__c = 'S-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, Contract> results = FC_ContractCache.findByIds(new Set<Id>{
                testContract.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_ContractCache.findByIds(new Set<Id>{
                testContract.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindBySubscriptionNumbers() {

        Contract testContract = [
                select Id, AccountId, FC_Subscription_Number__c, FC_Subscription__c, FC_Price_Book__c
                from Contract
                where FC_Subscription_Number__c = 'S-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<String, Contract> results = FC_ContractCache.findBySubscriptionNumbers(new Set<String>{
                testContract.FC_Subscription_Number__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_ContractCache.findBySubscriptionNumbers(new Set<String>{
                testContract.FC_Subscription_Number__c
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

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today());
        insert testSubscription;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',
                AccountId = testAccount.Id, Amount = 100,
                StageName = 'New Opportunity', CloseDate = Date.today());
        insert testOpportunity;

        Contract testContract = new Contract(AccountId = testAccount.Id, FC_Subscription_Number__c = 'S-1',
                FC_Subscription__c = testSubscription.Id, FC_Price_Book__c = Test.getStandardPricebookId());
        insert testContract;

    }

}