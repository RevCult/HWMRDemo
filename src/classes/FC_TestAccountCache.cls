@isTest
private class FC_TestAccountCache {

    @isTest
    private static void testClearCache() {

        Account testAccount = [
                select Id
                from Account
                where Name = 'Test Account'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, Account> results = FC_AccountCache.findByIds(new Set<Id>{
                testAccount.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_AccountCache.findByIds(new Set<Id>{
                testAccount.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        FC_AccountCache.clearCache();
        results = FC_AccountCache.findByIds(new Set<Id>{
                testAccount.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(2, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByIds() {

        Account testAccount = [
                select Id
                from Account
                where Name = 'Test Account'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, Account> results = FC_AccountCache.findByIds(new Set<Id>{
                testAccount.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_AccountCache.findByIds(new Set<Id>{
                testAccount.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());

        Test.stopTest();

    }

    @testSetup
    private static void setup() {

        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '12345');
        insert testAccount;

    }
}