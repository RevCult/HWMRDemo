@isTest
private class FC_TestContractHandler {

    @isTest
    private static void testInsert() {

        Account testAccount = [select Id from Account where Name = 'Test Account' limit 1];

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_ContractHandler'
        });

        Test.startTest();

        Contract testContract = new Contract(AccountId = testAccount.Id, FC_Subscription_Number__c = 'S-2',
                FC_Price_Book__c = Test.getStandardPricebookId());
        insert testContract;

        Test.stopTest();

        testContract = [
                select Id, AccountId, FC_Subscription_Number__c, FC_Subscription__c, FC_Subscription__r.Name,
                        FC_Price_Book__c
                from Contract
                where FC_Subscription_Number__c = 'S-2'
                limit 1
        ];

        System.assertNotEquals(null, testContract.FC_Subscription__c);
        System.assertEquals('S-2', testContract.FC_Subscription__r.Name);

    }

    @isTest
    private static void testUpdate() {

        Contract testContract = [
                select Id, AccountId, FC_Subscription_Number__c, FC_Subscription__c, FC_Subscription__r.Name,
                        FC_Price_Book__c
                from Contract
                where FC_Subscription_Number__c = 'S-1'
                limit 1
        ];

        System.assertEquals(null, testContract.FC_Subscription__c);
        System.assertEquals(null, testContract.FC_Subscription__r.Name);

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_ContractHandler'
        });

        Test.startTest();

        update testContract;

        Test.stopTest();

        testContract = [
                select Id, AccountId, FC_Subscription_Number__c, FC_Subscription__c, FC_Subscription__r.Name,
                        FC_Price_Book__c
                from Contract
                where FC_Subscription_Number__c = 'S-1'
                limit 1
        ];

        System.assertNotEquals(null, testContract.FC_Subscription__c);
        System.assertEquals('S-1', testContract.FC_Subscription__r.Name);

    }

    @testSetup
    private static void setup() {

        Account testAccount = new Account(Name = 'Test Account', Has_Active_Subscription__c = false, BillingPostalCode = '12345');
        insert testAccount;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c[] testSubscriptions = new Zuora__Subscription__c[]{
                new Zuora__Subscription__c(Name = 'S-1',
                        Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                        Zuora__Status__c = 'Active', Zuora__SubscriptionNumber__c = 'S-1'),
                new Zuora__Subscription__c(Name = 'S-2',
                        Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                        Zuora__Status__c = 'Active', Zuora__SubscriptionNumber__c = 'S-2')
        };
        insert testSubscriptions;

        Contract testContract = new Contract(AccountId = testAccount.Id, FC_Subscription_Number__c = 'S-1',
                FC_Price_Book__c = Test.getStandardPricebookId());
        insert testContract;

    }

}