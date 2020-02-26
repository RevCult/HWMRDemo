@IsTest
private class FC_TestChargeMonthlyRevenueCleanerBatch {

    @IsTest
    private static void testBatchable() {
        System.assertEquals(2, [select count() from FC_Charge_Monthly_Revenue__c]);
        Test.startTest();
        Database.executeBatch(new FC_ChargeMonthlyRevenueCleanerBatchable(), 20);
        Test.stopTest();
        System.assertEquals(1, [select count() from FC_Charge_Monthly_Revenue__c]);

    }

    @TestSetup
    private static void setup() {
        FC_Charge_Monthly_Revenue_Settings__c testSettings = new FC_Charge_Monthly_Revenue_Settings__c(
                SetupOwnerId = UserInfo.getOrganizationId(), Active_Import_Process_ID__c = 'TEST1');
        upsert testSettings;

        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '10069', Override_Billing_Address_Information__c = true);
        insert testAccount;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today(),
                Zuora__TermSettingType__c = 'TERMED', Zuora__External_Id__c = 'S-1', Zuora__Zuora_Id__c = 'S-1');
        insert testSubscription;

        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge =
                new Zuora__SubscriptionProductCharge__c(Name = 'C-1',
                        Zuora__Subscription__c = testSubscription.Id, Zuora__Type__c = 'Recurring',
                        Zuora__SubscriptionChargeNumber__c = 'C-1', Zuora__Zuora_Id__c = 'C-1');
        insert testSubscriptionProductCharge;

        FC_Charge_Monthly_Revenue__c[] testChargeMonthlyRevenues = new FC_Charge_Monthly_Revenue__c[]{
                new FC_Charge_Monthly_Revenue__c(Import_Process_Id__c = 'TEST1', Rate_Plan_Charge__c = testSubscriptionProductCharge.Id),
                new FC_Charge_Monthly_Revenue__c(Import_Process_Id__c = 'TEST2', Rate_Plan_Charge__c = testSubscriptionProductCharge.Id)
        };
        insert testChargeMonthlyRevenues;

    }
}