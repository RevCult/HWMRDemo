@isTest
private class FC_TestZquProductRatePlanChargeHandler {

    @isTest
    public static void testInsert() {

        zqu__ProductRatePlan__c testProductRatePlan = [
                select Id
                from zqu__ProductRatePlan__c
                where Name = 'Test Product Rate Plan'
                limit 1
        ];

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_ZquProductRatePlanChargeHandler'
        });

        Test.startTest();

        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = new zqu__ProductRatePlanCharge__c(
                Name = 'Test Product Rate Plan Charge', zqu__ProductRatePlan__c = testProductRatePlan.Id,
                zqu__RecognizedRevenueAccount__c = 'AC-1', zqu__ZuoraId__c = 'PRPC-2', zqu__Deleted__c = false);
        insert testProductRatePlanCharge;

        Test.stopTest();

        testProductRatePlanCharge = [
                select Id, zqu__RecognizedRevenueAccount__c, FC_Recognized_Revenue_Account__c
                from zqu__ProductRatePlanCharge__c
                where Id = :testProductRatePlanCharge.Id
                limit 1
        ];

        System.assertEquals(testProductRatePlanCharge.zqu__RecognizedRevenueAccount__c,
                testProductRatePlanCharge.FC_Recognized_Revenue_Account__c);

    }

    @isTest
    public static void testUpdate() {

        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = [
                select Id, zqu__ProductRatePlan__c
                from zqu__ProductRatePlanCharge__c
                where zqu__RecognizedRevenueAccount__c = 'AC-1'
                limit 1
        ];

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_ZquProductRatePlanChargeHandler',
                'FC_FcMetroclientProductGeoSeg3Handler'
        });

        Test.startTest();

        update testProductRatePlanCharge;

        Test.stopTest();

        testProductRatePlanCharge = [
                select Id, zqu__RecognizedRevenueAccount__c, FC_Recognized_Revenue_Account__c
                from zqu__ProductRatePlanCharge__c
                where Id = :testProductRatePlanCharge.Id
                limit 1
        ];

        System.assertEquals(testProductRatePlanCharge.zqu__RecognizedRevenueAccount__c,
                testProductRatePlanCharge.FC_Recognized_Revenue_Account__c);
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
                zqu__Product__c = testProduct.Id, zqu__ZuoraId__c = 'PRP-1', zqu__ZProduct__c = testZProduct.Id,
                zqu__Deleted__c = false, zqu__EffectiveStartDate__c = Date.today() - 30,
                zqu__EffectiveEndDate__c = Date.today() + 30);
        insert testProductRatePlan;

        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = new zqu__ProductRatePlanCharge__c(
                Name = 'Test Product Rate Plan Charge', zqu__ProductRatePlan__c = testProductRatePlan.Id,
                zqu__RecognizedRevenueAccount__c = 'AC-1',
                zqu__ZuoraId__c = 'PRPC-1', zqu__Deleted__c = false);
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
                        Dependent_Seg3__c = null, Exclude_From_Product_Selector__c = false, Product_Geography__c = testProductGeography.Id,
                        Execute_Immediately__c = true, Seg3__c = 'CONS');
        insert testProductGeographySeg3;

    }

}