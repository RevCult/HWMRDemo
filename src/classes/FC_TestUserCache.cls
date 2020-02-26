@isTest
private class FC_TestUserCache {

    @isTest
    private static void testClearCache() {

        User testUser = [select Id from User where Name = 'Test Sales' limit 1];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, User> results = FC_UserCache.findByIds(new Set<Id>{
                testUser.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_UserCache.findByIds(new Set<Id>{
                testUser.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        FC_UserCache.clearCache();
        results = FC_UserCache.findByIds(new Set<Id>{
                testUser.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(2, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByIds() {

        User testUser = [select Id from User where Name = 'Test Sales' limit 1];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, User> results = FC_UserCache.findByIds(new Set<Id>{
                testUser.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_UserCache.findByIds(new Set<Id>{
                testUser.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByNames() {

        User testUser = [select Id, Name from User where Name = 'Test Sales' limit 1];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<String, User> results = FC_UserCache.findByNames(new Set<String>{
                testUser.Name
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_UserCache.findByNames(new Set<String>{
                testUser.Name
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @testSetup
    private static void setup() {

        Profile testProfile = [select Id from Profile where Name = 'Media - Sales Rep' limit 1];

        User testUser = new User(FirstName = 'Test', LastName = 'Sales', ProfileId = testProfile.Id,
                Username = FC_UuidUtil.uuidV4() + '@example.com', Email = FC_UuidUtil.uuidV4() + '@example.com',
                Alias = FC_UuidUtil.uuidV4().left(8), CommunityNickname = FC_UuidUtil.uuidV4(),
                TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US');
        insert testUser;

    }

}