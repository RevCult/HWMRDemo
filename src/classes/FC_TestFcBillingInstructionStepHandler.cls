@isTest
private class FC_TestFcBillingInstructionStepHandler {

    @isTest
    public static void testInsert() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        FC_Metroclient_Product_Geography_Seg3__c testProductGeographySeg3 = [
                select Id
                from FC_Metroclient_Product_Geography_Seg3__c
                where Accounting_Code__c = 'AC-1'
                limit 1
        ];

        FC_Billing_Instruction_Set__c[] testBillingInstructionSets = [
                select Id, Template__r.Name
                from FC_Billing_Instruction_Set__c
                where Opportunity__c = :testOpportunity.Id
        ];

        Map<String, FC_Billing_Instruction_Set__c> templateNameToBillingInstructionSetMap =
                new Map<String, FC_Billing_Instruction_Set__c>();
        for (FC_Billing_Instruction_Set__c testBillingInstructionSet : testBillingInstructionSets) {
            templateNameToBillingInstructionSetMap.put(testBillingInstructionSet.Template__r.Name,
                    testBillingInstructionSet);
        }
        System.debug('****** TEMPLATE NAME TO BI SET MAP: ' + templateNameToBillingInstructionSetMap);
        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_FcBillingInstructionStepHandler'
        });

        Test.startTest();

        FC_Billing_Instruction_Step__c[] testBillingInstructionSteps = new FC_Billing_Instruction_Step__c[]{
                new FC_Billing_Instruction_Step__c(
                        Billing_Instruction_Set__c = templateNameToBillingInstructionSetMap.get('Ramp Up').Id,
                        Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                        Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Up_To_Periods__c = 1,
                        Metadata_Number_of_Periods__c = 1),
                new FC_Billing_Instruction_Step__c(
                        Billing_Instruction_Set__c = templateNameToBillingInstructionSetMap.get('Step Up').Id,
                        Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                        Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Up_To_Periods__c = 1,
                        Metadata_Is_Last__c = true, Metadata_Number_of_Periods__c = 1),
                new FC_Billing_Instruction_Step__c(
                        Billing_Instruction_Set__c = templateNameToBillingInstructionSetMap.get('Standard').Id,
                        Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                        Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Up_To_Periods__c = 1,
                        Metadata_Number_of_Periods__c = 1)
        };
        insert testBillingInstructionSteps;

        Test.stopTest();

        testBillingInstructionSteps = [
                select Id, End_Date__c, Billing_Instruction_Set__c,
                        Billing_Instruction_Set__r.Opportunity__r.FC_Term_End_Date__c,
                        Billing_Instruction_Set__r.Template__r.Name
                from FC_Billing_Instruction_Step__c
                where Id in :testBillingInstructionSteps
        ];

        Map<String, FC_Billing_Instruction_Step__c> templateNameToBillingInstructionStepMap =
                new Map<String, FC_Billing_Instruction_Step__c>();
        for (FC_Billing_Instruction_Step__c testBillingInstructionStep : testBillingInstructionSteps) {
            templateNameToBillingInstructionStepMap.put(
                    testBillingInstructionStep.Billing_Instruction_Set__r.Template__r.Name,
                    testBillingInstructionStep);
        }

        System.debug('****** TEMPLATE NAME TO BI STEP MAP: ' + templateNameToBillingInstructionStepMap);

        System.assertEquals(Date.today().addMonths(1) - 1, templateNameToBillingInstructionStepMap.get('Ramp Up').End_Date__c);
        System.assertEquals(templateNameToBillingInstructionStepMap.get('Step Up').Billing_Instruction_Set__r.Opportunity__r.FC_Term_End_Date__c,
                templateNameToBillingInstructionStepMap.get('Step Up').End_Date__c);
        System.assertEquals(Date.today().addMonths(1) - 1, templateNameToBillingInstructionStepMap.get('Standard').End_Date__c);

    }

    @isTest
    public static void testUpdate() {

        Opportunity testOpportunity = [
                select Id, FC_Notify_Accounting_Generate_Invoice__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        System.assertNotEquals(true, testOpportunity.FC_Notify_Accounting_Generate_Invoice__c);

        testOpportunity.Proof_of_Delivery_attached__c = true;
        testOpportunity.Scheduled_Delivery_Date__c = Date.today();
        update testOpportunity;

        FC_Billing_Instruction_Set__c testBillingInstructionSet = [
                select Id, Template__r.Name
                from FC_Billing_Instruction_Set__c
                where Opportunity__c = :testOpportunity.Id
                limit 1
        ];

        FC_Billing_Instruction_Step__c testBillingInstructionStep = [
                select Id, End_Date__c, Billing_Instruction_Set__r.Opportunity__r.FC_Term_End_Date__c,
                        Billing_Instruction_Set__r.Template__r.Name, Execute_Immediately__c
                from FC_Billing_Instruction_Step__c
                where Billing_Instruction_Set__c = :testBillingInstructionSet.Id
        ];

        System.assertNotEquals(true, testBillingInstructionStep.Execute_Immediately__c);

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_FcBillingInstructionStepHandler'
        });

        Test.startTest();

        testBillingInstructionStep.Price__c = 100;

        update testBillingInstructionStep;

        testBillingInstructionStep = [
                select Id, End_Date__c, Billing_Instruction_Set__r.Opportunity__r.FC_Term_End_Date__c,
                        Billing_Instruction_Set__r.Template__r.Name, Execute_Immediately__c
                from FC_Billing_Instruction_Step__c
                where Billing_Instruction_Set__c = :testBillingInstructionSet.Id
        ];

        System.assertEquals(true, testBillingInstructionStep.Execute_Immediately__c);

        fcf.TriggerRunStatus.unblockAll();

        testBillingInstructionStep.Status__c = 'Executed';
        testBillingInstructionStep.Price__c = 100;

        update testBillingInstructionStep;

        Test.stopTest();

//        testOpportunity = [
//                select Id, FC_Notify_Accounting_Generate_Invoice__c
//                from Opportunity
//                where Id = :testOpportunity.Id
//                limit 1
//        ];
//
//        System.assertEquals(true, testOpportunity.FC_Notify_Accounting_Generate_Invoice__c);

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

        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '12345');
        insert testAccount;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today());
        insert testSubscription;

        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge =
                new Zuora__SubscriptionProductCharge__c(Name = 'C-1', Seg3_Record__c = testProductGeographySeg3.Id,
                        Zuora__Subscription__c = testSubscription.Id, Zuora__Type__c = 'Recurring',
                        Zuora__SubscriptionChargeNumber__c = 'C-1');
        insert testSubscriptionProductCharge;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',
                AccountId = testAccount.Id, Amount = 100,
                StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30);
        insert testOpportunity;

        String[] uuids = new List<String>();
        for (Integer i = 0; i < 5; i++) {
            uuids.add(FC_UuidUtil.uuidV4());
        }
        OpportunityLineItem[] testOpportunityLineItems = new OpportunityLineItem[]{
                new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[0]),
                new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[1]),
                new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[2]),
                new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[3]),
                new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[4])
        };
        insert testOpportunityLineItems;

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
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunity.Id,
                                Opportunity_Line_Item_UUID__c = uuids[0], Template__c = testBillingInstructionTemplateMap.get('Standard').Id),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunity.Id,
                                Opportunity_Line_Item_UUID__c = uuids[1], Template__c = testBillingInstructionTemplateMap.get('Ramp Up').Id),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunity.Id,
                                Opportunity_Line_Item_UUID__c = uuids[2], Template__c = testBillingInstructionTemplateMap.get('Step Up').Id),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunity.Id,
                                Opportunity_Line_Item_UUID__c = uuids[3], Template__c = testBillingInstructionTemplateMap.get('Opt Out').Id),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunity.Id,
                                Opportunity_Line_Item_UUID__c = uuids[4], Template__c = testBillingInstructionTemplateMap.get('Free Months').Id)
                };
        insert testBillingInstructionSets;

        testOpportunityLineItems[0].FC_Billing_Instruction_Set__c = testBillingInstructionSets[0].Id;
        testOpportunityLineItems[1].FC_Billing_Instruction_Set__c = testBillingInstructionSets[1].Id;
        testOpportunityLineItems[2].FC_Billing_Instruction_Set__c = testBillingInstructionSets[2].Id;
        testOpportunityLineItems[3].FC_Billing_Instruction_Set__c = testBillingInstructionSets[3].Id;
        testOpportunityLineItems[4].FC_Billing_Instruction_Set__c = testBillingInstructionSets[4].Id;
        update testOpportunityLineItems;

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