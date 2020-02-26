@isTest
private class FC_TestFcMetroclientProdGeoSeg3Handler {

    @isTest
    private static void testInsert() {

        MetroclientProductGeography__c testProductGeography = [
                select Id
                from MetroclientProductGeography__c
                where Name = 'Test Product Geography'
                limit 1
        ];

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_FcMetroclientProductGeoSeg3Handler'
        });

        Test.startTest();

        FC_Metroclient_Product_Geography_Seg3__c testProductGeographySeg3 =
                new FC_Metroclient_Product_Geography_Seg3__c(Accounting_Code__c = 'AC-1',
                        Dependent_Seg3__c = null, Exclude_From_Product_Selector__c = false,
                        Execute_Immediately__c = true,
                        Product_Geography__c = testProductGeography.Id);
        insert testProductGeographySeg3;

        Test.stopTest();

        testProductGeographySeg3 = [
                select Id, Product__c, Product_Rate_Plan__c, Charge_Type__c, Seg3__c
                from FC_Metroclient_Product_Geography_Seg3__c
                where Id = :testProductGeographySeg3.Id
                limit 1
        ];

        Product2 testProduct = [select Id from Product2 where Name = 'Test Product' limit 1];
        zqu__ProductRatePlan__c testProductRatePlan = [
                select Id
                from zqu__ProductRatePlan__c
                where zqu__ZuoraId__c = 'PRP-1'
                limit 1
        ];
        System.assertEquals(testProduct.Id, testProductGeographySeg3.Product__c);
        System.assertEquals(testProductRatePlan.Id, testProductGeographySeg3.Product_Rate_Plan__c);
        System.assertEquals('Recurring', testProductGeographySeg3.Charge_Type__c);
        System.assertEquals('CONS', testProductGeographySeg3.Seg3__c);

    }

    @isTest
    private static void testUpdate() {

        FC_Metroclient_Product_Geography_Seg3__c testProductGeographySeg3 = [
                select Id, Product__c, Product_Rate_Plan__c, Charge_Type__c, Seg3__c
                from FC_Metroclient_Product_Geography_Seg3__c
                where Accounting_Code__c = 'AC-1'
                limit 1
        ];

        System.assertEquals(null, testProductGeographySeg3.Product__c);
        System.assertEquals(null, testProductGeographySeg3.Product_Rate_Plan__c);
        System.assert(String.isBlank(testProductGeographySeg3.Charge_Type__c));
        System.assert(String.isBlank(testProductGeographySeg3.Seg3__c));

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_FcMetroclientProductGeoSeg3Handler'
        });

        Test.startTest();

        update testProductGeographySeg3;

        Test.stopTest();

        testProductGeographySeg3 = [
                select Id, Product__c, Product_Rate_Plan__c, Charge_Type__c, Seg3__c
                from FC_Metroclient_Product_Geography_Seg3__c
                where Accounting_Code__c = 'AC-1'
                limit 1
        ];

        Product2 testProduct = [select Id from Product2 where Name = 'Test Product' limit 1];
        zqu__ProductRatePlan__c testProductRatePlan = [
                select Id
                from zqu__ProductRatePlan__c
                where zqu__ZuoraId__c = 'PRP-1'
                limit 1
        ];
        System.assertEquals(testProduct.Id, testProductGeographySeg3.Product__c);
        System.assertEquals(testProductRatePlan.Id, testProductGeographySeg3.Product_Rate_Plan__c);
        System.assertEquals('Recurring', testProductGeographySeg3.Charge_Type__c);
        System.assertEquals('CONS', testProductGeographySeg3.Seg3__c);

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
                Segment3__c = 'CONS', zqu__Product__c = testProduct.Id, zqu__ZuoraId__c = 'PRP-1',
                zqu__ZProduct__c = testZProduct.Id, zqu__EffectiveStartDate__c = Date.today() - 30,
                zqu__EffectiveEndDate__c = Date.today() + 30, zqu__Deleted__c = false);
        insert testProductRatePlan;

        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = new zqu__ProductRatePlanCharge__c(
                Name = 'Test Product Rate Plan Charge', zqu__ProductRatePlan__c = testProductRatePlan.Id,
                zqu__RecognizedRevenueAccount__c = 'AC-1', FC_Recognized_Revenue_Account__c = 'AC-1',
                zqu__ZuoraId__c = 'PRPC-1', zqu__Type__c = 'Recurring',
                zqu__Deleted__c = false);
        insert testProductRatePlanCharge;

        MetroclientProduct__c testMetroclientProduct = new MetroclientProduct__c(Name = 'Test Product',
                ProductAbbreviation__c = 'TEST', ZuoraSku__c = 'SKU-1');
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
                new FC_Metroclient_Product_Geography_Seg3__c(Accounting_Code__c = 'AC-1',
                        Dependent_Seg3__c = null, Exclude_From_Product_Selector__c = false,
                        Execute_Immediately__c = true,
                        Product_Geography__c = testProductGeography.Id);
        insert testProductGeographySeg3;
    }

}