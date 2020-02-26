@isTest
private class FC_TestMapgUltimateParentAcctSyncBatch {

    @isTest
    private static void testBatchable() {

        MetroclientAccountProductGeography__c testMetroclientAccountProductGeography = [
                select Id, Account__c,
                        FC_Ultimate_Parent_Account__c, FC_Ultimate_Parent_Account_Synced__c
                from
                        MetroclientAccountProductGeography__c
                where Name = 'MAPG-1'
                limit 1
        ];
        System.assertEquals(false, testMetroclientAccountProductGeography.FC_Ultimate_Parent_Account_Synced__c);
        System.assertEquals(null, testMetroclientAccountProductGeography.FC_Ultimate_Parent_Account__c);

        Test.startTest();
        FC_MapgUltimateParentAccountSyncBatch batchable = new FC_MapgUltimateParentAccountSyncBatch();
        Database.executeBatch(batchable);
        Test.stopTest();

        testMetroclientAccountProductGeography = [
                select Id, Account__c,
                        FC_Ultimate_Parent_Account__c, FC_Ultimate_Parent_Account_Synced__c
                from
                        MetroclientAccountProductGeography__c
                where Name = 'MAPG-1'
                limit 1
        ];
        System.assertEquals(true, testMetroclientAccountProductGeography.FC_Ultimate_Parent_Account_Synced__c);
        System.assertEquals(testMetroclientAccountProductGeography.Account__c, testMetroclientAccountProductGeography.FC_Ultimate_Parent_Account__c);

    }

    @testSetup
    private static void setup() {
        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '12345');
        insert testAccount;

        MetroclientAccountProductGeography__c testMetroclientAccountProductGeography = new MetroclientAccountProductGeography__c(Name = 'MAPG-1', Account__c = testAccount.Id);
        insert testMetroclientAccountProductGeography;
    }
}