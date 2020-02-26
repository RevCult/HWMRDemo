@isTest
private class FC_TestFcMetroclientProductGeoSeg3Cache {

    @isTest
    private static void testClearCache() {

        FC_Metroclient_Product_Geography_Seg3__c testProductGeographySeg3 = [
                select Id
                from FC_Metroclient_Product_Geography_Seg3__c
                where Accounting_Code__c = 'AC-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, FC_Metroclient_Product_Geography_Seg3__c> results = FC_FcMetroclientProductGeoSeg3Cache.findByIds(new Set<Id>{
                testProductGeographySeg3.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_FcMetroclientProductGeoSeg3Cache.findByIds(new Set<Id>{
                testProductGeographySeg3.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        FC_FcMetroclientProductGeoSeg3Cache.clearCache();
        results = FC_FcMetroclientProductGeoSeg3Cache.findByIds(new Set<Id>{
                testProductGeographySeg3.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(2, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByIds() {

        FC_Metroclient_Product_Geography_Seg3__c testProductGeographySeg3 = [
                select Id
                from FC_Metroclient_Product_Geography_Seg3__c
                where Accounting_Code__c = 'AC-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, FC_Metroclient_Product_Geography_Seg3__c> results = FC_FcMetroclientProductGeoSeg3Cache.findByIds(new Set<Id>{
                testProductGeographySeg3.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_FcMetroclientProductGeoSeg3Cache.findByIds(new Set<Id>{
                testProductGeographySeg3.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByAccountingCodes() {

        FC_Metroclient_Product_Geography_Seg3__c testProductGeographySeg3 = [
                select Id, Accounting_Code__c
                from FC_Metroclient_Product_Geography_Seg3__c
                where Accounting_Code__c = 'AC-1'
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<String, Set<FC_Metroclient_Product_Geography_Seg3__c>> results =
                FC_FcMetroclientProductGeoSeg3Cache.findByAccountingCodes(new Set<String>{
                        testProductGeographySeg3.Accounting_Code__c
                });
        System.assertEquals(1, results.size());
        System.assertEquals(1, results.get(testProductGeographySeg3.Accounting_Code__c).size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_FcMetroclientProductGeoSeg3Cache.findByAccountingCodes(new Set<String>{
                testProductGeographySeg3.Accounting_Code__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, results.get(testProductGeographySeg3.Accounting_Code__c).size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @testSetup
    private static void setup() {

        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        PricebookEntry testPricebookEntry = new PricebookEntry(IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(), Product2Id = testProduct.Id, UnitPrice = 100);
        insert testPricebookEntry;

        zqu__ZProduct__c testZProduct = new zqu__ZProduct__c(Name = 'Test ZProduct', zqu__Product__c = testProduct.Id,
                zqu__SKU__c = 'SKU-1', zqu__ZuoraId__c = 'P-1');
        insert testZProduct;

        zqu__ProductRatePlan__c testProductRatePlan = new zqu__ProductRatePlan__c(Name = 'Test Product Rate Plan',
                zqu__Product__c = testProduct.Id, zqu__ZuoraId__c = 'PRP-1', zqu__ZProduct__c = testZProduct.Id);
        insert testProductRatePlan;

        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = new zqu__ProductRatePlanCharge__c(
                Name = 'Test Product Rate Plan Charge', zqu__ProductRatePlan__c = testProductRatePlan.Id,
                zqu__RecognizedRevenueAccount__c = 'AC-1', zqu__ZuoraId__c = 'PRPC-1');
        insert testProductRatePlanCharge;

        MetroclientProduct__c testMetroclientProduct = new MetroclientProduct__c(Name = 'Test Product',
                ProductAbbreviation__c = 'TEST');
        insert testMetroclientProduct;

        MetroclientGeographyType__c testGeographyType = new MetroclientGeographyType__c(Name = 'Test Geography Type',
                GeographyTypeId__c = 1);
        insert testGeographyType;

        MetroclientGeography__c testGeography = new MetroclientGeography__c(Name = 'Test Geography',
                GeographyType__c = testGeographyType.Id);
        insert testGeography;

        MetroclientProductGeographyType__c testProductGeographyType =
                new MetroclientProductGeographyType__c(Name = 'Test Product Geography Type',
                        GeographyType__c = testGeographyType.Id, Product__c = testMetroclientProduct.Id);
        insert testProductGeographyType;

        MetroclientProductGeography__c testProductGeography = new MetroclientProductGeography__c(
                Name = 'Test Product Geography', Geography__c = testGeography.Id,
                ProductGeographyType__c = testProductGeographyType.Id);
        insert testProductGeography;

        FC_Metroclient_Product_Geography_Seg3__c testProductGeographySeg3 =
                new FC_Metroclient_Product_Geography_Seg3__c(Accounting_Code__c = 'AC-1', Charge_Type__c = 'Recurring',
                        Dependent_Seg3__c = null, Exclude_From_Product_Selector__c = false,
                        Execute_Immediately__c = true, Product__c = testProduct.Id,
                        Product_Geography__c = testProductGeography.Id, Product_Rate_Plan__c = testProductRatePlan.Id,
                        Seg3__c = 'CONS');
        insert testProductGeographySeg3;

        FC_Metroclient_Product_Geography_Seg3__Tag[] testProductGeographySeg3Tags =
                new FC_Metroclient_Product_Geography_Seg3__Tag[]{
                        new FC_Metroclient_Product_Geography_Seg3__Tag(ItemId = testProductGeographySeg3.Id,
                                Name = 'Balance Due', Type = 'Public'),
                        new FC_Metroclient_Product_Geography_Seg3__Tag(ItemId = testProductGeographySeg3.Id,
                                Name = 'Expenses', Type = 'Public')
                };
        insert testProductGeographySeg3Tags;

    }

}