@isTest
private class FC_TestSubscriptionProductChargeHandler {

    private static final String SIMPLE_PRODUCT_NAME = 'Test Simple Product';
    private static final String SIMPLE_PRODUCT_RATE_PLAN_NAME = 'Test Simple Product Rate Plan';
    private static final String SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME = 'Test Simple Product Rate Plan Charge';
    private static final String CONSULTING_PRODUCT_NAME = 'Test Consulting Product';
    private static final String CONSULTING_PRODUCT_RATE_PLAN_NAME = 'Test Consulting Product Rate Plan';
    private static final String CONSULTING_PRODUCT_RATE_PLAN_CHARGE_NAME = 'Test Consulting Product Rate Plan Charge';
    private static final String ONE_TIME_CHARGE_PRODUCT_NAME = 'Test One-Time Charge Product';
    private static final String ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_NAME = 'Test One-Time Charge Product Rate Plan';
    private static final String ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_CHARGE_NAME = 'Test One-Time Charge Product Rate Plan Charge';
    private static final String QUOTE_TEMPLATE_NAME = 'Test Quote Template';

    private static testmethod void testInsert() {
        TestDataStruct testData = setup();

        FC_Metroclient_Product_Geography_Seg3__c testFcMetroclientProductGeographySeg3 = [
                select Id
                from
                        FC_Metroclient_Product_Geography_Seg3__c
                where Accounting_Code__c = 'AC-1'
                limit 1
        ];

        enableTriggerHandlers();

        Test.startTest();
        Zuora__SubscriptionProductCharge__c[] testSubscriptionProductCharges = new Zuora__SubscriptionProductCharge__c[]{
                new Zuora__SubscriptionProductCharge__c(Name = SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME,
                        Seg3RecordID__c = testFcMetroclientProductGeographySeg3.Id,
                        Zuora__ChargeNumber__c = 'C-1',
                        Zuora__External_Id__c = 'C-1',
                        Zuora__RatePlanId__c = '0',
                        Zuora__Subscription__c = testData.subscriptions[0].Id,
                        Zuora__RatePlanName__c = SIMPLE_PRODUCT_RATE_PLAN_NAME,
                        Zuora__ProductSKU__c = 'SKU-0',
                        Zuora__Price__c = 10000,
                        Zuora__ExtendedAmount__c = 10000)
        };
        insert testSubscriptionProductCharges;
        Test.stopTest();

        for (Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge : [
                select Id, Name, FC_Lookup_Key__c, Seg3RecordID__c, Seg3_Record__c,
                        Zuora__ProductSKU__c, Zuora__RatePlanName__c
                from Zuora__SubscriptionProductCharge__c
                where Id in :testSubscriptionProductCharges
        ]) {
            System.assertEquals(testSubscriptionProductCharge.Zuora__ProductSKU__c + '^' +
                    testSubscriptionProductCharge.Zuora__RatePlanName__c + '^' +
                    testSubscriptionProductCharge.Name,
                    testSubscriptionProductCharge.FC_Lookup_Key__c);
            System.assertEquals(testFcMetroclientProductGeographySeg3.Id, testSubscriptionProductCharge.Seg3_Record__c);
        }

        for (MetroclientAccountProductGeography__c testMetroclientAccountProductGeography : [
                select Id, Name, ChargeNumber__c, Charge__c,
                        Charge__r.Zuora__ChargeNumber__c
                from MetroclientAccountProductGeography__c
                where Charge__c in :testSubscriptionProductCharges
        ]) {
            System.assertEquals(testMetroclientAccountProductGeography.ChargeNumber__c, testMetroclientAccountProductGeography.Charge__r.Zuora__ChargeNumber__c);
        }

    }

    private static testmethod void testPreventRecursiveTrigger() {
        TestDataStruct testData = setup();
        enableTriggerHandlers();

        Zuora__SubscriptionProductCharge__c[] testSubscriptionProductCharges = new Zuora__SubscriptionProductCharge__c[]{
                new Zuora__SubscriptionProductCharge__c(Name = SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME,
                        Zuora__ChargeNumber__c = 'C-1',
                        Zuora__External_Id__c = 'C-1',
                        Zuora__RatePlanId__c = '0',
                        Zuora__Subscription__c = testData.subscriptions[0].Id,
                        Zuora__RatePlanName__c = SIMPLE_PRODUCT_RATE_PLAN_NAME,
                        Zuora__ProductSKU__c = 'SKU-1',
                        Zuora__Price__c = 10000,
                        Zuora__ExtendedAmount__c = 10000,
                        Zuora__BillingPeriod__c = 'Month')
        };
        insert testSubscriptionProductCharges;

        fcf.TriggerRunStatus.unblockAll();
        Test.startTest();

        Zuora__SubscriptionProductCharge__c testSubscriptionProductChargeToUpdate =
                new Zuora__SubscriptionProductCharge__c(Id = testSubscriptionProductCharges[0].Id,
                        Zuora__Price__c = 20000,
                        Zuora__ExtendedAmount__c = 20000);
        System.assert(fcf.TriggerRunStatus.isRunnable(
                new fcf.TriggerRunStatusItem(FC_SubscriptionProductChargeHandler.TRIGGER_RUN_STATUS_ID,
                        new Set<ID>{
                                testSubscriptionProductChargeToUpdate.Id
                        })));
        update testSubscriptionProductChargeToUpdate;
        System.assert(!fcf.TriggerRunStatus.isRunnable(
                new fcf.TriggerRunStatusItem(FC_SubscriptionProductChargeHandler.TRIGGER_RUN_STATUS_ID,
                        new Set<ID>{
                                testSubscriptionProductChargeToUpdate.Id
                        })));
        update testSubscriptionProductChargeToUpdate;
        System.assert(!fcf.TriggerRunStatus.isRunnable(
                new fcf.TriggerRunStatusItem(FC_SubscriptionProductChargeHandler.TRIGGER_RUN_STATUS_ID,
                        new Set<ID>{
                                testSubscriptionProductChargeToUpdate.Id
                        })));
        Test.stopTest();

        for (MetroclientAccountProductGeography__c testMetroclientAccountProductGeography : [
                select Id, Name, ChargeNumber__c, Charge__c,
                        Charge__r.Zuora__ChargeNumber__c
                from MetroclientAccountProductGeography__c
                where Charge__c in :testSubscriptionProductCharges
        ]) {
            System.assertEquals(testMetroclientAccountProductGeography.ChargeNumber__c, testMetroclientAccountProductGeography.Charge__r.Zuora__ChargeNumber__c);
        }

    }

    private static testMethod void testSegment2Market() {
        TestDataStruct testData = setup();
        enableTriggerHandlers();

        Zuora__SubscriptionProductCharge__c[] testSubscriptionProductCharges = new Zuora__SubscriptionProductCharge__c[]{
                new Zuora__SubscriptionProductCharge__c(Name = SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME,
                        Segment2__c = '01',
                        Zuora__ChargeNumber__c = 'C-1',
                        Zuora__External_Id__c = 'C-1',
                        Zuora__RatePlanId__c = '0',
                        Zuora__Subscription__c = testData.subscriptions[0].Id,
                        Zuora__RatePlanName__c = SIMPLE_PRODUCT_RATE_PLAN_NAME,
                        Zuora__ProductSKU__c = 'SKU-1',
                        Zuora__Price__c = 10000,
                        Zuora__ExtendedAmount__c = 10000),
                new Zuora__SubscriptionProductCharge__c(Name = SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME,
                        Segment2__c = '1',
                        Zuora__ChargeNumber__c = 'C-2',
                        Zuora__External_Id__c = 'C-2',
                        Zuora__RatePlanId__c = '0',
                        Zuora__Subscription__c = testData.subscriptions[0].Id,
                        Zuora__RatePlanName__c = SIMPLE_PRODUCT_RATE_PLAN_NAME,
                        Zuora__ProductSKU__c = 'SKU-2',
                        Zuora__Price__c = 10000,
                        Zuora__ExtendedAmount__c = 10000),
                new Zuora__SubscriptionProductCharge__c(Name = SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME,
                        Segment2__c = '11',
                        Zuora__ChargeNumber__c = 'C-3',
                        Zuora__External_Id__c = 'C-3',
                        Zuora__RatePlanId__c = '0',
                        Zuora__Subscription__c = testData.subscriptions[0].Id,
                        Zuora__RatePlanName__c = SIMPLE_PRODUCT_RATE_PLAN_NAME,
                        Zuora__ProductSKU__c = 'SKU-3',
                        Zuora__Price__c = 10000,
                        Zuora__ExtendedAmount__c = 10000),
                new Zuora__SubscriptionProductCharge__c(Name = SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME,
                        Segment2__c = '99',
                        Zuora__ChargeNumber__c = 'C-4',
                        Zuora__External_Id__c = 'C-4',
                        Zuora__RatePlanId__c = '0',
                        Zuora__Subscription__c = testData.subscriptions[0].Id,
                        Zuora__RatePlanName__c = SIMPLE_PRODUCT_RATE_PLAN_NAME,
                        Zuora__ProductSKU__c = 'SKU-4',
                        Zuora__Price__c = 10000,
                        Zuora__ExtendedAmount__c = 10000)
        };
        fcf.TriggerRunStatus.unblockAll();
        Test.startTest();
        insert testSubscriptionProductCharges;
        Test.stopTest();

        for (Zuora__SubscriptionProductCharge__c spc : [select Segment2__c, Segment2_Market_Name__c from Zuora__SubscriptionProductCharge__c]) {
            if (spc.Segment2__c == '01') {
                System.assertEquals('TEST01', spc.Segment2_Market_Name__c);
            } else if (spc.Segment2__c == '1') {
                System.assertEquals('TEST01', spc.Segment2_Market_Name__c);
            } else if (spc.Segment2__c == '11') {
                System.assertEquals('TEST11', spc.Segment2_Market_Name__c);
            } else if (spc.Segment2__c == '99') {
                System.assert(String.isBlank(spc.Segment2_Market_Name__c));
            }
        }

    }


    private static testmethod void testUpdate() {
        TestDataStruct testData = setup();
        enableTriggerHandlers();

        Zuora__SubscriptionProductCharge__c[] testSubscriptionProductCharges = new Zuora__SubscriptionProductCharge__c[]{
                new Zuora__SubscriptionProductCharge__c(Name = SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME,
                        Zuora__ChargeNumber__c = 'C-1',
                        Zuora__External_Id__c = 'C-1',
                        Zuora__RatePlanId__c = '0',
                        Zuora__Subscription__c = testData.subscriptions[0].Id,
                        Zuora__RatePlanName__c = SIMPLE_PRODUCT_RATE_PLAN_NAME,
                        Zuora__ProductSKU__c = 'SKU-1',
                        Zuora__Price__c = 10000,
                        Zuora__ExtendedAmount__c = 10000)
        };
        insert testSubscriptionProductCharges;


        fziiss__Invoice_Item__c testInvoiceItem = new fziiss__Invoice_Item__c(Name = 'II-1', Segment2__c = '00',
                fziiss__ServiceStartDate__c = Date.today(), fziiss__RatePlanChargeId__c = 'C-1',
                fziiss__Rate_Plan_Charge__c = testSubscriptionProductCharges[0].Id);
        insert testInvoiceItem;

        fcf.TriggerRunStatus.unblockAll();
        Test.startTest();

        Zuora__SubscriptionProductCharge__c testSubscriptionProductChargeToUpdate =
                new Zuora__SubscriptionProductCharge__c(Id = testSubscriptionProductCharges[0].Id,
                        Zuora__Price__c = 20000,
                        Zuora__ExtendedAmount__c = 20000);
        update testSubscriptionProductChargeToUpdate;

        Test.stopTest();

        for (Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge : [
                select Id, Name, FC_Lookup_Key__c,
                        Zuora__ProductSKU__c, Zuora__RatePlanName__c
                from Zuora__SubscriptionProductCharge__c
                where Id in :testSubscriptionProductCharges
        ]) {
            System.assertEquals(testSubscriptionProductCharge.Zuora__ProductSKU__c + '^' +
                    testSubscriptionProductCharge.Zuora__RatePlanName__c + '^' +
                    testSubscriptionProductCharge.Name,
                    testSubscriptionProductCharge.FC_Lookup_Key__c);
        }

        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = [
                select Id, FC_Most_Recent_Service_Start_Date__c
                from Zuora__SubscriptionProductCharge__c
                where Id = :testSubscriptionProductCharges[0].Id
                limit 1
        ];
        System.assertEquals(Date.today(), testSubscriptionProductCharge.FC_Most_Recent_Service_Start_Date__c);

    }

    private static void enableTriggerHandlers() {
        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_EchosignSignAgreementHandler', 'FC_ProductRatePlanChargeHandler', 'FC_QuoteHandler',
                'FC_QuoteOriginalChargeHandler', 'FC_QuoteRatePlanChargeHandler', 'FC_SubscriptionProductChargeHandler',
                'FC_MetroclientAccountProductGeoHandler'
        });
    }

    private static TestDataStruct setup() {

        FC_Approval_Threshold_Settings__c testApprovalThresholdSettings =
                new FC_Approval_Threshold_Settings__c(SetupOwnerId = UserInfo.getOrganizationId(),
                        Consulting_Quote_Total_Amount__c = 5000,
                        Non_Consulting_Quote_Total_Amount__c = 2000,
                        Non_Consulting_Charge_Total__c = 2000,
                        Quote_Discount_Percentage__c = 5,
                        Retainer_Rate_Plan_Amount__c = 2500,
                        Cancellation_Approval_Amount__c = -5000);
        upsert testApprovalThresholdSettings;

        FC_Bucket_Field_Mapping__c[] bucketFieldMappingsToInsert = new FC_Bucket_Field_Mapping__c[]{
                new FC_Bucket_Field_Mapping__c(Name = '0', Quote_Field__c = 'CCR_Custom_Report__c'),
                new FC_Bucket_Field_Mapping__c(Name = '1', Quote_Field__c = 'CCR_Expenses__c'),
                new FC_Bucket_Field_Mapping__c(Name = '2', Quote_Field__c = 'CMS_Expenses__c')
        };
        upsert bucketFieldMappingsToInsert;

        Profile testSalesProfile = [select Id from Profile where Name = 'Media - Sales Rep' limit 1];

        User testSalesUser = new User(FirstName = 'Test', LastName = 'Sales', ProfileId = testSalesProfile.Id,
                Username = FC_UuidUtil.uuidV4() + '@example.com', Email = FC_UuidUtil.uuidV4() + '@example.com',
                Alias = FC_UuidUtil.uuidV4().left(8), CommunityNickname = FC_UuidUtil.uuidV4(),
                TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US');
        insert testSalesUser;

        MetrostudySalesRegion__c testSalesRegion = new MetrostudySalesRegion__c(Abbreviation__c = 'TEST',
                Description__c = 'Test Sales Region', Name = 'Test Sales Region');
        insert testSalesRegion;

        MetrostudySalesRegionAssignment__c testSalesRegionAssignment = new MetrostudySalesRegionAssignment__c(
                Name = 'Test Sales Region Assignment', Role__c = 'RD', SalesRegion__c = testSalesRegion.Id,
                User__c = testSalesUser.Id);
        insert testSalesRegionAssignment;

        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        PricebookEntry testPricebookEntry = new PricebookEntry(IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(), Product2Id = testProduct.Id, UnitPrice = 100);
        insert testPricebookEntry;

        Map<String, zqu__ZProduct__c> testProductsMap = new Map<String, zqu__ZProduct__c>{
                SIMPLE_PRODUCT_NAME => new zqu__ZProduct__c(Name = SIMPLE_PRODUCT_NAME, zqu__SKU__c = 'SKU-0', zqu__ZuoraId__c = '0', zqu__Product__c = testProduct.Id),
                CONSULTING_PRODUCT_NAME => new zqu__ZProduct__c(Name = CONSULTING_PRODUCT_NAME, zqu__SKU__c = 'SKU-1', zqu__ZuoraId__c = '1', zqu__Product__c = testProduct.Id),
                ONE_TIME_CHARGE_PRODUCT_NAME => new zqu__ZProduct__c(Name = ONE_TIME_CHARGE_PRODUCT_NAME, zqu__SKU__c = 'SKU-2', zqu__ZuoraId__c = '2', zqu__Product__c = testProduct.Id)
        };
        upsert testProductsMap.values();

        Map<String, zqu__ProductRatePlan__c> testProductRatePlanMap = new Map<String, zqu__ProductRatePlan__c>{
                SIMPLE_PRODUCT_RATE_PLAN_NAME => new zqu__ProductRatePlan__c(Name = SIMPLE_PRODUCT_RATE_PLAN_NAME,
                        zqu__ZProduct__c = testProductsMap.get(SIMPLE_PRODUCT_NAME).Id, zqu__ZuoraId__c = '0', zqu__Product__c = testProduct.Id),
                CONSULTING_PRODUCT_RATE_PLAN_NAME => new zqu__ProductRatePlan__c(Name = CONSULTING_PRODUCT_RATE_PLAN_NAME,
                        zqu__ZProduct__c = testProductsMap.get(CONSULTING_PRODUCT_NAME).Id, zqu__ZuoraId__c = '1', zqu__Product__c = testProduct.Id),
                ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_NAME => new zqu__ProductRatePlan__c(Name = ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_NAME,
                        zqu__ZProduct__c = testProductsMap.get(ONE_TIME_CHARGE_PRODUCT_NAME).Id, zqu__ZuoraId__c = '2', zqu__Product__c = testProduct.Id)
        };
        upsert testProductRatePlanMap.values();

        Map<String, zqu__ProductRatePlanCharge__c> testProductRatePlanChargesMap = new Map<String, zqu__ProductRatePlanCharge__c>{
                SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME => new zqu__ProductRatePlanCharge__c(Name = SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME,
                        zqu__ProductRatePlan__c = testProductRatePlanMap.get(SIMPLE_PRODUCT_RATE_PLAN_NAME).Id, zqu__Type__c = 'Recurring', zqu__RecurringPeriod__c = 'Annual', zqu__ZuoraId__c = '0',
                        zqu__ListPrice__c = 10000,
                        FC_Lookup_Key__c = 'SKU-0^' + SIMPLE_PRODUCT_RATE_PLAN_NAME + '^' + SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME),
                CONSULTING_PRODUCT_RATE_PLAN_CHARGE_NAME => new zqu__ProductRatePlanCharge__c(Name = CONSULTING_PRODUCT_RATE_PLAN_CHARGE_NAME,
                        zqu__ProductRatePlan__c = testProductRatePlanMap.get(CONSULTING_PRODUCT_RATE_PLAN_NAME).Id, zqu__Type__c = 'Recurring', zqu__RecurringPeriod__c = 'Annual', zqu__ZuoraId__c = '1',
                        zqu__ListPrice__c = 10000,
                        FC_Lookup_Key__c = 'SKU-1^' + CONSULTING_PRODUCT_RATE_PLAN_NAME + '^' + CONSULTING_PRODUCT_RATE_PLAN_CHARGE_NAME),
                ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_CHARGE_NAME => new zqu__ProductRatePlanCharge__c(Name = ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_CHARGE_NAME,
                        zqu__ProductRatePlan__c = testProductRatePlanMap.get(ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_NAME).Id, zqu__Type__c = 'One-Time', zqu__ZuoraId__c = '2',
                        zqu__ListPrice__c = 10000,
                        FC_Lookup_Key__c = 'SKU-2^' + ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_NAME + '^' + ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_CHARGE_NAME)
        };
        upsert testProductRatePlanChargesMap.values();

        MetroclientProduct__c testMetroclientProduct = new MetroclientProduct__c(Name = 'Test Product',
                ProductAbbreviation__c = 'TEST');
        insert testMetroclientProduct;

        MetroclientGeographyType__c testGeographyType = new MetroclientGeographyType__c(Name = 'Test Geography Type',
                GeographyTypeId__c = 1);
        insert testGeographyType;

        MetroclientGeography__c testGeography = new MetroclientGeography__c(Name = 'Test Geography',
                GeographyType__c = testGeographyType.Id, SalesRegion__c = testSalesRegion.Id);
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
                        Product_Geography__c = testProductGeography.Id,
                        Product_Rate_Plan__c = testProductRatePlanMap.get(SIMPLE_PRODUCT_RATE_PLAN_NAME).Id,
                        Seg3__c = 'CONS');
        insert testProductGeographySeg3;

        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '12345');
        insert testAccount;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity 1', AccountId = testAccount.Id,
                StageName = 'New Opportunity', CloseDate = Date.today() + 365);
        insert testOpportunity;

        zqu__Quote_Template__c[] testQuoteTemplates = new zqu__Quote_Template__c[]{
                new zqu__Quote_Template__c(Name = QUOTE_TEMPLATE_NAME, zqu__IsDefault__c = true,
                        zqu__Quote_Type__c = 'New Subscription', zqu__Template_Id__c = '12345')
        };
        upsert testQuoteTemplates;

        Zuora__Subscription__c[] testSubscriptions = new Zuora__Subscription__c[]{
                new Zuora__Subscription__c(Name = 'S-1', Zuora__Account__c = testAccount.Id,
                        Zuora__CustomerAccount__c = testCustomerAccount.Id,
                        Zuora__Zuora_Id__c = 'S-1', Zuora__External_Id__c = 'S-1',
                        Zuora__SubscriptionStartDate__c = Date.today() - 730,
                        Zuora__NextChargeDate__c = Date.today() + 30,
                        Zuora__TermStartDate__c = Date.today() - 30,
                        Zuora__TermSettingType__c = 'EVERGREEN')
        };
        insert testSubscriptions;

        zqu__Quote__c testQuote = new zqu__Quote__c(Name = 'Test Quote',
                RecordTypeId = fcf.RecordTypeUtil.findByName('zqu__Quote__c.Amendment').Id,
                Original_Record_Type_Name__c = 'Amendment', Approval_Status__c = '',
                zqu__Opportunity__c = testOpportunity.Id, zqu__Opportunity__r = testOpportunity,
                zqu__QuoteTemplate__c = testQuoteTemplates[0].Id, zqu__QuoteTemplate__r = testQuoteTemplates[0],
                zqu__Status__c = 'New', zqu__ExistSubscriptionID__c = 'S-1');
        insert testQuote;

        zqu__QuoteAmendment__c testQuoteAmendment = new zqu__QuoteAmendment__c(Name = 'QA-1', zqu__Type__c = 'UpdateProduct', zqu__Quote__c = testQuote.Id);
        insert testQuoteAmendment;

        zqu__QuoteRatePlan__c testQuoteRatePlan = new zqu__QuoteRatePlan__c(Name = 'QRP-1', zqu__AmendmentType__c = 'UpdateProduct',
                zqu__ProductRatePlanZuoraId__c = testProductRatePlanMap.get(SIMPLE_PRODUCT_RATE_PLAN_NAME).zqu__ZuoraId__c,
                zqu__Quote__c = testQuote.Id,
                zqu__QuoteAmendment__c = testQuoteAmendment.Id);
        insert testQuoteRatePlan;

        zqu__QuoteRatePlanCharge__c testQuoteRatePlanCharge = new zqu__QuoteRatePlanCharge__c(Name = 'QRPC-1',
                zqu__QuoteRatePlan__c = testQuoteRatePlan.Id,
                zqu__ProductRatePlanChargeZuoraId__c = testProductRatePlanChargesMap.get(SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME).zqu__ZuoraId__c,
                zqu__SubscriptionRatePlanChargeZuoraId__c = 'C-1',
                zqu__ListTotal__c = 10000, zqu__Total__c = 2500,
                zqu__ChargeType__c = 'Recurring', zqu__Period__c = 'Annual');
        insert testQuoteRatePlanCharge;

        FC_Segment_2_Assignment__c[] assignments = new List<FC_Segment_2_Assignment__c>();
        assignments.add(new FC_Segment_2_Assignment__c(Name = '01', Market_Name__c = 'TEST01'));
        assignments.add(new FC_Segment_2_Assignment__c(Name = '11', Market_Name__c = 'TEST11'));
        assignments.add(new FC_Segment_2_Assignment__c(Name = '02', Market_Name__c = 'TEST02'));
        insert assignments;

        MetroclientAccountProductGeography__c testMetroclientAccountProductGeography = new MetroclientAccountProductGeography__c(Name = 'MAPG-1', ChargeNumber__c = 'C-1');
        insert testMetroclientAccountProductGeography;

        TestDataStruct result = new TestDataStruct();
        result.subscriptions.addAll(testSubscriptions);
        return result;
    }

    private class TestDataStruct {
        public Zuora__Subscription__c[] subscriptions = new List<Zuora__Subscription__c>();
    }

}