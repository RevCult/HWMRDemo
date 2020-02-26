@isTest
private class FC_TestZuoraSubscriptionTCAmendFormCtrl {

    @isTest
    private static void testSuccess() {

        Zuora__Subscription__c testSubscription = [
                select Id, Zuora__Account__c, Zuora__AutoRenew__c, Zuora__CurrentTermPeriodType__c, Zuora__InitialTerm__c,
                        Zuora__RenewalTerm__c, Zuora__RenewalTermPeriodType__c,
                        Zuora__SubscriptionNumber__c, Zuora__TermEndDate__c, Zuora__TermSettingType__c,
                        Zuora__TermStartDate__c
                from Zuora__Subscription__c
                where Zuora__SubscriptionNumber__c = 'S-1'
                limit 1
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        PageReference testPage = Page.FC_ZuoraSubscriptionTCAmendmentForm;
        testPage.getParameters().put('id', testSubscription.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testSubscription);
        FC_ZuoraSubscriptionTCAmendmentFormCtrl controller = new FC_ZuoraSubscriptionTCAmendmentFormCtrl(standardController);

        controller.termStartDate = Date.today() + 1;

        controller.currentTerm = 1;
        controller.currentTermPeriodType = 'Day';
        System.assertEquals((Date.today() + 2).format(), controller.displayNewTermEndDate);

        controller.currentTermPeriodType = 'Year';
        System.assertEquals((Date.today().addYears(1) + 1).format(), controller.displayNewTermEndDate);

        controller.currentTermPeriodType = 'Week';
        System.assertEquals((Date.today().addDays(7) + 1).format(), controller.displayNewTermEndDate);

        controller.currentTermPeriodType = 'Month';
        System.assertEquals((Date.today().addMonths(1) + 1).format(), controller.displayNewTermEndDate);

        controller.processAmendment();

        System.assertEquals(true, controller.success);

        Test.stopTest();

    }

    @isTest
    private static void testError() {

        Zuora__Subscription__c testSubscription = [
                select Id, Zuora__Account__c, Zuora__AutoRenew__c, Zuora__CurrentTermPeriodType__c, Zuora__InitialTerm__c,
                        Zuora__RenewalTerm__c, Zuora__RenewalTermPeriodType__c,
                        Zuora__SubscriptionNumber__c, Zuora__TermEndDate__c, Zuora__TermSettingType__c,
                        Zuora__TermStartDate__c
                from Zuora__Subscription__c
                where Zuora__SubscriptionNumber__c = 'S-1'
                limit 1
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock(true));
        PageReference testPage = Page.FC_ZuoraSubscriptionTCAmendmentForm;
        testPage.getParameters().put('id', testSubscription.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testSubscription);
        FC_ZuoraSubscriptionTCAmendmentFormCtrl controller = new FC_ZuoraSubscriptionTCAmendmentFormCtrl(standardController);

        System.assertEquals(testSubscription.Zuora__TermStartDate__c.format(), controller.displaySubscriptionTermStartDate);
        System.assertEquals(testSubscription.Zuora__TermEndDate__c.format(), controller.displaySubscriptionTermEndDate);

        controller.termStartDate = Date.today() + 1;

        controller.currentTerm = 1;
        controller.currentTermPeriodType = 'Day';
        System.assertEquals((Date.today() + 2).format(), controller.displayNewTermEndDate);

        controller.currentTermPeriodType = 'Year';
        System.assertEquals((Date.today().addYears(1) + 1).format(), controller.displayNewTermEndDate);

        controller.currentTermPeriodType = 'Week';
        System.assertEquals((Date.today().addDays(7) + 1).format(), controller.displayNewTermEndDate);

        controller.currentTermPeriodType = 'Month';
        System.assertEquals((Date.today().addMonths(1) + 1).format(), controller.displayNewTermEndDate);

        controller.processAmendment();

        System.assertEquals(false, controller.success);

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

        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        PricebookEntry testPricebookEntry = new PricebookEntry(IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(), Product2Id = testProduct.Id, UnitPrice = 100);
        insert testPricebookEntry;

        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '12345');
        insert testAccount;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__Status__c = 'Active', Zuora__TermSettingType__c = 'TERMED',
                Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today(),
                Zuora__SubscriptionNumber__c = 'S-1', Zuora__InitialTerm__c = '12 months', Zuora__RenewalTerm__c = '12 months');
        insert testSubscription;

        Zuora__SubscriptionRatePlan__c[] testRatePlans = new Zuora__SubscriptionRatePlan__c[]{
                new Zuora__SubscriptionRatePlan__c(Name = 'RP-1', Zuora__External_Id__c = 'RP-1', Zuora__Subscription__c = testSubscription.Id),
                new Zuora__SubscriptionRatePlan__c(Name = 'RP-2', Zuora__External_Id__c = 'RP-2', Zuora__Subscription__c = testSubscription.Id),
                new Zuora__SubscriptionRatePlan__c(Name = 'RP-3', Zuora__External_Id__c = 'RP-3', Zuora__Subscription__c = testSubscription.Id)
        };
        insert testRatePlans;

        Zuora__SubscriptionProductCharge__c[] testSubscriptionProductCharges = new Zuora__SubscriptionProductCharge__c[]{
                new Zuora__SubscriptionProductCharge__c(Name = 'C-1', Zuora__SubscriptionRatePlan__c = testRatePlans[0].Id,
                        Zuora__Subscription__c = testSubscription.Id, Zuora__Type__c = 'Recurring', Zuora__SubscriptionChargeNumber__c = 'C-1'),
                new Zuora__SubscriptionProductCharge__c(Name = 'C-2', Zuora__SubscriptionRatePlan__c = testRatePlans[1].Id,
                        Zuora__Subscription__c = testSubscription.Id, Zuora__Type__c = 'Recurring', Zuora__SubscriptionChargeNumber__c = 'C-2'),
                new Zuora__SubscriptionProductCharge__c(Name = 'C-3', Zuora__SubscriptionRatePlan__c = testRatePlans[2].Id,
                        Zuora__Subscription__c = testSubscription.Id, Zuora__Type__c = 'Recurring', Zuora__SubscriptionChargeNumber__c = 'C-3')
        };
        insert testSubscriptionProductCharges;

        Contract testContract = new Contract(AccountId = testAccount.Id, FC_Subscription_Number__c = 'S-1', FC_Subscription__c = testSubscription.Id);
        insert testContract;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',
                AccountId = testAccount.Id, Amount = 100,
                StageName = 'New Opportunity', CloseDate = Date.today(), ContractId = testContract.Id);
        insert testOpportunity;

        String[] uuids = new List<String>();
        for (Integer i = 0; i < 3; i++) {
            uuids.add(FC_UuidUtil.uuidV4());
        }
        OpportunityLineItem[] testOpportunityLineItems = new OpportunityLineItem[]{
                new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[0],
                        FC_Zuora_Action__c = 'No Action'),
                new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[1],
                        FC_Zuora_Action__c = 'No Action'),
                new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[2],
                        FC_Zuora_Action__c = 'No Action')
        };
        insert testOpportunityLineItems;

        FC_Billing_Instruction_Set__c[] testBillingInstructionSets =
                new FC_Billing_Instruction_Set__c[]{
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunity.Id, Charge_Number__c = 'C-1',
                                Opportunity_Line_Item_UUID__c = uuids[0], Template__c = testBillingInstructionTemplateMap.get('Standard').Id),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunity.Id, Charge_Number__c = 'C-2',
                                Opportunity_Line_Item_UUID__c = uuids[1], Template__c = testBillingInstructionTemplateMap.get('Standard').Id),
                        new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunity.Id, Charge_Number__c = 'C-3',
                                Opportunity_Line_Item_UUID__c = uuids[2], Template__c = testBillingInstructionTemplateMap.get('Standard').Id)
                };
        insert testBillingInstructionSets;

        testOpportunityLineItems[0].FC_Billing_Instruction_Set__c = testBillingInstructionSets[0].Id;
        testOpportunityLineItems[1].FC_Billing_Instruction_Set__c = testBillingInstructionSets[1].Id;
        testOpportunityLineItems[2].FC_Billing_Instruction_Set__c = testBillingInstructionSets[2].Id;
        update testOpportunityLineItems;

    }

}