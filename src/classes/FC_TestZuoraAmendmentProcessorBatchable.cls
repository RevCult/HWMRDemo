@isTest
private class FC_TestZuoraAmendmentProcessorBatchable {

    @isTest
    private static void testBatchable() {

        Opportunity testOpportunity = [
                select Id
                from Opportunity
                where Name = 'Test Existing Subscription Opportunity'
                limit 1
        ];

        FC_Billing_Instruction_Step__c[] testBillingInstructionSteps = [
                select Id, Status__c
                from FC_Billing_Instruction_Step__c
                where Billing_Instruction_Set__r.Opportunity__c = :testOpportunity.Id
        ];

        for (FC_Billing_Instruction_Step__c testBillingInstructionStep : testBillingInstructionSteps) {
            System.assertEquals('Pending', testBillingInstructionStep.Status__c);
        }

        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        Test.startTest();
        Id asyncJobId = Database.executeBatch(new FC_ZuoraAmendmentProcessorBatchable(testOpportunity.Id, false), 9);
        Test.stopTest();

        testBillingInstructionSteps = [
                select Id, Status__c
                from FC_Billing_Instruction_Step__c
                where Billing_Instruction_Set__r.Opportunity__c = :testOpportunity.Id
        ];

        for (FC_Billing_Instruction_Step__c testBillingInstructionStep : testBillingInstructionSteps) {
            System.assertEquals('Executed', testBillingInstructionStep.Status__c);
        }

    }

    @isTest
    private static void testBatchableError() {

        Opportunity testOpportunity = [
                select Id
                from Opportunity
                where Name = 'Test Existing Subscription Opportunity'
                limit 1
        ];

        FC_Billing_Instruction_Step__c[] testBillingInstructionSteps = [
                select Id, Status__c
                from FC_Billing_Instruction_Step__c
                where Billing_Instruction_Set__r.Opportunity__c = :testOpportunity.Id
        ];

        for (FC_Billing_Instruction_Step__c testBillingInstructionStep : testBillingInstructionSteps) {
            System.assertEquals('Pending', testBillingInstructionStep.Status__c);
        }

        FC_ZuoraCalloutMock mock = new FC_ZuoraCalloutMock();
        mock.testUpdateSubscriptionError = true;
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        try {
            Id asyncJobId = Database.executeBatch(new FC_ZuoraAmendmentProcessorBatchable(testOpportunity.Id, false), 9);
            Test.stopTest();
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }

        testBillingInstructionSteps = [
                select Id, Status__c
                from FC_Billing_Instruction_Step__c
                where Billing_Instruction_Set__r.Opportunity__c = :testOpportunity.Id
        ];

        for (FC_Billing_Instruction_Step__c testBillingInstructionStep : testBillingInstructionSteps) {
            System.assertEquals('Pending', testBillingInstructionStep.Status__c);
        }

    }


    @testSetup
    private static void setup() {

        Map<String, FC_Billing_Instruction_Template__c> testBillingInstructionTemplateMap =
                new Map<String, FC_Billing_Instruction_Template__c>{
                        'Standard' => new FC_Billing_Instruction_Template__c(Name = 'Standard', Custom_Javascript_Visualforce_Page__c = 'Standard'),
                        'Ramp Up' => new FC_Billing_Instruction_Template__c(Name = 'Ramp Up', Custom_Javascript_Visualforce_Page__c = 'Ramp Up'),
                        'Step Up' => new FC_Billing_Instruction_Template__c(Name = 'Step Up', Custom_Javascript_Visualforce_Page__c = 'Step Up'),
                        'Opt Out' => new FC_Billing_Instruction_Template__c(Name = 'Opt Out', Custom_Javascript_Visualforce_Page__c = 'Opt Out'),
                        'Free Months' => new FC_Billing_Instruction_Template__c(Name = 'Free Months', Custom_Javascript_Visualforce_Page__c = 'Free Months')
                };
        insert testBillingInstructionTemplateMap.values();

        FC_Billing_Instruction_Settings__c testBillingInstructionSettings =
                new FC_Billing_Instruction_Settings__c(SetupOwnerId = UserInfo.getOrganizationId(),
                        Check_Payment_Method_Zuora_ID__c = '1234567890',
                        Default_Billing_Instruction_Template_ID__c = testBillingInstructionTemplateMap.get('Standard').Id);
        insert testBillingInstructionSettings;

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

        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '10069', Override_Billing_Address_Information__c = true);
        insert testAccount;

        Contact[] testContacts = new Contact[]{
                new Contact(AccountId = testAccount.Id, FirstName = 'Test First', LastName = 'Test Last',
                        MailingStreet = 'Test Addresss1\nTest Address2', MailingCity = 'Test City', MailingStateCode = 'NY',
                        MailingPostalCode = '12345', MailingCountryCode = 'US', Override_Mailing_Address_Information__c = true),
                new Contact(AccountId = testAccount.Id, LastName = 'Test Last', Override_Mailing_Address_Information__c = true)
        };
        insert testContacts;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today(),
                Zuora__TermSettingType__c = 'TERMED');
        insert testSubscription;

        Zuora__SubscriptionProductCharge__c[] testSubscriptionProductCharges =
                new Zuora__SubscriptionProductCharge__c[]{
                        new Zuora__SubscriptionProductCharge__c(Name = 'C-1', Seg3_Record__c = testProductGeographySeg3.Id,
                                Zuora__Subscription__c = testSubscription.Id, Zuora__Type__c = 'Recurring',
                                Zuora__SubscriptionChargeNumber__c = 'C-1', Zuora__Zuora_Id__c = 'C-1'),
                        new Zuora__SubscriptionProductCharge__c(Name = 'C-2', Seg3_Record__c = testProductGeographySeg3.Id,
                                Zuora__Subscription__c = testSubscription.Id, Zuora__Type__c = 'Recurring',
                                Zuora__SubscriptionChargeNumber__c = 'C-2', Zuora__Zuora_Id__c = 'C-2'),
                        new Zuora__SubscriptionProductCharge__c(Name = 'C-3', Seg3_Record__c = testProductGeographySeg3.Id,
                                Zuora__Subscription__c = testSubscription.Id, Zuora__Type__c = 'Recurring',
                                Zuora__SubscriptionChargeNumber__c = 'C-3', Zuora__Zuora_Id__c = 'C-3')
                };
        insert testSubscriptionProductCharges;

        Contract testContract = new Contract(AccountId = testAccount.Id, FC_Subscription_Number__c = 'S-1',
                FC_Subscription__c = testSubscription.Id, FC_Price_Book__c = Test.getStandardPricebookId());
        insert testContract;

        Opportunity[] testOpportunities = new List<Opportunity>{
                new Opportunity(Name = 'Test Renew Opportunity',
                        AccountId = testAccount.Id, Amount = 100, ContractId = testContract.Id,
                        StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30,
                        FC_Renew__c = true, FC_Contract_Effective_Date__c = Date.today(), FC_Term_Type__c = 'TERMED'),
                new Opportunity(Name = 'Test New Subscription New Account Opportunity',
                        AccountId = testAccount.Id, Amount = 100,
                        StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30,
                        FC_Bill_To_Contact__c = testContacts[0].Id, FC_Sold_To_Contact__c = testContacts[0].Id, FC_Contract_Effective_Date__c = Date.today(),
                        FC_Batch__c = 'Batch1', FC_Currency__c = 'USD', FC_Payment_Term__c = 'Due Upon Receipt', FC_T_C_Term_Start_Date__c = Date.today() + 15,
                        FC_Term_Type__c = 'TERMED'),
                new Opportunity(Name = 'Test Existing Subscription Opportunity',
                        AccountId = testAccount.Id, Amount = 100, ContractId = testContract.Id,
                        StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30,
                        FC_Bill_To_Contact__c = testContacts[0].Id, FC_Sold_To_Contact__c = testContacts[0].Id, FC_Contract_Effective_Date__c = Date.today(),
                        FC_Term_Type__c = 'TERMED'),
                new Opportunity(Name = 'Test Invalid Opportunity', AccountId = testAccount.Id, Amount = 100, FC_Bill_To_Contact__c = testContacts[1].Id,
                        FC_Sold_To_Contact__c = testContacts[1].Id, StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30)
        };
        insert testOpportunities;

        String[] uuids = new List<String>();
        for (Integer i = 0; i < 6; i++) {
            uuids.add(FC_UuidUtil.uuidV4());
        }
        OpportunityLineItem[] testOpportunityLineItems = new OpportunityLineItem[]{
                new OpportunityLineItem(OpportunityId = testOpportunities[1].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[0],
                        FC_Zuora_Action__c = 'Add'),
                new OpportunityLineItem(OpportunityId = testOpportunities[2].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[1],
                        FC_Zuora_Action__c = 'Add'),
                new OpportunityLineItem(OpportunityId = testOpportunities[2].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[2],
                        FC_Zuora_Action__c = 'Add'),
                new OpportunityLineItem(OpportunityId = testOpportunities[2].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[3],
                        FC_Zuora_Action__c = 'Add'),
                new OpportunityLineItem(OpportunityId = testOpportunities[2].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[4],
                        FC_Zuora_Action__c = 'Add'),
                new OpportunityLineItem(OpportunityId = testOpportunities[3].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[5],
                        FC_Zuora_Action__c = 'Add')
        };
        insert testOpportunityLineItems;

        FC_Billing_Instruction_Set__c[] testBillingInstructionSets =
                new FC_Billing_Instruction_Set__c[]{
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunities[1].Id,
                                Opportunity_Line_Item_UUID__c = uuids[0], Template__c = testBillingInstructionTemplateMap.get('Standard').Id),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunities[2].Id,
                                Opportunity_Line_Item_UUID__c = uuids[1], Template__c = testBillingInstructionTemplateMap.get('Standard').Id),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunities[2].Id,
                                Opportunity_Line_Item_UUID__c = uuids[2], Template__c = testBillingInstructionTemplateMap.get('Standard').Id),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunities[2].Id,
                                Opportunity_Line_Item_UUID__c = uuids[3], Template__c = testBillingInstructionTemplateMap.get('Standard').Id),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunities[2].Id,
                                Opportunity_Line_Item_UUID__c = uuids[4], Template__c = testBillingInstructionTemplateMap.get('Standard').Id),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunities[3].Id,
                                Opportunity_Line_Item_UUID__c = uuids[5], Template__c = testBillingInstructionTemplateMap.get('Standard').Id)
                };
        insert testBillingInstructionSets;

        testOpportunityLineItems[0].FC_Billing_Instruction_Set__c = testBillingInstructionSets[0].Id;
        testOpportunityLineItems[1].FC_Billing_Instruction_Set__c = testBillingInstructionSets[1].Id;
        testOpportunityLineItems[2].FC_Billing_Instruction_Set__c = testBillingInstructionSets[2].Id;
        testOpportunityLineItems[3].FC_Billing_Instruction_Set__c = testBillingInstructionSets[3].Id;
        testOpportunityLineItems[4].FC_Billing_Instruction_Set__c = testBillingInstructionSets[4].Id;
        testOpportunityLineItems[5].FC_Billing_Instruction_Set__c = testBillingInstructionSets[5].Id;
        update testOpportunityLineItems;

        FC_Billing_Instruction_Step__c[] testBillingInstructionSteps =
                new FC_Billing_Instruction_Step__c[]{
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[0].Id,
                                Contract_Effective_Date__c = Date.today() + 30, Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'New',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Subscribe').Id),
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[1].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'Pending',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Add').Id),
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[2].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'Pending',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Modify').Id),
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[3].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'Pending',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Remove').Id),
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[4].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'Pending',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Add').Id),
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[5].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'New',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Subscribe').Id)
                };
        insert testBillingInstructionSteps;

    }

}