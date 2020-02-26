@isTest
private class FC_TestZuoraCustomerAccountHandler {

    @isTest
    private static void testUpdate() {

        Test.startTest();
        Zuora__CustomerAccount__c testCustomerAccount = [select Id, Seg2_Description__c from Zuora__CustomerAccount__c where Zuora__External_Id__c = 'A-1' limit 1];
        System.assert(String.isBlank(testCustomerAccount.Seg2_Description__c));
        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [select Id, Seg2_Description__c from Zuora__SubscriptionProductCharge__c where Zuora__External_Id__c = 'SPC-1' limit 1];
        testSubscriptionProductCharge.Segment2__c = '0';
        testSubscriptionProductCharge.Segment2_Market_Name__c = 'Test';
        update testSubscriptionProductCharge;
        update testCustomerAccount;
        testCustomerAccount = [select Id, Seg2_Description__c from Zuora__CustomerAccount__c where Zuora__External_Id__c = 'A-1' limit 1];
        testSubscriptionProductCharge = [select Id, Seg2_Description__c from Zuora__SubscriptionProductCharge__c where Zuora__External_Id__c = 'SPC-1' limit 1];
        System.assertEquals(testSubscriptionProductCharge.Seg2_Description__c, testCustomerAccount.Seg2_Description__c);
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
                Zuora__ChargeNumber__c = 'SPC-1', Zuora__External_Id__c = 'SPC-1');
        insert testSubscriptionProductCharge;

        fcf.TriggerHandlerSettings.enable('FC_ZuoraCustomerAccountHandler');
    }

}