@IsTest
private class FC_TestAccountUpdateBatchable {

    @IsTest
    private static void testBatchable() {
        Account testUltimateParentAccount = [
                select Id, FC_Ultimate_Parent_Account__c,
                        FC_Ultimate_Parent_Account_ID_Formula__c
                from Account
                where Name = 'Test Account'
                limit 1
        ];
        Account testAccount1 = [
                select Id, FC_Ultimate_Parent_Account__c,
                        FC_Ultimate_Parent_Account_ID_Formula__c
                from Account
                where Name = 'Test Account 1'
                limit 1
        ];
        Account testAccount2 = [
                select Id, FC_Ultimate_Parent_Account__c,
                        FC_Ultimate_Parent_Account_ID_Formula__c
                from Account
                where Name = 'Test Account 2'
                limit 1
        ];

        System.assertEquals(testUltimateParentAccount.Id, testUltimateParentAccount.FC_Ultimate_Parent_Account_ID_Formula__c);
        System.assertEquals(testAccount1.Id, testAccount1.FC_Ultimate_Parent_Account_ID_Formula__c);
        System.assertEquals(testAccount2.Id, testAccount2.FC_Ultimate_Parent_Account_ID_Formula__c);

        fcf.TriggerHandlerSettings.enable('FC_AccountHandler');

        Test.startTest();
        FC_AccountUpdateBatchable batchable = new FC_AccountUpdateBatchable();
        Database.executeBatch(batchable);
        Test.stopTest();

        testUltimateParentAccount = [
                select Id, FC_Ultimate_Parent_Account__c,
                        FC_Ultimate_Parent_Account_ID_Formula__c
                from Account
                where Name = 'Test Account'
                limit 1
        ];
        testAccount1 = [
                select Id, FC_Ultimate_Parent_Account__c,
                        FC_Ultimate_Parent_Account_ID_Formula__c
                from Account
                where Name = 'Test Account 1'
                limit 1
        ];
        testAccount2 = [
                select Id, FC_Ultimate_Parent_Account__c,
                        FC_Ultimate_Parent_Account_ID_Formula__c
                from Account
                where Name = 'Test Account 2'
                limit 1
        ];

        System.assertEquals(testUltimateParentAccount.Id, testUltimateParentAccount.FC_Ultimate_Parent_Account_ID_Formula__c);
        System.assertEquals(testUltimateParentAccount.Id, testAccount1.FC_Ultimate_Parent_Account_ID_Formula__c);
        System.assertEquals(testUltimateParentAccount.Id, testAccount2.FC_Ultimate_Parent_Account_ID_Formula__c);
    }

    @TestSetup
    private static void setup() {
        Account testAccount = new Account(Name = 'Test Account', Has_Active_Subscription__c = false,
                BillingPostalCode = '10069', Override_Billing_Address_Information__c = true);
        insert testAccount;

        Account testAccount1 = new Account(Name = 'Test Account 1', Has_Active_Subscription__c = false,
                ParentId = testAccount.Id, BillingPostalCode = '10069', Override_Billing_Address_Information__c = true);
        insert testAccount1;

        Account testAccount2 = new Account(Name = 'Test Account 2',
                Has_Active_Subscription__c = false, ParentId = testAccount1.Id,
                BillingPostalCode = '10069', Override_Billing_Address_Information__c = true);
        insert testAccount2;
    }

}