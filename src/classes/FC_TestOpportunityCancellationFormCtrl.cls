@isTest
private class FC_TestOpportunityCancellationFormCtrl {

    @isTest
    private static void testCancelSubscription() {
        Opportunity testOpportunity = [
                select Id, Name, Account.Name, ContractId, Contract.FC_Subscription__c,
                        Contract.FC_Subscription__r.Name, Contract.FC_Subscription__r.Zuora__Status__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        PageReference testPage = Page.FC_OpportunityCancellationForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityCancellationFormController controller = new FC_OpportunityCancellationFormController(standardController);

        controller.preValidate();

        System.assertEquals(true, controller.preValid);
        System.assertEquals(false, controller.success);

        controller.selectedCancellationAction = 'SUBSCRIPTION';
        controller.effectiveDateString = '2017-11-15';

        controller.processCancellation();

        System.assertEquals(true, controller.success);
        Test.stopTest();

    }

    @isTest
    private static void testCancelProduct() {
        Opportunity testOpportunity = [
                select Id, Name, Account.Name, ContractId, Contract.FC_Subscription__c,
                        Contract.FC_Subscription__r.Name, Contract.FC_Subscription__r.Zuora__Status__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        PageReference testPage = Page.FC_OpportunityCancellationForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityCancellationFormController controller = new FC_OpportunityCancellationFormController(standardController);

        controller.preValidate();

        System.assertEquals(true, controller.preValid);
        System.assertEquals(false, controller.success);

        System.assertEquals(3, controller.ratePlans.size());

        controller.selectedCancellationAction = 'PRODUCTS';
        controller.effectiveDateString = '2017-11-15';
        controller.ratePlans[0].selected = true;

        controller.processCancellation();

        System.assertEquals(true, controller.success);
        Test.stopTest();

    }

    @isTest
    private static void testCancelSubscriptionErrorCancellation() {
        Opportunity testOpportunity = [
                select Id, Name, Account.Name, ContractId, Contract.FC_Subscription__c,
                        Contract.FC_Subscription__r.Name, Contract.FC_Subscription__r.Zuora__Status__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock(true));
        PageReference testPage = Page.FC_OpportunityCancellationForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityCancellationFormController controller = new FC_OpportunityCancellationFormController(standardController);

        controller.preValidate();

        System.assertEquals(true, controller.preValid);
        System.assertEquals(false, controller.success);

        controller.selectedCancellationAction = 'SUBSCRIPTION';
        controller.effectiveDateString = '2017-11-15';

        controller.processCancellation();

        System.assertEquals(false, controller.success);
        Test.stopTest();

    }

    @isTest
    private static void testCancelProductNoProductSelected() {
        Opportunity testOpportunity = [
                select Id, Name, Account.Name, ContractId, Contract.FC_Subscription__c,
                        Contract.FC_Subscription__r.Name, Contract.FC_Subscription__r.Zuora__Status__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        PageReference testPage = Page.FC_OpportunityCancellationForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityCancellationFormController controller = new FC_OpportunityCancellationFormController(standardController);

        controller.preValidate();

        System.assertEquals(true, controller.preValid);
        System.assertEquals(false, controller.success);

        System.assertEquals(3, controller.ratePlans.size());

        controller.selectedCancellationAction = 'PRODUCTS';
        controller.effectiveDateString = '2017-11-15';

        controller.processCancellation();

        System.assertEquals(false, controller.success);
        Test.stopTest();

    }

    @isTest
    private static void testCancelSubscriptionErrorUpdate() {
        Opportunity testOpportunity = [
                select Id, Name, Account.Name, ContractId, Contract.FC_Subscription__c,
                        Contract.FC_Subscription__r.Name, Contract.FC_Subscription__r.Zuora__Status__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        Test.startTest();
        FC_ZuoraCalloutMock testMock = new FC_ZuoraCalloutMock();
        testMock.testUpdateSubscriptionError = true;
        Test.setMock(HttpCalloutMock.class, testMock);
        PageReference testPage = Page.FC_OpportunityCancellationForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityCancellationFormController controller = new FC_OpportunityCancellationFormController(standardController);

        controller.preValidate();

        System.assertEquals(true, controller.preValid);
        System.assertEquals(false, controller.success);

        controller.selectedCancellationAction = 'SUBSCRIPTION';
        controller.effectiveDateString = '2017-11-15';

        controller.processCancellation();

        System.assertEquals(true, controller.success);
        Test.stopTest();

    }

    @isTest
    private static void testCancelProductError() {
        Opportunity testOpportunity = [
                select Id, Name, Account.Name, ContractId, Contract.FC_Subscription__c,
                        Contract.FC_Subscription__r.Name, Contract.FC_Subscription__r.Zuora__Status__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock(true));
        PageReference testPage = Page.FC_OpportunityCancellationForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityCancellationFormController controller = new FC_OpportunityCancellationFormController(standardController);

        controller.preValidate();

        System.assertEquals(true, controller.preValid);
        System.assertEquals(false, controller.success);

        System.assertEquals(3, controller.ratePlans.size());

        controller.selectedCancellationAction = 'PRODUCTS';
        controller.effectiveDateString = '2017-11-15';
        controller.ratePlans[0].selected = true;

        controller.processCancellation();

        System.assertEquals(false, controller.success);
        Test.stopTest();

    }

    @isTest
    private static void testInvalidEffectiveDate() {
        Opportunity testOpportunity = [
                select Id, Name, Account.Name, ContractId, Contract.FC_Subscription__c,
                        Contract.FC_Subscription__r.Name, Contract.FC_Subscription__r.Zuora__Status__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        PageReference testPage = Page.FC_OpportunityContractForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityCancellationFormController controller = new FC_OpportunityCancellationFormController(standardController);

        controller.preValidate();

        System.assertEquals(true, controller.preValid);
        System.assertEquals(false, controller.success);

        controller.selectedCancellationAction = 'SUBSCRIPTION';
        controller.effectiveDateString = 'BAD';

        controller.processCancellation();

        System.assertEquals(false, controller.success);
        Test.stopTest();

    }

    @isTest
    private static void testMissingEffectiveDate() {
        Opportunity testOpportunity = [
                select Id, Name, Account.Name, ContractId, Contract.FC_Subscription__c,
                        Contract.FC_Subscription__r.Name, Contract.FC_Subscription__r.Zuora__Status__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        PageReference testPage = Page.FC_OpportunityCancellationForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityCancellationFormController controller = new FC_OpportunityCancellationFormController(standardController);

        controller.preValidate();

        System.assertEquals(true, controller.preValid);
        System.assertEquals(false, controller.success);

        controller.selectedCancellationAction = 'SUBSCRIPTION';
        controller.effectiveDateString = null;

        controller.processCancellation();

        System.assertEquals(false, controller.success);
        Test.stopTest();

    }

    @isTest
    private static void testMissingCancellationAction() {
        Opportunity testOpportunity = [
                select Id, Name, Account.Name, ContractId, Contract.FC_Subscription__c,
                        Contract.FC_Subscription__r.Name, Contract.FC_Subscription__r.Zuora__Status__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        PageReference testPage = Page.FC_OpportunityCancellationForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityCancellationFormController controller = new FC_OpportunityCancellationFormController(standardController);

        controller.preValidate();

        System.assertEquals(true, controller.preValid);
        System.assertEquals(false, controller.success);

        controller.selectedCancellationAction = null;
        controller.effectiveDateString = '2017-11-15';

        controller.processCancellation();

        System.assertEquals(false, controller.success);
        Test.stopTest();

    }

    @isTest
    private static void testPreValidateFail() {
        Opportunity testOpportunity = [select Id, Name, Account.Name, ContractId from Opportunity where Name = 'Test Opportunity' limit 1];
        testOpportunity.ContractId = null;
        update testOpportunity;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        PageReference testPage = Page.FC_OpportunityCancellationForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityCancellationFormController controller = new FC_OpportunityCancellationFormController(standardController);

        controller.preValidate();

        System.assertEquals(false, controller.preValid);
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
                Zuora__Status__c = 'Active', Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today());
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