@isTest
private class FC_TestChargeRevenueShareCleanerBatch {

    @isTest
    private static void testDeleteAll() {

        FC_Charge_Revenue_Share__c[] testChargeRevenueShares = [
                select Id, Obsolete__c
                from FC_Charge_Revenue_Share__c
        ];
        System.assertEquals(2, testChargeRevenueShares.size());

        Test.startTest();
        FC_ChargeRevenueShareCleanerBatchable batchable = new FC_ChargeRevenueShareCleanerBatchable(null);
        Database.executeBatch(batchable);
        Test.stopTest();

        testChargeRevenueShares = [
                select Id, Obsolete__c
                from FC_Charge_Revenue_Share__c
        ];
        System.assertEquals(0, testChargeRevenueShares.size());

    }

    @isTest
    private static void testDeleteObsolete() {

        FC_Charge_Revenue_Share__c[] testChargeRevenueShares = [
                select Id, Obsolete__c
                from FC_Charge_Revenue_Share__c
                where Obsolete__c = true and Processed_By_Batchable_On__c < :DateTime.now()
        ];
        System.assertEquals(1, testChargeRevenueShares.size());
        System.assertEquals(true, testChargeRevenueShares[0].Obsolete__c);

        Test.startTest();
        FC_ChargeRevenueShareCleanerBatchable batchable = new FC_ChargeRevenueShareCleanerBatchable(DateTime.now());
        Database.executeBatch(batchable);
        Test.stopTest();

        testChargeRevenueShares = [
                select Id, Obsolete__c
                from FC_Charge_Revenue_Share__c
                where Obsolete__c = true and Processed_By_Batchable_On__c < :DateTime.now()
        ];
        System.assertEquals(0, testChargeRevenueShares.size());
    }

    @testSetup
    private static void setup() {

        FC_Charge_Revenue_Share_Settings__c testChargeRevenueShareSettings = new FC_Charge_Revenue_Share_Settings__c(
                SetupOwnerId = UserInfo.getOrganizationId(), Last_Run_On__c = Date.today().addYears(-1));
        insert testChargeRevenueShareSettings;

        FC_Segment_2_Assignment__c[] testSegment2Assignments = new FC_Segment_2_Assignment__c[]{
                new FC_Segment_2_Assignment__c(Name = '01', Market_Name__c = 'TEST MARKET 1', Allocation_Percentage__c = 10),
                new FC_Segment_2_Assignment__c(Name = '02', Market_Name__c = 'TEST MARKET 2', Allocation_Percentage__c = 20)
        };
        insert testSegment2Assignments;

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

        MetroclientGeography__c[] testGeographies = new MetroclientGeography__c[]{
                new MetroclientGeography__c(Name = 'Test Geography 00', GeographyType__c = testGeographyType.Id, Seg2__c = '00'),
                new MetroclientGeography__c(Name = 'Test Geography 01', GeographyType__c = testGeographyType.Id, Seg2__c = '01')
        };
        insert testGeographies;

        MetroclientProductGeographyType__c testProductGeographyType =
                new MetroclientProductGeographyType__c(Name = 'Test Product Geography Type',
                        GeographyType__c = testGeographyType.Id, Product__c = testMetroclientProduct.Id);
        insert testProductGeographyType;

        MetroclientProductGeography__c[] testProductGeographies = new MetroclientProductGeography__c[]{
                new MetroclientProductGeography__c(
                        Name = 'Test Product Geography 00', Geography__c = testGeographies[0].Id,
                        ProductGeographyType__c = testProductGeographyType.Id),
                new MetroclientProductGeography__c(
                        Name = 'Test Product Geography 01', Geography__c = testGeographies[1].Id,
                        ProductGeographyType__c = testProductGeographyType.Id)
        };
        insert testProductGeographies;

        FC_Metroclient_Product_Geography_Seg3__c[] testProductGeographySeg3s =
                new FC_Metroclient_Product_Geography_Seg3__c[]{
                        new FC_Metroclient_Product_Geography_Seg3__c(Accounting_Code__c = 'AC-00', Charge_Type__c = 'Recurring',
                                Dependent_Seg3__c = null, Exclude_From_Product_Selector__c = false,
                                Execute_Immediately__c = true, Product__c = testProduct.Id,
                                Product_Geography__c = testProductGeographies[0].Id, Product_Rate_Plan__c = testProductRatePlan.Id,
                                Seg3__c = 'CONS'),
                        new FC_Metroclient_Product_Geography_Seg3__c(Accounting_Code__c = 'AC-01', Charge_Type__c = 'Recurring',
                                Dependent_Seg3__c = null, Exclude_From_Product_Selector__c = false,
                                Execute_Immediately__c = true, Product__c = testProduct.Id,
                                Product_Geography__c = testProductGeographies[1].Id, Product_Rate_Plan__c = testProductRatePlan.Id,
                                Seg3__c = 'CONS')
                };
        insert testProductGeographySeg3s;

        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '12345');
        insert testAccount;

        Contact[] testContacts = new Contact[]{
                new Contact(AccountId = testAccount.Id, FirstName = 'Test First', LastName = 'Test Last',
                        MailingStreet = 'Test Addresss1\nTest Address2', MailingCity = 'Test City', MailingStateCode = 'NY',
                        MailingPostalCode = '12345', MailingCountryCode = 'US'),
                new Contact(AccountId = testAccount.Id, LastName = 'Test Last')
        };
        insert testContacts;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c[] testSubscriptions = new List<Zuora__Subscription__c>{
                new Zuora__Subscription__c(Name = 'S-1', Zuora__Account__c = testAccount.Id,
                        Zuora__CustomerAccount__c = testCustomerAccount.Id, Zuora__External_Id__c = 'S-1',
                        Zuora__SubscriptionNumber__c = 'S-1', Zuora__Zuora_Id__c = 'S-1')
        };
        insert testSubscriptions;

        Zuora__SubscriptionProductCharge__c[] testCharges = new List<Zuora__SubscriptionProductCharge__c>{
                new Zuora__SubscriptionProductCharge__c(Name = 'SPC-1',
                        Seg3RecordID__c = testProductGeographySeg3s[0].Id,
                        Seg3_Record__c = testProductGeographySeg3s[0].Id,
                        Zuora__ChargeNumber__c = 'SPC-1', Zuora__External_Id__c = 'SPC-1',
                        Zuora__MonthlyRecurringRevenue__c = 100, Zuora__Subscription__c = testSubscriptions[0].Id,
                        Zuora__SubscriptionChargeNumber__c = 'SPC-1'),
                new Zuora__SubscriptionProductCharge__c(Name = 'SPC-2',
                        Seg3RecordID__c = testProductGeographySeg3s[1].Id,
                        Seg3_Record__c = testProductGeographySeg3s[1].Id,
                        Zuora__ChargeNumber__c = 'SPC-2', Zuora__External_Id__c = 'SPC-2',
                        Zuora__MonthlyRecurringRevenue__c = 100, Zuora__Subscription__c = testSubscriptions[0].Id,
                        Zuora__SubscriptionChargeNumber__c = 'SPC-2')
        };
        insert testCharges;

        FC_Charge_Revenue_Share__c[] testChargeRevenueShares = new FC_Charge_Revenue_Share__c[]{
                new FC_Charge_Revenue_Share__c(Subscription_Product_Charge__c = testCharges[0].Id,
                        Charge_Last_Modified_Date__c = testCharges[0].LastModifiedDate,
                        Processed_By_Batchable_On__c = DateTime.now().addDays(-1)),
                new FC_Charge_Revenue_Share__c(Subscription_Product_Charge__c = testCharges[0].Id,
                        Charge_Last_Modified_Date__c = DateTime.now().addDays(-1),
                        Processed_By_Batchable_On__c = DateTime.now().addDays(-1))
        };
        insert testChargeRevenueShares;

    }
}