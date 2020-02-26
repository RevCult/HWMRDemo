@isTest
private class FC_TestMetrostudySalesRegionAssignCache {

    @isTest
    private static void testClearCache() {

        MetrostudySalesRegionAssignment__c testSalesRegionAssignment = [
                select Id
                from MetrostudySalesRegionAssignment__c
                where Name = 'Test Sales Region Assignment'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, MetrostudySalesRegionAssignment__c> results = FC_MetrostudySalesRegionAssignmentCache.findByIds(
                new Set<Id>{
                        testSalesRegionAssignment.Id
                });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_MetrostudySalesRegionAssignmentCache.findByIds(new Set<Id>{
                testSalesRegionAssignment.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        FC_MetrostudySalesRegionAssignmentCache.clearCache();
        results = FC_MetrostudySalesRegionAssignmentCache.findByIds(new Set<Id>{
                testSalesRegionAssignment.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(2, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByIds() {

        MetrostudySalesRegionAssignment__c testSalesRegionAssignment = [
                select Id
                from MetrostudySalesRegionAssignment__c
                where Name = 'Test Sales Region Assignment'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, MetrostudySalesRegionAssignment__c> results = FC_MetrostudySalesRegionAssignmentCache.findByIds(
                new Set<Id>{
                        testSalesRegionAssignment.Id
                });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_MetrostudySalesRegionAssignmentCache.findByIds(new Set<Id>{
                testSalesRegionAssignment.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindBySalesRegionIds() {

        MetrostudySalesRegionAssignment__c testSalesRegionAssignment = [
                select Id, SalesRegion__c
                from MetrostudySalesRegionAssignment__c
                where Name = 'Test Sales Region Assignment'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, Set<MetrostudySalesRegionAssignment__c>> results = FC_MetrostudySalesRegionAssignmentCache.findBySalesRegionIds(
                new Set<Id>{
                        testSalesRegionAssignment.SalesRegion__c
                });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_MetrostudySalesRegionAssignmentCache.findBySalesRegionIds(new Set<Id>{
                testSalesRegionAssignment.SalesRegion__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @testSetup
    private static void setup() {

        MetrostudySalesRegion__c testSalesRegion = new MetrostudySalesRegion__c(Abbreviation__c = 'TEST',
                Description__c = 'Test Sales Region', Name = 'Test Sales Region');
        insert testSalesRegion;

        MetrostudySalesRegionAssignment__c testSalesRegionAssignment = new MetrostudySalesRegionAssignment__c(
                Name = 'Test Sales Region Assignment', Role__c = 'Test', SalesRegion__c = testSalesRegion.Id,
                User__c = UserInfo.getUserId());
        insert testSalesRegionAssignment;

    }

}