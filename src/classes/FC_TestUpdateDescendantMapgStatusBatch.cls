@isTest
private class FC_TestUpdateDescendantMapgStatusBatch {

    @isTest
    private static void testBatchable() {

        Account testAccount = [select Id, ParentId, FC_MAPG_Status__c from Account where Name = 'Test Account' limit 1];
        System.assertEquals(null, testAccount.ParentId);
        System.assertEquals('Current', testAccount.FC_MAPG_Status__c);

        Account testAccount1 = [select Id, ParentId, FC_MAPG_Status__c from Account where Name = 'Test Account 1' limit 1];
        System.assertEquals(testAccount.Id, testAccount1.ParentId);
        System.assertEquals(null, testAccount1.FC_MAPG_Status__c);

        Test.startTest();
        FC_UpdateDescendantAcctMapgStatusBatch batchable = new FC_UpdateDescendantAcctMapgStatusBatch();
        Database.executeBatch(batchable);
        Test.stopTest();

        testAccount1 = [select Id, ParentId, FC_MAPG_Status__c from Account where Name = 'Test Account 1' limit 1];
        System.assertEquals('Current', testAccount1.FC_MAPG_Status__c);

    }

    @testSetup
    private static void setup() {
        Account testAccount = new Account(Name = 'Test Account', FC_MAPG_Status__c = 'Current', BillingPostalCode = '12345', Parent__c = true);
        insert testAccount;

        Account testAccount1 = new Account(Name = 'Test Account 1', FC_Ultimate_Parent_Account__c = testAccount.Id, ParentId = testAccount.Id, BillingPostalCode = '12345');
        insert testAccount1;

        MetroclientAccountProductGeography__c[] testMetroclientAccountProductGeographies = new MetroclientAccountProductGeography__c[]{
                new MetroclientAccountProductGeography__c(Name = 'MAPG-1', Account__c = testAccount.Id,
                        FC_Ultimate_Parent_Account__c = testAccount.Id, StartDate__c = Date.today() - 30, EndDate__c = Date.today() + 30),
                new MetroclientAccountProductGeography__c(Name = 'MAPG-2', Account__c = testAccount.Id,
                        FC_Ultimate_Parent_Account__c = testAccount.Id, StartDate__c = Date.today() + 30, EndDate__c = Date.today() + 60)
        };
        insert testMetroclientAccountProductGeographies;
    }

}