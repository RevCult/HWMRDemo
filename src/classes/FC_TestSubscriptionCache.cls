@isTest
private class FC_TestSubscriptionCache {

    @isTest
    private static void testClearCache() {

        Zuora__Subscription__c testSubscription = [
                select Id
                from Zuora__Subscription__c
                where Zuora__SubscriptionNumber__c = 'S-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, Zuora__Subscription__c> results = FC_SubscriptionCache.findByIds(new Set<Id>{
                testSubscription.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_SubscriptionCache.findByIds(new Set<Id>{
                testSubscription.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        FC_SubscriptionCache.clearCache();
        results = FC_SubscriptionCache.findByIds(new Set<Id>{
                testSubscription.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(2, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByIds() {

        Zuora__Subscription__c testSubscription = [
                select Id
                from Zuora__Subscription__c
                where Zuora__SubscriptionNumber__c = 'S-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, Zuora__Subscription__c> results = FC_SubscriptionCache.findByIds(new Set<Id>{
                testSubscription.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_SubscriptionCache.findByIds(new Set<Id>{
                testSubscription.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindBySubscriptionNumber() {

        Zuora__Subscription__c testSubscription = [
                select Id, Zuora__SubscriptionNumber__c
                from Zuora__Subscription__c
                where Zuora__SubscriptionNumber__c = 'S-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<String, Zuora__Subscription__c> results = FC_SubscriptionCache.findBySubscriptionNumber(new Set<String>{
                testSubscription.Zuora__SubscriptionNumber__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_SubscriptionCache.findBySubscriptionNumber(new Set<String>{
                testSubscription.Zuora__SubscriptionNumber__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByAccountIds() {

        Zuora__Subscription__c testSubscription = [
                select Id, Zuora__Account__c
                from Zuora__Subscription__c
                where Zuora__SubscriptionNumber__c = 'S-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, Set<Zuora__Subscription__c>> results = FC_SubscriptionCache.findByAccountIds(new Set<Id>{
                testSubscription.Zuora__Account__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_SubscriptionCache.findByAccountIds(new Set<Id>{
                testSubscription.Zuora__Account__c
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
                Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today(),
                Zuora__SubscriptionNumber__c = 'S-1');
        insert testSubscription;
    }
}