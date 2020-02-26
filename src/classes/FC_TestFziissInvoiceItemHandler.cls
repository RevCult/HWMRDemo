@isTest
private class FC_TestFziissInvoiceItemHandler {

    @isTest
    private static void testInsert() {

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'fziiss.InvoiceItemHandler', 'FC_SubscriptionProductChargeHandler'
        });

        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [
                select Id, Zuora__BillingPeriod__c, Zuora__External_Id__c, Zuora__Subscription__c
                from Zuora__SubscriptionProductCharge__c
                where Zuora__External_Id__c = 'SPC-1'
        ];

        Test.startTest();
        fziiss__Invoice_Item__c testInvoiceItem = new fziiss__Invoice_Item__c(Name = 'II-1', Segment2__c = '00',
                fziiss__SubscriptionNumber__c = 'S-1', fziiss__ChargeNumber__c = 'SPC-1',
                fziiss__Subscription__c = testSubscriptionProductCharge.Zuora__Subscription__c,
                fziiss__Rate_Plan_Charge__c = testSubscriptionProductCharge.Id);
        insert testInvoiceItem;

        Test.stopTest();

        testInvoiceItem = [
                select Id, Name, Billing_Frequency__c, Segment2_Market_Name__c
                from fziiss__Invoice_Item__c
                where Id = :testInvoiceItem.Id
        ];
        System.assertEquals('TEST MARKET', testInvoiceItem.Segment2_Market_Name__c);
        System.assertEquals(testSubscriptionProductCharge.Zuora__BillingPeriod__c, testInvoiceItem.Billing_Frequency__c);
    }

    @isTest
    private static void testUpdate() {

        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [
                select Id, FC_Most_Recent_Service_Start_Date__c, Zuora__BillingPeriod__c, Zuora__External_Id__c
                from Zuora__SubscriptionProductCharge__c
                where Zuora__External_Id__c = 'SPC-1'
        ];
        System.assertEquals(null, testSubscriptionProductCharge.FC_Most_Recent_Service_Start_Date__c);

        fziiss__Invoice_Item__c testInvoiceItem = new fziiss__Invoice_Item__c(Name = 'II-1',
                fziiss__SubscriptionNumber__c = 'S-1',
                fziiss__ChargeNumber__c = 'SPC-1',
                fziiss__Rate_Plan_Charge__c = testSubscriptionProductCharge.Id,
                fziiss__ServiceStartDate__c = Date.today());
        insert testInvoiceItem;

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'fziiss.InvoiceItemHandler', 'FC_SubscriptionProductChargeHandler'
        });

        fcf.TriggerRunStatus.unblockAll();
        Test.startTest();
        testInvoiceItem.Name = 'II-1';
        testInvoiceItem.Segment2__c = '00';
        testInvoiceItem.fziiss__SubscriptionNumber__c = 'S-1';
        testInvoiceItem.fziiss__ChargeNumber__c = 'SPC-1';
        update testInvoiceItem;
        Test.stopTest();

        testInvoiceItem = [
                select Id, Name, Billing_Frequency__c, Segment2_Market_Name__c
                from fziiss__Invoice_Item__c
                where Id = :testInvoiceItem.Id
        ];
        System.assertEquals('TEST MARKET', testInvoiceItem.Segment2_Market_Name__c);
        System.assertEquals(testSubscriptionProductCharge.Zuora__BillingPeriod__c, testInvoiceItem.Billing_Frequency__c);

        testSubscriptionProductCharge = [
                select Id, FC_Most_Recent_Service_Start_Date__c, Zuora__BillingPeriod__c, Zuora__External_Id__c
                from Zuora__SubscriptionProductCharge__c
                where Zuora__External_Id__c = 'SPC-1'
        ];
        System.assertEquals(Date.today(), testSubscriptionProductCharge.FC_Most_Recent_Service_Start_Date__c);

    }

    @isTest
    private static void testDelete() {

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'fziiss.InvoiceItemHandler', 'FC_SubscriptionProductChargeHandler'
        });

        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [
                select Id, FC_Most_Recent_Service_Start_Date__c, Zuora__BillingPeriod__c, Zuora__External_Id__c
                from Zuora__SubscriptionProductCharge__c
                where Zuora__External_Id__c = 'SPC-1'
        ];
        System.assertEquals(null, testSubscriptionProductCharge.FC_Most_Recent_Service_Start_Date__c);

        fcf.TriggerRunStatus.unblockAll();
        fziiss__Invoice_Item__c testInvoiceItem = new fziiss__Invoice_Item__c(Name = 'II-1',
                fziiss__SubscriptionNumber__c = 'S-1',
                fziiss__ChargeNumber__c = 'SPC-1',
                fziiss__Rate_Plan_Charge__c = testSubscriptionProductCharge.Id,
                fziiss__ServiceStartDate__c = Date.today());
        insert testInvoiceItem;

        testSubscriptionProductCharge = [
                select Id, FC_Most_Recent_Service_Start_Date__c, Zuora__BillingPeriod__c, Zuora__External_Id__c
                from Zuora__SubscriptionProductCharge__c
                where Zuora__External_Id__c = 'SPC-1'
        ];
        System.assertEquals(Date.today(), testSubscriptionProductCharge.FC_Most_Recent_Service_Start_Date__c);

        fcf.TriggerRunStatus.unblockAll();
        Test.startTest();
        delete testInvoiceItem;
        Test.stopTest();

        testSubscriptionProductCharge = [
                select Id, FC_Most_Recent_Service_Start_Date__c, Zuora__BillingPeriod__c, Zuora__External_Id__c
                from Zuora__SubscriptionProductCharge__c
                where Zuora__External_Id__c = 'SPC-1'
        ];
        System.assertEquals(null, testSubscriptionProductCharge.FC_Most_Recent_Service_Start_Date__c);
    }

    @isTest
    private static void testUndelete() {

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'fziiss.InvoiceItemHandler', 'FC_SubscriptionProductChargeHandler'
        });

        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [
                select Id, FC_Most_Recent_Service_Start_Date__c, Zuora__BillingPeriod__c, Zuora__External_Id__c
                from Zuora__SubscriptionProductCharge__c
                where Zuora__External_Id__c = 'SPC-1'
        ];
        System.assertEquals(null, testSubscriptionProductCharge.FC_Most_Recent_Service_Start_Date__c);

        fcf.TriggerRunStatus.unblockAll();
        fziiss__Invoice_Item__c testInvoiceItem = new fziiss__Invoice_Item__c(Name = 'II-1',
                fziiss__SubscriptionNumber__c = 'S-1',
                fziiss__ChargeNumber__c = 'SPC-1',
                fziiss__Rate_Plan_Charge__c = testSubscriptionProductCharge.Id,
                fziiss__ServiceStartDate__c = Date.today());
        insert testInvoiceItem;

        testSubscriptionProductCharge = [
                select Id, FC_Most_Recent_Service_Start_Date__c, Zuora__BillingPeriod__c, Zuora__External_Id__c
                from Zuora__SubscriptionProductCharge__c
                where Zuora__External_Id__c = 'SPC-1'
        ];
        System.assertEquals(Date.today(), testSubscriptionProductCharge.FC_Most_Recent_Service_Start_Date__c);

        fcf.TriggerRunStatus.unblockAll();
        delete testInvoiceItem;

        testSubscriptionProductCharge = [
                select Id, FC_Most_Recent_Service_Start_Date__c, Zuora__BillingPeriod__c, Zuora__External_Id__c
                from Zuora__SubscriptionProductCharge__c
                where Zuora__External_Id__c = 'SPC-1'
        ];
        System.assertEquals(null, testSubscriptionProductCharge.FC_Most_Recent_Service_Start_Date__c);

        fcf.TriggerRunStatus.unblockAll();
        Test.startTest();
        undelete testInvoiceItem;
        Test.stopTest();

        testSubscriptionProductCharge = [
                select Id, FC_Most_Recent_Service_Start_Date__c, Zuora__BillingPeriod__c, Zuora__External_Id__c
                from Zuora__SubscriptionProductCharge__c
                where Zuora__External_Id__c = 'SPC-1'
        ];
        System.assertEquals(Date.today(), testSubscriptionProductCharge.FC_Most_Recent_Service_Start_Date__c);
    }

    @testSetup
    private static void setup() {
        FC_Segment_2_Assignment__c testFcSegment2Assignment = new FC_Segment_2_Assignment__c(Name = '00',
                Market_Name__c = 'TEST MARKET');
        insert testFcSegment2Assignment;

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

        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '12345');
        insert testAccount;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__External_Id__c = 'S-1', Zuora__SubscriptionNumber__c = 'S-1');
        insert testSubscription;

        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = new Zuora__SubscriptionProductCharge__c(
                Name = 'SPC-1', Zuora__Account__c = testAccount.Id, Zuora__Subscription__c = testSubscription.Id,
                Zuora__BillingPeriod__c = 'Month', Zuora__SubscriptionChargeNumber__c = 'SPC-1',
                Zuora__External_Id__c = 'SPC-1', Seg3_Record__c = testProductGeographySeg3.Id);
        insert testSubscriptionProductCharge;

        fcf.TriggerHandlerSettings.enable('FC_FziissInvoiceItemHandler');
    }

}