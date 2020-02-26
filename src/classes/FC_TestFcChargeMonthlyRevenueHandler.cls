@IsTest
private class FC_TestFcChargeMonthlyRevenueHandler {

    @IsTest
    private static void testInsert() {

        fcf.TriggerHandlerSettings.enable('FC_FcChargeMonthlyRevenueHandler');
        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [
                select Id
                from Zuora__SubscriptionProductCharge__c
                where Zuora__ChargeNumber__c = 'SPC-1'
                limit 1
        ];

        Test.startTest();
        FC_Charge_Monthly_Revenue__c testChargeMonthlyRevenue = new FC_Charge_Monthly_Revenue__c(Charge_Number__c = 'SPC-1');
        insert testChargeMonthlyRevenue;
        Test.stopTest();

        System.assertEquals(testSubscriptionProductCharge.Id, [
                select Rate_Plan_Charge__c
                from FC_Charge_Monthly_Revenue__c
                where Id = :testChargeMonthlyRevenue.Id
        ].Rate_Plan_Charge__c);
    }

    @IsTest
    private static void testUpdate() {
        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [
                select Id
                from Zuora__SubscriptionProductCharge__c
                where Zuora__ChargeNumber__c = 'SPC-1'
                limit 1
        ];

        FC_Charge_Monthly_Revenue__c testChargeMonthlyRevenue = new FC_Charge_Monthly_Revenue__c(Charge_Number__c = 'SPC-1',
                Rate_Plan_Charge__c = testSubscriptionProductCharge.Id);
        insert testChargeMonthlyRevenue;


        fcf.TriggerHandlerSettings.enable('FC_FcChargeMonthlyRevenueHandler');
        Test.startTest();
        testChargeMonthlyRevenue.Charge_Number__c = 'SPC-1';
        update testChargeMonthlyRevenue;
        Test.stopTest();

        System.assertEquals(testSubscriptionProductCharge.Id, [
                select Rate_Plan_Charge__c
                from FC_Charge_Monthly_Revenue__c
                where Id = :testChargeMonthlyRevenue.Id
        ].Rate_Plan_Charge__c);
    }


    @TestSetup
    private static void setup() {
        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '10069', Override_Billing_Address_Information__c = true);
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