@isTest
private class FC_TestUpdateUltimateMapgStatusBatch {

    @isTest
    private static void testBatchableCurrent() {

        MetroclientAccountProductGeography__c testMetroclientAccountProductGeography = [
                select Id, Account__c,
                        FC_Ultimate_Parent_Account__c, FC_Ultimate_Parent_Account_Synced__c, Status__c
                from
                        MetroclientAccountProductGeography__c
                where Name = 'MAPG-1'
                limit 1
        ];
        System.assertEquals(true, testMetroclientAccountProductGeography.FC_Ultimate_Parent_Account_Synced__c);
        System.assertEquals(testMetroclientAccountProductGeography.Account__c, testMetroclientAccountProductGeography.FC_Ultimate_Parent_Account__c);
        System.assertEquals('Active', testMetroclientAccountProductGeography.Status__c);

        Account testAccount = [select Id, ParentId, FC_MAPG_Status__c from Account where Name = 'Test Account' limit 1];
        System.assertEquals(null, testAccount.ParentId);
        System.assertEquals(null, testAccount.FC_MAPG_Status__c);

        Test.startTest();
        FC_UpdateUltimateParentMapgStatusBatch batchable = new FC_UpdateUltimateParentMapgStatusBatch();
        Database.executeBatch(batchable);
        Test.stopTest();

        testAccount = [select Id, ParentId, FC_MAPG_Status__c from Account where Name = 'Test Account' limit 1];
        System.assertEquals('Current', testAccount.FC_MAPG_Status__c);

    }


    @isTest
    private static void testBatchableFuture() {

        MetroclientAccountProductGeography__c testMetroclientAccountProductGeography = [
                select Id, Account__c,
                        FC_Ultimate_Parent_Account__c, FC_Ultimate_Parent_Account_Synced__c, Status__c
                from
                        MetroclientAccountProductGeography__c
                where Name = 'MAPG-2'
                limit 1
        ];
        System.assertEquals(true, testMetroclientAccountProductGeography.FC_Ultimate_Parent_Account_Synced__c);
        System.assertEquals(testMetroclientAccountProductGeography.Account__c, testMetroclientAccountProductGeography.FC_Ultimate_Parent_Account__c);
        System.assertEquals('Future', testMetroclientAccountProductGeography.Status__c);

        Account testAccount = [select Id, ParentId, FC_MAPG_Status__c from Account where Name = 'Test Account' limit 1];
        System.assertEquals(null, testAccount.ParentId);
        System.assertEquals(null, testAccount.FC_MAPG_Status__c);

        delete [select Id from MetroclientAccountProductGeography__c where Name = 'MAPG-1'];

        Test.startTest();
        FC_UpdateUltimateParentMapgStatusBatch batchable = new FC_UpdateUltimateParentMapgStatusBatch();
        Database.executeBatch(batchable);
        Test.stopTest();

        testAccount = [select Id, ParentId, FC_MAPG_Status__c from Account where Name = 'Test Account' limit 1];
        System.assertEquals('Future', testAccount.FC_MAPG_Status__c);

    }

    @testSetup
    private static void setup() {
        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '12345');
        insert testAccount;

        MetroclientAccountProductGeography__c[] testMetroclientAccountProductGeographies = new MetroclientAccountProductGeography__c[]{
                new MetroclientAccountProductGeography__c(Name = 'MAPG-1', Account__c = testAccount.Id,
                        FC_Ultimate_Parent_Account__c = testAccount.Id, StartDate__c = Date.today() - 30, EndDate__c = Date.today() + 30),
                new MetroclientAccountProductGeography__c(Name = 'MAPG-2', Account__c = testAccount.Id,
                        FC_Ultimate_Parent_Account__c = testAccount.Id, StartDate__c = Date.today() + 30, EndDate__c = Date.today() + 60)
        };
        insert testMetroclientAccountProductGeographies;
    }

}