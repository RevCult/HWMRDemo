@isTest
private class FC_TestOpportunityLineItemHandler {

    private static final String NEW_OPPORTUNITY_1_NAME = 'Test New Opportunity 1';
    private static final String NEW_OPPORTUNITY_2_NAME = 'Test New Opportunity 2';
    private static final String EXISTING_OPPORTUNITY_NAME = 'Test Existing Opportunity';
    private static final String NO_UPDATE_OPPORTUNITY_NAME = 'Test No-Update Opportunity';

    @isTest
    private static void testInsert() {

        PricebookEntry testPricebookEntry = [
                select Id
                from PricebookEntry
                where Product2.Name = 'Test Product' and Pricebook2Id = :Test.getStandardPricebookId()
                limit 1
        ];

        FC_Metroclient_Product_Geography_Seg3__c testProductGeographySeg3 = [
                select Id
                from FC_Metroclient_Product_Geography_Seg3__c
                where Accounting_Code__c = 'AC-1'
                limit 1
        ];


        Opportunity[] testOpportunities = [
                select Id, Name, FC_Contract_Effective_Date__c, FC_Service_Activation_Date__c,
                        FC_Target_Date__c, FC_Term_Start_Date__c, FC_Term_End_Date__c, FC_Initial_Term__c
                from Opportunity
                where Name in :(new Set<String>{
                        NEW_OPPORTUNITY_1_NAME, NEW_OPPORTUNITY_2_NAME, NO_UPDATE_OPPORTUNITY_NAME
                })
        ];
        System.assertEquals(3, testOpportunities.size());

        Map<String, Opportunity> testOpportunityMap = new Map<String, Opportunity>();
        for (Opportunity testOpportunity : testOpportunities) {
            testOpportunityMap.put(testOpportunity.Name, testOpportunity);
        }

        Map<String, Id> testBillingInstructionTemplateNameToIdMap = new Map<String, Id>();
        for (FC_Billing_Instruction_Template__c testBillingInstructionTemplate : [
                select Id, Name
                from FC_Billing_Instruction_Template__c
        ]) {
            testBillingInstructionTemplateNameToIdMap.put(testBillingInstructionTemplate.Name, testBillingInstructionTemplate.Id);
        }
        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_OpportunityLineItemHandler'
        });

        String[] uuids = new List<String>();
        for (Integer i = 0; i < 4; i++) {
            uuids.add(FC_UuidUtil.uuidV4());
        }

        Test.startTest();

        FC_Billing_Instruction_Set__c[] testBillingInstructionSets =
                new FC_Billing_Instruction_Set__c[]{
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunityMap.get(NEW_OPPORTUNITY_1_NAME).Id,
                                Opportunity_Line_Item_UUID__c = uuids[0], Template__c = testBillingInstructionTemplateNameToIdMap.get('Free Months'),
                                Instruction_Parameters__c = '{"numberOfFreeMonths":"1"}'),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunityMap.get(NEW_OPPORTUNITY_2_NAME).Id,
                                Opportunity_Line_Item_UUID__c = uuids[1], Template__c = testBillingInstructionTemplateNameToIdMap.get('Opt Out'),
                                Instruction_Parameters__c = '{"duration":"1"}'),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunityMap.get(NO_UPDATE_OPPORTUNITY_NAME).Id,
                                Opportunity_Line_Item_UUID__c = uuids[2], Template__c = testBillingInstructionTemplateNameToIdMap.get('Opt Out'),
                                Instruction_Parameters__c = '{"duration":"1"}')
                };
        insert testBillingInstructionSets;

        OpportunityLineItem[] testOpportunityLineItems = new OpportunityLineItem[]{
                new OpportunityLineItem(OpportunityId = testOpportunityMap.get(NEW_OPPORTUNITY_1_NAME).Id,
                        PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100, FC_Effective_Date__c = Date.today(),
                        Billing_Frequency__c = 'One-Time', FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id,
                        FC_Billing_Instruction_Set__c = testBillingInstructionSets[0].Id, FC_UUID__c = uuids[0],
                        FC_Zuora_Action__c = 'Add', FC_Sale_Price__c = 100),
                new OpportunityLineItem(OpportunityId = testOpportunityMap.get(NEW_OPPORTUNITY_2_NAME).Id,
                        PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100, FC_Effective_Date__c = Date.today(),
                        Billing_Frequency__c = 'Monthly', FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id,
                        FC_Billing_Instruction_Set__c = testBillingInstructionSets[1].Id, FC_UUID__c = uuids[1],
                        FC_Zuora_Action__c = 'No Action', FC_Sale_Price__c = 100),
                new OpportunityLineItem(OpportunityId = testOpportunityMap.get(NO_UPDATE_OPPORTUNITY_NAME).Id,
                        PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100, FC_Effective_Date__c = Date.today(),
                        Billing_Frequency__c = 'Monthly', FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id,
                        FC_Billing_Instruction_Set__c = testBillingInstructionSets[2].Id, FC_UUID__c = uuids[2],
                        FC_Zuora_Action__c = 'No Action', FC_Sale_Price__c = 100)
        };
        insert testOpportunityLineItems;

        Test.stopTest();

        testOpportunityLineItems = [
                select Id, Opportunity.Name, FC_End_Date__c
                from OpportunityLineItem
                where Id in :testOpportunityLineItems
        ];

        Map<String, OpportunityLineItem> testOpportunityLineItemMap = new Map<String, OpportunityLineItem>();
        for (OpportunityLineItem testOpportunityLineItem : testOpportunityLineItems) {
            testOpportunityLineItemMap.put(testOpportunityLineItem.Opportunity.Name, testOpportunityLineItem);
        }

        System.assertEquals(Date.today().addMonths(13), testOpportunityLineItemMap.get(NEW_OPPORTUNITY_1_NAME).FC_End_Date__c);
        System.assertEquals(Date.today().addMonths(13), testOpportunityLineItemMap.get(NEW_OPPORTUNITY_2_NAME).FC_End_Date__c);
        System.assertEquals(null, testOpportunityLineItemMap.get(NO_UPDATE_OPPORTUNITY_NAME).FC_End_Date__c);
    }

    @isTest
    private static void testUpdate() {

        Opportunity testOpportunity = [
                select Id, Name, FC_Contract_Effective_Date__c, FC_Service_Activation_Date__c,
                        FC_Target_Date__c, FC_Term_Start_Date__c, FC_Term_End_Date__c, FC_Initial_Term__c
                from Opportunity
                where Name = :EXISTING_OPPORTUNITY_NAME
                limit 1
        ];

        OpportunityLineItem[] testOpportunityLineItems = [
                select Id
                from OpportunityLineItem
                where OpportunityId = :testOpportunity.Id
        ];

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_OpportunityLineItemHandler'
        });

        Test.startTest();

        update testOpportunityLineItems;

        Test.stopTest();

        testOpportunityLineItems = [
                select Id, Opportunity.Name, FC_End_Date__c, FC_Zuora_Action__c, UnitPrice
                from OpportunityLineItem
                where Id in :testOpportunityLineItems
        ];

        for (OpportunityLineItem testOpportunityLineItem : testOpportunityLineItems) {

            if (testOpportunityLineItem.FC_Zuora_Action__c == 'Add') {
                System.assertEquals(100, testOpportunityLineItem.UnitPrice);
            } else if (testOpportunityLineItem.FC_Zuora_Action__c == 'Update') {
                System.assertEquals(100, testOpportunityLineItem.UnitPrice);
            } else if (testOpportunityLineItem.FC_Zuora_Action__c == 'Remove') {
                System.assertEquals(-100, testOpportunityLineItem.UnitPrice);
            } else if (testOpportunityLineItem.FC_Zuora_Action__c == 'No Action') {
                System.assertEquals(0, testOpportunityLineItem.UnitPrice);
            }

        }
    }

    @isTest
    private static void testDelete() {

        Opportunity testOpportunity = [
                select Id, Name, FC_Contract_Effective_Date__c, FC_Service_Activation_Date__c,
                        FC_Target_Date__c, FC_Term_Start_Date__c, FC_Term_End_Date__c, FC_Initial_Term__c
                from Opportunity
                where Name = :EXISTING_OPPORTUNITY_NAME
                limit 1
        ];

        OpportunityLineItem[] testOpportunityLineItems = [
                select Id
                from OpportunityLineItem
                where OpportunityId = :testOpportunity.Id
        ];

        FC_Billing_Instruction_Set__c[] testBillingInstructionSets = [
                select Id
                from FC_Billing_Instruction_Set__c
                where Opportunity__c = :testOpportunity.Id
        ];

        System.assertEquals(4, testOpportunityLineItems.size());
        System.assertEquals(4, testBillingInstructionSets.size());

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_OpportunityLineItemHandler'
        });

        Test.startTest();

        delete testOpportunityLineItems;

        Test.stopTest();

        testOpportunityLineItems = [
                select Id
                from OpportunityLineItem
                where OpportunityId = :testOpportunity.Id
        ];

        testBillingInstructionSets = [
                select Id
                from FC_Billing_Instruction_Set__c
                where Opportunity__c = :testOpportunity.Id
        ];

        System.assertEquals(0, testOpportunityLineItems.size());
        System.assertEquals(0, testBillingInstructionSets.size());
    }

    @testSetup
    private static void setup() {

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

        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '12345');
        insert testAccount;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today());
        insert testSubscription;

        Contract testContract = new Contract(AccountId = testAccount.Id, FC_Subscription_Number__c = 'S-1',
                FC_Subscription__c = testSubscription.Id, FC_Price_Book__c = Test.getStandardPricebookId());
        insert testContract;

        Opportunity[] testOpportunities = new Opportunity[]{
                new Opportunity(Name = NEW_OPPORTUNITY_1_NAME,
                        AccountId = testAccount.Id, Amount = 100,
                        StageName = 'New Opportunity', CloseDate = Date.today(),
                        RecordTypeId = fcf.RecordTypeUtil.findByName('Opportunity.Metrostudy_Opportunity_Record_Type_Consult').Id,
                        FC_Term_Type__c = 'TERMED', FC_Contract_Effective_Date__c = Date.today(), FC_Initial_Term__c = 12, Skip_Validation__c = true),
                new Opportunity(Name = NEW_OPPORTUNITY_2_NAME, AccountId = testAccount.Id, Amount = 100,
                        StageName = 'New Opportunity', CloseDate = Date.today(),
                        RecordTypeId = fcf.RecordTypeUtil.findByName('Opportunity.Metrostudy_Opportunity_Record_Type_Consult').Id,
                        FC_Term_Type__c = 'EVERGREEN', FC_Contract_Effective_Date__c = Date.today(), FC_Initial_Term__c = 12, Skip_Validation__c = true),
                new Opportunity(Name = NO_UPDATE_OPPORTUNITY_NAME, AccountId = testAccount.Id, Amount = 100, ContractId = testContract.Id,
                        OwnerId = testSalesUser.Id, StageName = 'New Opportunity', CloseDate = Date.today(),
                        RecordTypeId = fcf.RecordTypeUtil.findByName('Opportunity.Media').Id,
                        FC_Term_Type__c = 'EVERGREEN', FC_Contract_Effective_Date__c = Date.today(), FC_Initial_Term__c = 12, Skip_Validation__c = true),
                new Opportunity(Name = EXISTING_OPPORTUNITY_NAME, AccountId = testAccount.Id, Amount = 100,
                        StageName = 'New Opportunity', CloseDate = Date.today(), ContractId = testContract.Id,
                        RecordTypeId = fcf.RecordTypeUtil.findByName('Opportunity.Metrostudy_Opportunity_Record_Type_Consult').Id,
                        FC_Term_Type__c = 'EVERGREEN', FC_Contract_Effective_Date__c = Date.today(), FC_Initial_Term__c = 12, Skip_Validation__c = true)
        };
        insert testOpportunities;

        String[] uuids = new List<String>();
        for (Integer i = 0; i < 4; i++) {
            uuids.add(FC_UuidUtil.uuidV4());
        }

        Map<String, FC_Billing_Instruction_Template__c> testBillingInstructionTemplateMap =
                new Map<String, FC_Billing_Instruction_Template__c>{
                        'Standard' => new FC_Billing_Instruction_Template__c(Name = 'Standard'),
                        'Ramp Up' => new FC_Billing_Instruction_Template__c(Name = 'Ramp Up'),
                        'Step Up' => new FC_Billing_Instruction_Template__c(Name = 'Step Up'),
                        'Opt Out' => new FC_Billing_Instruction_Template__c(Name = 'Opt Out'),
                        'Free Months' => new FC_Billing_Instruction_Template__c(Name = 'Free Months')
                };
        insert testBillingInstructionTemplateMap.values();

        FC_Billing_Instruction_Set__c[] testBillingInstructionSets =
                new FC_Billing_Instruction_Set__c[]{
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunities[3].Id,
                                Opportunity_Line_Item_UUID__c = uuids[0], Template__c = testBillingInstructionTemplateMap.get('Free Months').Id,
                                Instruction_Parameters__c = '{"numberOfFreeMonths":"1"}'),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunities[3].Id,
                                Opportunity_Line_Item_UUID__c = uuids[1], Template__c = testBillingInstructionTemplateMap.get('Opt Out').Id,
                                Instruction_Parameters__c = '{"duration":"1"}'),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunities[3].Id,
                                Opportunity_Line_Item_UUID__c = uuids[2], Template__c = testBillingInstructionTemplateMap.get('Standard').Id,
                                Instruction_Parameters__c = 'BAD'),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunities[3].Id,
                                Opportunity_Line_Item_UUID__c = uuids[3], Template__c = testBillingInstructionTemplateMap.get('Opt Out').Id,
                                Instruction_Parameters__c = '{"duration":"1"}')
                };
        insert testBillingInstructionSets;

        OpportunityLineItem[] testOpportunityLineItems = new OpportunityLineItem[]{
                new OpportunityLineItem(OpportunityId = testOpportunities[3].Id,
                        PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100, FC_Effective_Date__c = Date.today(),
                        Billing_Frequency__c = 'One-Time', FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id,
                        FC_Billing_Instruction_Set__c = testBillingInstructionSets[0].Id, FC_UUID__c = uuids[0],
                        FC_Zuora_Action__c = 'Add', FC_Sale_Price__c = 100),
                new OpportunityLineItem(OpportunityId = testOpportunities[3].Id,
                        PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100, FC_Effective_Date__c = Date.today(),
                        Billing_Frequency__c = 'Monthly', FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id,
                        FC_Billing_Instruction_Set__c = testBillingInstructionSets[1].Id, FC_UUID__c = uuids[1],
                        FC_Zuora_Action__c = 'No Action', FC_Original_Sale_Price__c = 100, FC_Sale_Price__c = 100),
                new OpportunityLineItem(OpportunityId = testOpportunities[3].Id,
                        PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100, FC_Effective_Date__c = Date.today(),
                        Billing_Frequency__c = 'Monthly', FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id,
                        FC_Billing_Instruction_Set__c = testBillingInstructionSets[2].Id, FC_UUID__c = uuids[2],
                        FC_Zuora_Action__c = 'Remove', FC_Original_Sale_Price__c = 100, FC_Sale_Price__c = 100),
                new OpportunityLineItem(OpportunityId = testOpportunities[3].Id,
                        PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100, FC_Effective_Date__c = Date.today(),
                        Billing_Frequency__c = 'Monthly', FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id,
                        FC_Billing_Instruction_Set__c = testBillingInstructionSets[3].Id, FC_UUID__c = uuids[3],
                        FC_Original_Sale_Price__c = 100,
                        FC_Zuora_Action__c = 'Update', FC_Sale_Price__c = 200)
        };
        insert testOpportunityLineItems;

        FC_Billing_Instruction_Step__c[] testBillingInstructionSteps =
                new FC_Billing_Instruction_Step__c[]{
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[0].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'New')
                };
        insert testBillingInstructionSteps;

        FC_Billing_Instruction_Step__Tag[] testBillingInstructionStepTags =
                new FC_Billing_Instruction_Step__Tag[]{
                        new FC_Billing_Instruction_Step__Tag(ItemId = testBillingInstructionSteps[0].Id,
                                Name = 'Balance Due', Type = 'Public'),
                        new FC_Billing_Instruction_Step__Tag(ItemId = testBillingInstructionSteps[0].Id,
                                Name = 'Expenses', Type = 'Public')
                };
        insert testBillingInstructionStepTags;

    }

}