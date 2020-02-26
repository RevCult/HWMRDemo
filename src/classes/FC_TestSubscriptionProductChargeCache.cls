@isTest
private class FC_TestSubscriptionProductChargeCache {

    @isTest
    private static void testFindByIds() {
        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [select Id, Zuora__External_Id__c
                from Zuora__SubscriptionProductCharge__c where Zuora__External_Id__c = 'SPC-1'];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<ID, Zuora__SubscriptionProductCharge__c> results = FC_SubscriptionProductChargeCache.findByIds(new Set<ID> { testSubscriptionProductCharge.Id });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Zuora__External_Id__c, results.get(testSubscriptionProductCharge.Id).Zuora__External_Id__c);
        System.assertEquals(1, Limits.getQueries());
        results = FC_SubscriptionProductChargeCache.findByIds(new Set<ID> { testSubscriptionProductCharge.Id });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Zuora__External_Id__c, results.get(testSubscriptionProductCharge.Id).Zuora__External_Id__c);
        System.assertEquals(1, Limits.getQueries());

        FC_SubscriptionProductChargeCache.clearCache();
        results = FC_SubscriptionProductChargeCache.findByIds(new Set<ID> { testSubscriptionProductCharge.Id });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Zuora__External_Id__c, results.get(testSubscriptionProductCharge.Id).Zuora__External_Id__c);
        System.assertEquals(2, Limits.getQueries());

        Test.stopTest();
    }

    @isTest
    private static void testFindByChargeNumbers() {
        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [select Id, Zuora__ChargeNumber__c
                from Zuora__SubscriptionProductCharge__c where Zuora__ChargeNumber__c = 'SPC-1'];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<String, Zuora__SubscriptionProductCharge__c> results = FC_SubscriptionProductChargeCache.findByChargeNumbers(new Set<String> { testSubscriptionProductCharge.Zuora__ChargeNumber__c });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Id, results.get(testSubscriptionProductCharge.Zuora__ChargeNumber__c).Id);
        System.assertEquals(1, Limits.getQueries());
        results = FC_SubscriptionProductChargeCache.findByChargeNumbers(new Set<String> { testSubscriptionProductCharge.Zuora__ChargeNumber__c });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Id, results.get(testSubscriptionProductCharge.Zuora__ChargeNumber__c).Id);
        System.assertEquals(1, Limits.getQueries());

        FC_SubscriptionProductChargeCache.clearCache();
        results = FC_SubscriptionProductChargeCache.findByChargeNumbers(new Set<String> { testSubscriptionProductCharge.Zuora__ChargeNumber__c });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Id, results.get(testSubscriptionProductCharge.Zuora__ChargeNumber__c).Id);
        System.assertEquals(2, Limits.getQueries());

        Test.stopTest();
    }

    @isTest
    private static void testFindBySubscriptionZuoraIds() {
        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [select Id, Zuora__External_Id__c
                from Zuora__SubscriptionProductCharge__c where Zuora__External_Id__c = 'SPC-1'];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<String, Set<Zuora__SubscriptionProductCharge__c>> results = FC_SubscriptionProductChargeCache.findBySubscriptionZuoraIds(new Set<String> { 'S-1' });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Zuora__External_Id__c, new List<Zuora__SubscriptionProductCharge__c>(results.get('S-1'))[0].Zuora__External_Id__c);
        System.assertEquals(1, Limits.getQueries());
        results = FC_SubscriptionProductChargeCache.findBySubscriptionZuoraIds(new Set<String> { 'S-1' });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Zuora__External_Id__c, new List<Zuora__SubscriptionProductCharge__c>(results.get('S-1'))[0].Zuora__External_Id__c);
        System.assertEquals(1, Limits.getQueries());

        FC_SubscriptionProductChargeCache.clearCache();
        results = FC_SubscriptionProductChargeCache.findBySubscriptionZuoraIds(new Set<String> { 'S-1' });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Zuora__External_Id__c, new List<Zuora__SubscriptionProductCharge__c>(results.get('S-1'))[0].Zuora__External_Id__c);
        System.assertEquals(2, Limits.getQueries());
        Test.stopTest();
    }

    @isTest
    private static void testFindBySubscriptionIds() {
        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [select Id, Zuora__Subscription__c
                from Zuora__SubscriptionProductCharge__c where Zuora__External_Id__c = 'SPC-1'];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, Set<Zuora__SubscriptionProductCharge__c>> results = FC_SubscriptionProductChargeCache.findBySubscriptionIds(new Set<Id> { testSubscriptionProductCharge.Zuora__Subscription__c });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Zuora__Subscription__c, new List<Zuora__SubscriptionProductCharge__c>(results.get(testSubscriptionProductCharge.Zuora__Subscription__c))[0].Zuora__Subscription__c);
        System.assertEquals(1, Limits.getQueries());
        results = FC_SubscriptionProductChargeCache.findBySubscriptionIds(new Set<Id> { testSubscriptionProductCharge.Zuora__Subscription__c });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Zuora__Subscription__c, new List<Zuora__SubscriptionProductCharge__c>(results.get(testSubscriptionProductCharge.Zuora__Subscription__c))[0].Zuora__Subscription__c);
        System.assertEquals(1, Limits.getQueries());

        FC_SubscriptionProductChargeCache.clearCache();
        results = FC_SubscriptionProductChargeCache.findBySubscriptionIds(new Set<Id> { testSubscriptionProductCharge.Zuora__Subscription__c});
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Zuora__Subscription__c, new List<Zuora__SubscriptionProductCharge__c>(results.get(testSubscriptionProductCharge.Zuora__Subscription__c))[0].Zuora__Subscription__c);
        System.assertEquals(2, Limits.getQueries());
        Test.stopTest();
    }
    
    @isTest
    private static void testFindByBillingAccountIds() {
        Zuora__CustomerAccount__c testCustomerAccount = [select Id, Zuora__External_Id__c from Zuora__CustomerAccount__c
                where Zuora__External_Id__c = 'A-1' limit 1];
        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [select Id, Zuora__External_Id__c
                from Zuora__SubscriptionProductCharge__c where Zuora__External_Id__c = 'SPC-1'];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, Set<Zuora__SubscriptionProductCharge__c>> results = FC_SubscriptionProductChargeCache.findByBillingAccountIds(new Set<Id> { testCustomerAccount.Id });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Zuora__External_Id__c, new List<Zuora__SubscriptionProductCharge__c>(results.get(testCustomerAccount.Id))[0].Zuora__External_Id__c);
        System.assertEquals(1, Limits.getQueries());
        results = FC_SubscriptionProductChargeCache.findByBillingAccountIds(new Set<Id> { testCustomerAccount.Id });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Zuora__External_Id__c, new List<Zuora__SubscriptionProductCharge__c>(results.get(testCustomerAccount.Id))[0].Zuora__External_Id__c);
        System.assertEquals(1, Limits.getQueries());

        FC_SubscriptionProductChargeCache.clearCache();
        results = FC_SubscriptionProductChargeCache.findByBillingAccountIds(new Set<Id> { testCustomerAccount.Id });
        System.assertEquals(1, results.size());
        System.assertEquals(testSubscriptionProductCharge.Zuora__External_Id__c, new List<Zuora__SubscriptionProductCharge__c>(results.get(testCustomerAccount.Id))[0].Zuora__External_Id__c);
        System.assertEquals(2, Limits.getQueries());
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
                Zuora__External_Id__c = 'S-1');
        insert testSubscription;

        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = new Zuora__SubscriptionProductCharge__c(
                Name = 'SPC-1', Zuora__Account__c = testAccount.Id, Zuora__Subscription__c = testSubscription.Id,
                Zuora__ChargeNumber__c = 'SPC-1', Zuora__SubscriptionChargeNumber__c = 'SPC-1', Zuora__External_Id__c = 'SPC-1');
        insert testSubscriptionProductCharge;
    }

}