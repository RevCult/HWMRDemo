@isTest
private class FC_TestRevenueShareProcessorBatchable {

    @isTest
    private static void testBatchable() {

        Test.startTest();
        FC_RevenueShareProcessorBatchable batchable = new FC_RevenueShareProcessorBatchable(false);
        Database.executeBatch(batchable);
        Test.stopTest();

        Map<Id, OpportunityLineItem> testOpportunityLineItemsLookupMap = new Map<Id, OpportunityLineItem>([
                select Id, FC_Geography_Type__c, FC_Seg2__c, TotalPrice
                from OpportunityLineItem
                where Opportunity.Account.Name = 'Test Account'
        ]);
        FC_Revenue_Share__c[] testRevenueShares = [
                select Id, Allocated_Total_Revenue__c, Allocation_Percentage__c, Obsolete__c,
                        Opportunity_Line_Item_ID__c, Segment_2__c
                from FC_Revenue_Share__c
                where Opportunity_Line_Item_ID__c in :testOpportunityLineItemsLookupMap.keySet()
        ];

        System.assertEquals(10, testRevenueShares.size());
        for (FC_Revenue_Share__c testRevenueShare : testRevenueShares) {
            OpportunityLineItem testOpportunityLineItem = testOpportunityLineItemsLookupMap.get(testRevenueShare.Opportunity_Line_Item_ID__c);
            if (testOpportunityLineItem.FC_Seg2__c == '00') {
                if (testRevenueShare.Segment_2__c == '01') {
                    System.assertEquals(10, testRevenueShare.Allocated_Total_Revenue__c);
                } else if (testRevenueShare.Segment_2__c == '02') {
                    System.assertEquals(20, testRevenueShare.Allocated_Total_Revenue__c);
                } else if (testRevenueShare.Segment_2__c == '03') {
                    System.assertEquals(30, testRevenueShare.Allocated_Total_Revenue__c);
                } else if (testRevenueShare.Segment_2__c == '04') {
                    System.assertEquals(30, testRevenueShare.Allocated_Total_Revenue__c);
                } else {
                    System.assert(false);
                }
            } else {
                if (testOpportunityLineItem.FC_Geography_Type__c == 'State') {
                    if (testRevenueShare.Segment_2__c == '03') {
                        System.assertEquals(50, testRevenueShare.Allocated_Total_Revenue__c);
                    } else if (testRevenueShare.Segment_2__c == '04') {
                        System.assertEquals(50, testRevenueShare.Allocated_Total_Revenue__c);
                    }
                } else {
                    System.assertEquals(100, testRevenueShare.Allocated_Total_Revenue__c);
                }

            }
            System.assertEquals(false, testRevenueShare.Obsolete__c);
        }
    }

    @testSetup
    private static void setup() {

        FC_Revenue_Share_Settings__c testRevenueShareSettings = new FC_Revenue_Share_Settings__c(
                SetupOwnerId = UserInfo.getOrganizationId(), Last_Run_On__c = Date.today().addYears(-1));
        insert testRevenueShareSettings;

        FC_Segment_2_Assignment__c[] testSegment2Assignments = new FC_Segment_2_Assignment__c[]{
                new FC_Segment_2_Assignment__c(Name = '01', Market_Name__c = 'TEST MARKET 1', Allocation_Percentage__c = 10),
                new FC_Segment_2_Assignment__c(Name = '02', Market_Name__c = 'TEST MARKET 2', Allocation_Percentage__c = 20),
                new FC_Segment_2_Assignment__c(Name = '03', State__c = 'Test Geography 03', Market_Name__c = 'TEST MARKET 3', Allocation_Percentage__c = 30),
                new FC_Segment_2_Assignment__c(Name = '04', State__c = 'Test Geography 03', Market_Name__c = 'TEST MARKET 4', Allocation_Percentage__c = 30)
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

        MetroclientGeographyType__c[] testGeographyTypes = new MetroclientGeographyType__c[]{
                new MetroclientGeographyType__c(Name = 'Country', GeographyTypeId__c = 1),
                new MetroclientGeographyType__c(Name = 'State', GeographyTypeId__c = 2)
        };
        insert testGeographyTypes;

        MetroclientGeography__c[] testGeographies = new MetroclientGeography__c[]{
                new MetroclientGeography__c(Name = 'Test Geography 00', GeographyType__c = testGeographyTypes[0].Id, Seg2__c = '00'),
                new MetroclientGeography__c(Name = 'Test Geography 01', GeographyType__c = testGeographyTypes[1].Id, Seg2__c = '01'),
                new MetroclientGeography__c(Name = 'Test Geography 02', GeographyType__c = testGeographyTypes[1].Id, Seg2__c = '02'),
                new MetroclientGeography__c(Name = 'Test Geography 03', GeographyType__c = testGeographyTypes[1].Id, Seg2__c = '03'),
                new MetroclientGeography__c(Name = 'Test Geography 04', GeographyType__c = testGeographyTypes[1].Id, Seg2__c = '04')
        };
        insert testGeographies;

        MetroclientProductGeographyType__c[] testProductGeographyTypes = new MetroclientProductGeographyType__c[]{
                new MetroclientProductGeographyType__c(Name = 'Test Product Geography Type 00',
                        GeographyType__c = testGeographyTypes[0].Id, Product__c = testMetroclientProduct.Id),
                new MetroclientProductGeographyType__c(Name = 'Test Product Geography Type 01',
                        GeographyType__c = testGeographyTypes[1].Id, Product__c = testMetroclientProduct.Id),
                new MetroclientProductGeographyType__c(Name = 'Test Product Geography Type 02',
                        GeographyType__c = testGeographyTypes[1].Id, Product__c = testMetroclientProduct.Id),
                new MetroclientProductGeographyType__c(Name = 'Test Product Geography Type 03',
                        GeographyType__c = testGeographyTypes[1].Id, Product__c = testMetroclientProduct.Id),
                new MetroclientProductGeographyType__c(Name = 'Test Product Geography Type 04',
                        GeographyType__c = testGeographyTypes[1].Id, Product__c = testMetroclientProduct.Id)
        };
        insert testProductGeographyTypes;

        MetroclientProductGeography__c[] testProductGeographies = new MetroclientProductGeography__c[]{
                new MetroclientProductGeography__c(
                        Name = 'Test Product Geography 00', Geography__c = testGeographies[0].Id,
                        ProductGeographyType__c = testProductGeographyTypes[0].Id),
                new MetroclientProductGeography__c(
                        Name = 'Test Product Geography 01', Geography__c = testGeographies[1].Id,
                        ProductGeographyType__c = testProductGeographyTypes[1].Id),
                new MetroclientProductGeography__c(
                        Name = 'Test Product Geography 02', Geography__c = testGeographies[2].Id,
                        ProductGeographyType__c = testProductGeographyTypes[2].Id),
                new MetroclientProductGeography__c(
                        Name = 'Test Product Geography 03', Geography__c = testGeographies[3].Id,
                        ProductGeographyType__c = testProductGeographyTypes[3].Id),
                new MetroclientProductGeography__c(
                        Name = 'Test Product Geography 04', Geography__c = testGeographies[3].Id,
                        ProductGeographyType__c = testProductGeographyTypes[4].Id)
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
                                Seg3__c = 'CONS'),
                        new FC_Metroclient_Product_Geography_Seg3__c(Accounting_Code__c = 'AC-02', Charge_Type__c = 'Recurring',
                                Dependent_Seg3__c = null, Exclude_From_Product_Selector__c = false,
                                Execute_Immediately__c = true, Product__c = testProduct.Id,
                                Product_Geography__c = testProductGeographies[2].Id, Product_Rate_Plan__c = testProductRatePlan.Id,
                                Seg3__c = 'CONS'),
                        new FC_Metroclient_Product_Geography_Seg3__c(Accounting_Code__c = 'AC-03', Charge_Type__c = 'Recurring',
                                Dependent_Seg3__c = null, Exclude_From_Product_Selector__c = false,
                                Execute_Immediately__c = true, Product__c = testProduct.Id,
                                Product_Geography__c = testProductGeographies[3].Id, Product_Rate_Plan__c = testProductRatePlan.Id,
                                Seg3__c = 'CONS'),
                        new FC_Metroclient_Product_Geography_Seg3__c(Accounting_Code__c = 'AC-04', Charge_Type__c = 'Recurring',
                                Dependent_Seg3__c = null, Exclude_From_Product_Selector__c = false,
                                Execute_Immediately__c = true, Product__c = testProduct.Id,
                                Product_Geography__c = testProductGeographies[4].Id, Product_Rate_Plan__c = testProductRatePlan.Id,
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
                        FC_Zuora_Action__c = 'Update'),
                new OpportunityLineItem(OpportunityId = testOpportunities[0].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3s[2].Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[2],
                        FC_Zuora_Action__c = 'Update'),
                new OpportunityLineItem(OpportunityId = testOpportunities[0].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3s[3].Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[3],
                        FC_Zuora_Action__c = 'Update'),
                new OpportunityLineItem(OpportunityId = testOpportunities[0].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3s[4].Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[4],
                        FC_Zuora_Action__c = 'Update')
        };
        insert testOpportunityLineItems;

    }
}