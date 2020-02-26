@isTest
private class FC_TestProductRatePlanChargeCache {

    @isTest
    private static void testClearCache() {

        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = [
                select Id
                from zqu__ProductRatePlanCharge__c
                where zqu__ZuoraId__c = 'PRPC-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, zqu__ProductRatePlanCharge__c> results = FC_ProductRatePlanChargeCache.findByIds(new Set<Id>{
                testProductRatePlanCharge.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_ProductRatePlanChargeCache.findByIds(new Set<Id>{
                testProductRatePlanCharge.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        FC_ProductRatePlanChargeCache.clearCache();
        results = FC_ProductRatePlanChargeCache.findByIds(new Set<Id>{
                testProductRatePlanCharge.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(2, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByIds() {

        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = [
                select Id
                from zqu__ProductRatePlanCharge__c
                where zqu__ZuoraId__c = 'PRPC-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, zqu__ProductRatePlanCharge__c> results = FC_ProductRatePlanChargeCache.findByIds(new Set<Id>{
                testProductRatePlanCharge.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_ProductRatePlanChargeCache.findByIds(new Set<Id>{
                testProductRatePlanCharge.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindWithActiveRatePlanByRecognizedRevenueAccount() {

        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = [
                select Id, zqu__RecognizedRevenueAccount__c
                from zqu__ProductRatePlanCharge__c
                where zqu__ZuoraId__c = 'PRPC-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<String, Set<zqu__ProductRatePlanCharge__c>> results = FC_ProductRatePlanChargeCache.findWithActiveRatePlanByRecognizedRevenueAccount(new Set<String>{
                testProductRatePlanCharge.zqu__RecognizedRevenueAccount__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_ProductRatePlanChargeCache.findWithActiveRatePlanByRecognizedRevenueAccount(new Set<String>{
                testProductRatePlanCharge.zqu__RecognizedRevenueAccount__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByFcLookupKeys() {

        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = [
                select Id, FC_Lookup_Key__c
                from zqu__ProductRatePlanCharge__c
                where zqu__ZuoraId__c = 'PRPC-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<String, zqu__ProductRatePlanCharge__c> results = FC_ProductRatePlanChargeCache.findByFcLookupKeys(new Set<String>{
                testProductRatePlanCharge.FC_Lookup_Key__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_ProductRatePlanChargeCache.findByFcLookupKeys(new Set<String>{
                testProductRatePlanCharge.FC_Lookup_Key__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByZuoraIds() {

        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = [
                select Id, zqu__ZuoraId__c
                from zqu__ProductRatePlanCharge__c
                where zqu__ZuoraId__c = 'PRPC-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<String, zqu__ProductRatePlanCharge__c> results = FC_ProductRatePlanChargeCache.findByZuoraIds(new Set<String>{
                testProductRatePlanCharge.zqu__ZuoraId__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_ProductRatePlanChargeCache.findByFcLookupKeys(new Set<String>{
                testProductRatePlanCharge.zqu__ZuoraId__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @testSetup
    private static void setup() {

        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        zqu__ZProduct__c testZProduct = new zqu__ZProduct__c(Name = 'Test ZProduct', zqu__Product__c = testProduct.Id,
                zqu__SKU__c = 'SKU-1', zqu__ZuoraId__c = 'P-1');
        insert testZProduct;

        zqu__ProductRatePlan__c testProductRatePlan = new zqu__ProductRatePlan__c(Name = 'Test Product Rate Plan',
                zqu__Product__c = testProduct.Id, zqu__ZuoraId__c = 'PRP-1', zqu__ZProduct__c = testZProduct.Id,
                zqu__EffectiveStartDate__c = Date.today() - 30, zqu__EffectiveEndDate__c = Date.today() + 30,
                zqu__Deleted__c = false);
        insert testProductRatePlan;

        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = new zqu__ProductRatePlanCharge__c(
                Name = 'Test Product Rate Plan Charge', zqu__ProductRatePlan__c = testProductRatePlan.Id,
                zqu__RecognizedRevenueAccount__c = 'AC-1', FC_Recognized_Revenue_Account__c = 'AC-1',
                zqu__ZuoraId__c = 'PRPC-1', FC_Lookup_Key__c = 'PRPC-1',
                zqu__Deleted__c = false);
        insert testProductRatePlanCharge;

    }

}