@isTest
private class FC_TestAccountHandler {

    @isTest
    private static void testInsert() {

        Account testAccount6 = [select Id, FC_Ultimate_Parent_Account__c from Account where Name = 'Test Account 6' limit 1];
        Account testAccount = [select Id, FC_Ultimate_Parent_Account__c from Account where Name = 'Test Account' limit 1];

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_AccountHandler'
        });

        Test.startTest();

        Account testAccount7 = new Account(Name = 'Test Account 7', ParentId = testAccount6.Id, Parent__c = true, BillingPostalCode = '12345');
        insert testAccount7;

        Test.stopTest();

        testAccount7 = [select Id, FC_Ultimate_Parent_Account__c from Account where Name = 'Test Account 7' limit 1];
        System.assertNotEquals(null, testAccount7.FC_Ultimate_Parent_Account__c);
        System.assertEquals(testAccount6.FC_Ultimate_Parent_Account__c, testAccount7.FC_Ultimate_Parent_Account__c);
        System.assertEquals(testAccount.Id, testAccount7.FC_Ultimate_Parent_Account__c);

    }

    @isTest
    private static void testUpdate() {

        Account testAccount = [select Id, Has_Active_Subscription__c from Account where Name = 'Test Account' limit 1];

        System.assertEquals(false, testAccount.Has_Active_Subscription__c);

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_AccountHandler'
        });

        Test.startTest();

        update testAccount;

        Test.stopTest();

        testAccount = [select Id, Has_Active_Subscription__c from Account where Name = 'Test Account' limit 1];

        System.assertEquals(true, testAccount.Has_Active_Subscription__c);

    }

    @testSetup
    private static void setup() {

        Account testAccount = new Account(Name = 'Test Account', Has_Active_Subscription__c = false, BillingPostalCode = '12345', Parent__c = true);
        insert testAccount;

        Account testAccount1 = new Account(Name = 'Test Account 1', FC_Ultimate_Parent_Account__c = testAccount.Id,
                Has_Active_Subscription__c = false, ParentId = testAccount.Id, BillingPostalCode = '12345', Parent__c = true);
        insert testAccount1;

        Account testAccount2 = new Account(Name = 'Test Account 2', FC_Ultimate_Parent_Account__c = testAccount.Id,
                Has_Active_Subscription__c = false, ParentId = testAccount1.Id, BillingPostalCode = '12345', Parent__c = true);
        insert testAccount2;

        Account testAccount3 = new Account(Name = 'Test Account 3', FC_Ultimate_Parent_Account__c = testAccount.Id,
                Has_Active_Subscription__c = false, ParentId = testAccount2.Id, BillingPostalCode = '12345', Parent__c = true);
        insert testAccount3;

        Account testAccount4 = new Account(Name = 'Test Account 4', FC_Ultimate_Parent_Account__c = testAccount.Id,
                Has_Active_Subscription__c = false, ParentId = testAccount3.Id, BillingPostalCode = '12345', Parent__c = true);
        insert testAccount4;

        Account testAccount5 = new Account(Name = 'Test Account 5', FC_Ultimate_Parent_Account__c = testAccount.Id,
                Has_Active_Subscription__c = false, ParentId = testAccount4.Id, BillingPostalCode = '12345', Parent__c = true);
        insert testAccount5;

        Account testAccount6 = new Account(Name = 'Test Account 6', FC_Ultimate_Parent_Account__c = testAccount.Id,
                Has_Active_Subscription__c = false, ParentId = testAccount5.Id, BillingPostalCode = '12345', Parent__c = true);
        insert testAccount6;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__Status__c = 'Active');
        insert testSubscription;

    }

}