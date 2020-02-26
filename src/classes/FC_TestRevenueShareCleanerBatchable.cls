@isTest
private class FC_TestRevenueShareCleanerBatchable {

    @isTest
    private static void testDeleteAll() {

        FC_Revenue_Share__c[] testRevenueShares = [
                select Id, Obsolete__c
                from FC_Revenue_Share__c
        ];
        System.assertEquals(2, testRevenueShares.size());

        Test.startTest();
        FC_RevenueShareCleanerBatchable batchable = new FC_RevenueShareCleanerBatchable(null);
        Database.executeBatch(batchable);
        Test.stopTest();

        testRevenueShares = [
                select Id, Obsolete__c
                from FC_Revenue_Share__c
        ];
        System.assertEquals(0, testRevenueShares.size());

    }

    @isTest
    private static void testDeleteObsolete() {

        FC_Revenue_Share__c[] testRevenueShares = [
                select Id, Obsolete__c
                from FC_Revenue_Share__c
                where Obsolete__c = true and Processed_By_Batchable_On__c < :DateTime.now()
        ];
        System.assertEquals(1, testRevenueShares.size());
        System.assertEquals(true, testRevenueShares[0].Obsolete__c);

        Test.startTest();
        FC_RevenueShareCleanerBatchable batchable = new FC_RevenueShareCleanerBatchable(DateTime.now());
        Database.executeBatch(batchable);
        Test.stopTest();

        testRevenueShares = [
                select Id, Obsolete__c
                from FC_Revenue_Share__c
                where Obsolete__c = true and Processed_By_Batchable_On__c < :DateTime.now()
        ];
        System.assertEquals(0, testRevenueShares.size());
    }

    @testSetup
    private static void setup() {

        FC_Revenue_Share_Settings__c testRevenueShareSettings = new FC_Revenue_Share_Settings__c(
                SetupOwnerId = UserInfo.getOrganizationId(), Last_Run_On__c = Date.today().addYears(-1));
        insert testRevenueShareSettings;

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

        Opportunity[] testOpportunities = new List<Opportunity>{
                new Opportunity(Name = 'Test Opportunity',
                        AccountId = testAccount.Id, Amount = 100,
                        StageName = 'New Opportunity', CloseDate = Date.today(), FC_Last_Sent_To_Zuora__c = DateTime.now(),
                        FC_Term_End_Date__c = Date.today() + 30,
                        FC_Renew__c = true, FC_Contract_Effective_Date__c = Date.today(), FC_Term_Type__c = 'TERMED')
        };
        insert testOpportunities;

        String[] uuids = new List<String>();
        for (Integer i = 0; i < 6; i++) {
            uuids.add(FC_UuidUtil.uuidV4());
        }
        OpportunityLineItem[] testOpportunityLineItems = new OpportunityLineItem[]{
                new OpportunityLineItem(OpportunityId = testOpportunities[0].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3s[0].Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[0],
                        FC_Zuora_Action__c = 'Update'),
                new OpportunityLineItem(OpportunityId = testOpportunities[0].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3s[1].Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[1],
                        FC_Zuora_Action__c = 'Update')
        };
        insert testOpportunityLineItems;

        Opportunity testOpportunity = [select Id, LastModifiedDate from Opportunity where Id = :testOpportunities[0].Id limit 1];
        AggregateResult testOpportunityLineItemAggregateResult = [
                select OpportunityId, max(LastModifiedDate) maxLastModifiedDate
                from OpportunityLineItem
                where OpportunityId = :testOpportunities[0].Id
                group by OpportunityId
        ];
        FC_Revenue_Share__c[] testRevenueShares = new FC_Revenue_Share__c[]{
                new FC_Revenue_Share__c(Opportunity__c = testOpportunities[0].Id,
                        Opportunity_Last_Modified_Date__c = testOpportunity.LastModifiedDate,
                        Processed_By_Batchable_On__c = DateTime.now().addDays(-1)),
                new FC_Revenue_Share__c(Opportunity__c = testOpportunities[0].Id,
                        Opportunity_Last_Modified_Date__c = DateTime.now().addDays(-1),
                        Recent_Opp_Line_Item_Last_Modified_Date__c = (DateTime) testOpportunityLineItemAggregateResult.get('maxLastModifiedDate'),
                        Processed_By_Batchable_On__c = DateTime.now().addDays(-1))
        };
        insert testRevenueShares;

    }

}