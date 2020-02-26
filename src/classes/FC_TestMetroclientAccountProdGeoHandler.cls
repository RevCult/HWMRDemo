@isTest
private class FC_TestMetroclientAccountProdGeoHandler {

    @isTest
    private static void testInsert() {
        fcf.TriggerHandlerSettings.enable('FC_MetroclientAccountProductGeoHandler');
        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [
                select Id
                from Zuora__SubscriptionProductCharge__c
                where Zuora__ChargeNumber__c = 'SPC-1'
                limit 1
        ];

        Test.startTest();
        MetroclientAccountProductGeography__c testMetroclientAccountProductGeography =
                new MetroclientAccountProductGeography__c(Name = 'MAPG-1', ChargeNumber__c = 'SPC-1');
        insert testMetroclientAccountProductGeography;
        Test.stopTest();

        System.assertEquals(testSubscriptionProductCharge.Id, [select Charge__c from MetroclientAccountProductGeography__c where Id = :testMetroclientAccountProductGeography.Id].Charge__c);
    }

    @isTest
    private static void testUpdate() {
        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [
                select Id
                from Zuora__SubscriptionProductCharge__c
                where Zuora__ChargeNumber__c = 'SPC-1'
                limit 1
        ];

        MetroclientAccountProductGeography__c testMetroclientAccountProductGeography =
                new MetroclientAccountProductGeography__c(Name = 'MAPG-1');
        insert testMetroclientAccountProductGeography;

        System.assertEquals(null, [select Charge__c from MetroclientAccountProductGeography__c where Id = :testMetroclientAccountProductGeography.Id].Charge__c);
        fcf.TriggerHandlerSettings.enable('FC_MetroclientAccountProductGeoHandler');
        Test.startTest();
        testMetroclientAccountProductGeography.ChargeNumber__c = 'SPC-1';
        update testMetroclientAccountProductGeography;
        Test.stopTest();

        System.assertEquals(testSubscriptionProductCharge.Id, [select Charge__c from MetroclientAccountProductGeography__c where Id = :testMetroclientAccountProductGeography.Id].Charge__c);
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
                Zuora__ChargeNumber__c = 'SPC-1', Zuora__External_Id__c = 'SPC-1', Zuora__SubscriptionChargeNumber__c = 'SPC-1');
        insert testSubscriptionProductCharge;
    }

}