@isTest
private class FC_TestZuoraSubscriptionHandler {

    @isTest
    private static void testInsert() {

        Account testAccount = [select Id from Account where Name = 'Test Account' limit 1];

        Zuora__CustomerAccount__c testCustomerAccount = [
                select Id
                from Zuora__CustomerAccount__c
                where Name = 'Test Account'
                limit 1
        ];

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_ZuoraSubscriptionHandler'
        });

        Test.startTest();

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-2',
                OpportunityID__c = testOpportunity.Id, Zuora__Account__c = testAccount.Id,
                Zuora__CustomerAccount__c = testCustomerAccount.Id, Zuora__TermEndDate__c = Date.today() + 365,
                Zuora__TermStartDate__c = Date.today());
        insert testSubscription;

        Test.stopTest();

        testSubscription = [
                select Id, Opportunity__c, FC_One_Time_Charge_Count__c
                from Zuora__Subscription__c
                where Name = 'S-2'
                limit 1
        ];

        System.assertEquals(testOpportunity.Id, testSubscription.Opportunity__c);
        System.assertEquals(0, testSubscription.FC_One_Time_Charge_Count__c);

    }

    @isTest
    private static void testUpdate() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        Zuora__Subscription__c testSubscription = [
                select Id, Opportunity__c, FC_One_Time_Charge_Count__c
                from Zuora__Subscription__c
                where Name = 'S-1'
                limit 1
        ];

        System.assertEquals(null, testSubscription.Opportunity__c);
        System.assertNotEquals(1, testSubscription.FC_One_Time_Charge_Count__c);

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_ZuoraSubscriptionHandler'
        });

        Test.startTest();

        testSubscription.OpportunityID__c = testOpportunity.Id;
        update testSubscription;

        Test.stopTest();

        testSubscription = [
                select Id, Opportunity__c, FC_One_Time_Charge_Count__c
                from Zuora__Subscription__c
                where Id = :testSubscription.Id
                limit 1
        ];

        System.assertEquals(testOpportunity.Id, testSubscription.Opportunity__c);
        System.assertEquals(1, testSubscription.FC_One_Time_Charge_Count__c);

    }

    @isTest
    private static void testDelete() {

        Account testAccount = [select Id, Has_Active_Subscription__c from Account where Name = 'Test Account' limit 1];

        System.assertEquals(true, testAccount.Has_Active_Subscription__c);

        Zuora__Subscription__c testSubscription = [
                select Id
                from Zuora__Subscription__c
                where Name = 'S-1'
                limit 1
        ];

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_AccountHandler',
                'FC_ZuoraSubscriptionHandler'
        });

        Test.startTest();

        delete testSubscription;

        Test.stopTest();

        testAccount = [select Id, Has_Active_Subscription__c from Account where Id = :testAccount.Id limit 1];

        System.assertEquals(false, testAccount.Has_Active_Subscription__c);

    }

    @isTest
    private static void testUndelete() {

        Account testAccount = [select Id, Has_Active_Subscription__c from Account where Name = 'Test Account' limit 1];

        System.assertEquals(true, testAccount.Has_Active_Subscription__c);

        Zuora__Subscription__c testSubscription = [
                select Id
                from Zuora__Subscription__c
                where Name = 'S-1'
                limit 1
        ];

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_AccountHandler',
                'FC_ZuoraSubscriptionHandler'
        });

        update testSubscription;

        fcf.TriggerRunStatus.unblockAll();

        delete testSubscription;

        testAccount = [select Id, Has_Active_Subscription__c from Account where Id = :testAccount.Id limit 1];

        System.assertEquals(false, testAccount.Has_Active_Subscription__c);

        fcf.TriggerRunStatus.unblockAll();

        Test.startTest();

        undelete testSubscription;

        Test.stopTest();

        testAccount = [select Id, Has_Active_Subscription__c from Account where Id = :testAccount.Id limit 1];

        System.assertEquals(true, testAccount.Has_Active_Subscription__c);

    }

    @testSetup
    private static void setup() {

        Account testAccount = new Account(Name = 'Test Account', Has_Active_Subscription__c = true, BillingPostalCode = '12345');
        insert testAccount;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today());
        insert testSubscription;

        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge =
                new Zuora__SubscriptionProductCharge__c(Name = 'C-1',
                        Zuora__Subscription__c = testSubscription.Id, Zuora__Type__c = 'One-Time',
                        Zuora__SubscriptionChargeNumber__c = 'C-1', Zuora__EffectiveStartDate__c = Date.today());
        insert testSubscriptionProductCharge;

        Contract testContract = new Contract(AccountId = testAccount.Id, FC_Subscription_Number__c = 'S-1',
                FC_Price_Book__c = Test.getStandardPricebookId());
        insert testContract;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',
                AccountId = testAccount.Id, Amount = 100, ContractId = testContract.Id,
                StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30);
        insert testOpportunity;

    }
}