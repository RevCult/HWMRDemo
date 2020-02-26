@isTest
private class FC_TestOpportunityProductsFormController {

    @isTest
    private static void testControllerNewSubscription() {

        Opportunity testOpportunity = [
                select Id
                from Opportunity
                where Name = 'Test New Subscription New Account Opportunity'
                limit 1
        ];

        Map<String, FC_Billing_Instruction_Template__c> testBillingInstructionTemplateMap = new Map<String, FC_Billing_Instruction_Template__c>();
        for (FC_Billing_Instruction_Template__c testBillingInstructionTemplate : [select Id, Name from FC_Billing_Instruction_Template__c]) {
            testBillingInstructionTemplateMap.put(testBillingInstructionTemplate.Name, testBillingInstructionTemplate);

        }

        OpportunityLineItem[] testOpportunityLineItems = [
                select Id, Billing_Frequency__c, FC_Bill_Case__c,
                        FC_Billing_Instruction_Set__c, FC_Effective_Date__c, FC_Geography__c, FC_Geography_Type__c,
                        FC_Metrostudy_Product__c, FC_Original_Sale_Price__c, FC_Product_Geography_Seg3__c,
                        FC_Sale_Price__c, FC_Seg3__c, FC_UUID__c, FC_Zuora_Action__c, MS_Segment__c, OpportunityId,
                        PricebookEntryId, Product2Id, UnitPrice
                from OpportunityLineItem
                where OpportunityId = :testOpportunity.Id
        ];

        System.assertEquals(((OpportunityLineItem[]) JSON.deserialize(FC_OpportunityProductsFormController.getOpportunityLineItemsJson(testOpportunity.Id),
                OpportunityLineItem[].class)).size(), testOpportunityLineItems.size());

        OpportunityLineItem[] testOpportunityLineItemsToSave = new List<OpportunityLineItem>();
        for (OpportunityLineItem testOpportunityLineItem : testOpportunityLineItems) {
            OpportunityLineItem testOpportunityLineItemToSave = testOpportunityLineItem.clone(false, false, false, false);
            testOpportunityLineItemToSave.FC_UUID__c = FC_UuidUtil.uuidV4();
            testOpportunityLineItemsToSave.add(testOpportunityLineItemToSave);
        }

        FC_Billing_Instruction_Set__c[] testBillingInstructionSets = [
                select Id, Charge__c, Charge_Effective_Start_Date__c, Charge_Number__c, Instruction_Parameters__c,
                        Opportunity__c, Opportunity_Line_Item_ID__c, Opportunity_Line_Item_UUID__c,
                        Subscription_Start_Date__c, Template__c
                from FC_Billing_Instruction_Set__c
                where Opportunity__c = :testOpportunity.Id
        ];

        FC_Billing_Instruction_Step__c[] testBillingInstructionSteps = [
                select Id, Bill_Cycle_Day__c, Bill_Cycle_Type__c, Billing_Instruction_Description__c,
                        Billing_Instruction_Set__c, Billing_Period__c, Billing_Period_Alignment__c,
                        Contract_Effective_Date__c, Description__c, End_Date__c, End_Date_Condition__c,
                        Execute_Immediately__c, Metadata_Is_Last__c, Metadata_Number_of_Periods__c,
                        Metrostudy_Product_Geography_Seg3__c, Price__c, Product_Rate_Plan__c, Quantity__c,
                        RecordTypeId, Specific_Billing_Period__c, Specific_End_Date__c, Status__c,
                        T_C_Term_Start_Date__c, Trigger_Date__c, Trigger_Event__c, Up_To_Periods__c,
                        Up_To_Periods_Type__c, Weekly_Bill_Cycle_Day__c
                from FC_Billing_Instruction_Step__c
                where Billing_Instruction_Set__c in :testBillingInstructionSets
        ];

        PageReference testPage = Page.FC_OpportunityProductsForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        Test.startTest();

        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityProductsFormController controller = new FC_OpportunityProductsFormController(standardController);

        System.assertEquals(testBillingInstructionTemplateMap.get('Standard').Id, controller.defaultBillingInstructionTemplateId);
        System.assertEquals(5, controller.billingInstructionTemplates.size());
        System.assertEquals(1, controller.pricebook2Options.size());

        FC_OpportunityProductsFormController.RemoteQueryParameters testQueryParameters = new FC_OpportunityProductsFormController.RemoteQueryParameters();
        testQueryParameters.filter = new Map<String, String>{
                'Name' => 'Test'
        };
        System.assertEquals(1, FC_OpportunityProductsFormController.queryProductRatePlans(testQueryParameters).total_count);

        FC_OpportunityProductsFormController.RemoteSaveResult[] testSaveOpportunityLineItemResults =
                FC_OpportunityProductsFormController.saveOpportunityLineItems(testOpportunityLineItemsToSave,
                        new List<List<String>>{
                                new List<String>{
                                        'FC_Bill_Case__c'
                                }
                        },
                        new String[]{
                                testOpportunityLineItems[0].Id
                        }, testBillingInstructionSets,
                        testBillingInstructionSteps,
                        new List<List<String>>{
                                new List<String>{
                                        'Bill_Cycle_Day__c'
                                }
                        },
                        new OpportunityLineItem[]{
                        }, testOpportunity.Id);

        System.debug('***** SAVE RESULTS: ' + testSaveOpportunityLineItemResults);
        for (Integer i = 0; i < testSaveOpportunityLineItemResults.size(); i++) {
            System.assertEquals('insert', testSaveOpportunityLineItemResults[i].status);
        }
        Test.stopTest();

    }

    @isTest
    private static void testControllerExistingSubscription() {

        Opportunity testOpportunity = [
                select Id
                from Opportunity
                where Name = 'Test Existing Subscription Opportunity'
                limit 1
        ];

        Map<String, FC_Billing_Instruction_Template__c> testBillingInstructionTemplateMap = new Map<String, FC_Billing_Instruction_Template__c>();
        for (FC_Billing_Instruction_Template__c testBillingInstructionTemplate : [select Id, Name from FC_Billing_Instruction_Template__c]) {
            testBillingInstructionTemplateMap.put(testBillingInstructionTemplate.Name, testBillingInstructionTemplate);

        }

        OpportunityLineItem[] testOpportunityLineItems = [
                select Id, Billing_Frequency__c, FC_Bill_Case__c,
                        FC_Billing_Instruction_Set__c, FC_Effective_Date__c, FC_Geography__c, FC_Geography_Type__c,
                        FC_Metrostudy_Product__c, FC_Original_Sale_Price__c, FC_Product_Geography_Seg3__c,
                        FC_Sale_Price__c, FC_Seg3__c, FC_UUID__c, FC_Zuora_Action__c, MS_Segment__c, OpportunityId,
                        PricebookEntryId, Product2Id, UnitPrice
                from OpportunityLineItem
                where OpportunityId = :testOpportunity.Id
        ];

        OpportunityLineItem[] testOpportunityLineItemsToSave = new List<OpportunityLineItem>();
        for (OpportunityLineItem testOpportunityLineItem : testOpportunityLineItems) {
            OpportunityLineItem testOpportunityLineItemToSave = testOpportunityLineItem.clone(false, false, false, false);
            testOpportunityLineItemToSave.FC_UUID__c = FC_UuidUtil.uuidV4();
            testOpportunityLineItemsToSave.add(testOpportunityLineItemToSave);
        }

        FC_Billing_Instruction_Set__c[] testBillingInstructionSets = [
                select Id, Charge__c, Charge_Effective_Start_Date__c, Charge_Number__c, Instruction_Parameters__c,
                        Opportunity__c, Opportunity_Line_Item_ID__c, Opportunity_Line_Item_UUID__c,
                        Subscription_Start_Date__c, Template__c
                from FC_Billing_Instruction_Set__c
                where Opportunity__c = :testOpportunity.Id
        ];

        FC_Billing_Instruction_Step__c[] testBillingInstructionSteps = [
                select Id, Bill_Cycle_Day__c, Bill_Cycle_Type__c, Billing_Instruction_Description__c,
                        Billing_Instruction_Set__c, Billing_Period__c, Billing_Period_Alignment__c,
                        Contract_Effective_Date__c, Description__c, End_Date__c, End_Date_Condition__c,
                        Execute_Immediately__c, Metadata_Is_Last__c, Metadata_Number_of_Periods__c,
                        Metrostudy_Product_Geography_Seg3__c, Price__c, Product_Rate_Plan__c, Quantity__c,
                        RecordTypeId, Specific_Billing_Period__c, Specific_End_Date__c, Status__c,
                        T_C_Term_Start_Date__c, Trigger_Date__c, Trigger_Event__c, Up_To_Periods__c,
                        Up_To_Periods_Type__c, Weekly_Bill_Cycle_Day__c
                from FC_Billing_Instruction_Step__c
                where Billing_Instruction_Set__c in :testBillingInstructionSets
        ];

        PageReference testPage = Page.FC_OpportunityProductsForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        Test.startTest();

        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityProductsFormController controller = new FC_OpportunityProductsFormController(standardController);

        System.assertEquals(testBillingInstructionTemplateMap.get('Standard').Id, controller.defaultBillingInstructionTemplateId);
        System.assertEquals(5, controller.billingInstructionTemplates.size());
        System.assertEquals(1, controller.pricebook2Options.size());

        FC_OpportunityProductsFormController.RemoteQueryParameters testQueryParameters = new FC_OpportunityProductsFormController.RemoteQueryParameters();
        testQueryParameters.filter = new Map<String, String>{
                'Name' => 'Test',
                'Product_Rate_Plan_Name__c' => 'Test',
                'Seg3__c' => 'CONS'
        };
        System.assertEquals(1, FC_OpportunityProductsFormController.queryProductRatePlans(testQueryParameters).total_count);
        System.assertEquals(1, FC_OpportunityProductsFormController.queryFcMetroclientProductGeographySeg3(testQueryParameters,
                false, Test.getStandardPricebookId()).total_count);

        FC_Metroclient_Product_Geography_Seg3__c testProductGeographySeg3 = [
                select Id
                from FC_Metroclient_Product_Geography_Seg3__c
                where Accounting_Code__c = 'AC-1'
                limit 1
        ];

        FC_OpportunityProductsFormController.RemoteOption[] testRemoteOptions =
                FC_OpportunityProductsFormController.getFcMetroclientProductGeographySeg3sByIdsAndOpportunityId(new Id[]{
                        testProductGeographySeg3.Id
                }, testOpportunity.Id);
        System.assertEquals(1, testRemoteOptions.size());

        FC_OpportunityProductsFormController.RemoteSaveResult[] testSaveOpportunityLineItemResults =
                FC_OpportunityProductsFormController.saveOpportunityLineItems(testOpportunityLineItemsToSave,
                        new List<List<String>>{
                                new List<String>{
                                        'FC_Bill_Case__c'
                                }, new List<String>{
                                        'FC_Bill_Case__c'
                                }, new List<String>{
                                        'FC_Bill_Case__c'
                                }, new List<String>{
                                }
                        },
                        new String[]{
                                testOpportunityLineItems[0].Id,
                                testOpportunityLineItems[1].Id,
                                testOpportunityLineItems[2].Id,
                                testOpportunityLineItems[3].Id
                        }, testBillingInstructionSets,
                        testBillingInstructionSteps,
                        new List<List<String>>{
                                new List<String>{
                                        'Bill_Cycle_Day__c'
                                },
                                new List<String>{
                                        'Bill_Cycle_Day__c'
                                },
                                new List<String>{
                                        'Bill_Cycle_Day__c'
                                }
                        },
                        new OpportunityLineItem[]{
                                testOpportunityLineItems[testOpportunityLineItems.size() - 1]
                        }, testOpportunity.Id);

        System.debug('***** SAVE RESULTS: ' + testSaveOpportunityLineItemResults);
        for (Integer i = 0; i < testSaveOpportunityLineItemResults.size(); i++) {
            if (i > 0) {
                System.assertEquals('insert', testSaveOpportunityLineItemResults[i].status);
            } else {
                System.assertEquals('delete', testSaveOpportunityLineItemResults[i].status);
            }
        }
        Test.stopTest();

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

        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '12345');
        insert testAccount;

        Contact testContact = new Contact(AccountId = testAccount.Id, FirstName = 'Test First', LastName = 'Test Last',
                MailingStreet = 'Test Addresss1\nTest Address2', MailingCity = 'Test City', MailingStateCode = 'NY',
                MailingPostalCode = '12345', MailingCountryCode = 'US');
        insert testContact;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today());
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
                        FC_Renew__c = true, FC_Contract_Effective_Date__c = Date.today(), Pricebook2Id = Test.getStandardPricebookId()),
                new Opportunity(Name = 'Test New Subscription New Account Opportunity',
                        AccountId = testAccount.Id, Amount = 100,
                        StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30,
                        FC_Bill_To_Contact__c = testContact.Id, FC_Sold_To_Contact__c = testContact.Id, FC_Contract_Effective_Date__c = Date.today()),
                new Opportunity(Name = 'Test Existing Subscription Opportunity',
                        AccountId = testAccount.Id, Amount = 100, ContractId = testContract.Id,
                        StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30,
                        FC_Bill_To_Contact__c = testContact.Id, FC_Sold_To_Contact__c = testContact.Id, FC_Contract_Effective_Date__c = Date.today())
        };
        insert testOpportunities;

        String[] uuids = new List<String>();
        for (Integer i = 0; i < 5; i++) {
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
                                Opportunity_Line_Item_UUID__c = uuids[4], Template__c = testBillingInstructionTemplateMap.get('Standard').Id)
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
                                Contract_Effective_Date__c = Date.today() + 30, Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'New',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Subscribe').Id),
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[1].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'New',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Subscribe').Id),
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[2].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'New',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Modify').Id),
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[3].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'New',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Remove').Id)
                };
        insert testBillingInstructionSteps;

    }

}