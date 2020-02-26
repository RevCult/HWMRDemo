@isTest
private class FC_TestOpportunityBillingAccountFormCtrl {

    @isTest
    private static void testCreateNewBillingAccount() {

        Opportunity testOpportunity = [select Id, AccountId, FC_Last_Sent_To_Zuora__c from Opportunity where Name = 'Test Opportunity' limit 1];

        Test.startTest();

        PageReference testPage = Page.FC_OpportunityBillingAccountForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityBillingAccountFormCtrl controller = new FC_OpportunityBillingAccountFormCtrl(standardController);

        controller.selectedBillingAccountAction = 'CREATE_NEW';
        controller.refreshUi();

        System.assertEquals(2, controller.billingAccountContactOptions.size());

        testOpportunity.FC_Bill_To_Contact__c = controller.billingAccountContactOptions[1].getValue();
        PageReference testResultPage = controller.saveOpportunity();

        System.assertEquals(standardController.view().getUrl(), testResultPage.getUrl());

        testOpportunity = [select Id, AccountId, FC_Last_Sent_To_Zuora__c, FC_Bill_To_Contact__c from Opportunity where Name = 'Test Opportunity' limit 1];
        System.assertEquals(Id.valueOf(controller.billingAccountContactOptions[1].getValue()), testOpportunity.FC_Bill_To_Contact__c);

        Test.stopTest();
    }

    @isTest
    private static void testUseExistingBillingAccount() {

        Opportunity testOpportunity = [select Id, AccountId, FC_Last_Sent_To_Zuora__c from Opportunity where Name = 'Test Opportunity' limit 1];

        Test.startTest();

        PageReference testPage = Page.FC_OpportunityBillingAccountForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityBillingAccountFormCtrl controller = new FC_OpportunityBillingAccountFormCtrl(standardController);

        controller.selectedBillingAccountAction = 'USE_EXISTING';
        controller.refreshUi();

        System.assertEquals(1, controller.billingAccounts.size());

        controller.selectedBillingAccountId = controller.billingAccounts[0].Id;
        PageReference testResultPage = controller.saveOpportunity();

        System.assertEquals(standardController.view().getUrl(), testResultPage.getUrl());

        testOpportunity = [select Id, AccountId, FC_Last_Sent_To_Zuora__c, FC_Billing_Account__c from Opportunity where Name = 'Test Opportunity' limit 1];
        System.assertEquals(Id.valueOf(controller.billingAccounts[0].Id), testOpportunity.FC_Billing_Account__c);

        Test.stopTest();
    }

    @isTest
    private static void testUseExistingBillingAccountRequired() {

        Opportunity testOpportunity = [select Id, AccountId, FC_Last_Sent_To_Zuora__c from Opportunity where Name = 'Test Opportunity' limit 1];

        Test.startTest();

        PageReference testPage = Page.FC_OpportunityBillingAccountForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityBillingAccountFormCtrl controller = new FC_OpportunityBillingAccountFormCtrl(standardController);

        controller.selectedBillingAccountAction = 'USE_EXISTING';
        controller.refreshUi();

        System.assertEquals(1, controller.billingAccounts.size());

        controller.selectedBillingAccountId = null;
        PageReference testResultPage = controller.saveOpportunity();

        System.assertEquals(null, testResultPage);

        Test.stopTest();

    }

    @isTest
    private static void testCannotUpdateSentOpportunity() {

        Opportunity testOpportunity = [select Id, AccountId, FC_Last_Sent_To_Zuora__c from Opportunity where Name = 'Test Opportunity' limit 1];
        testOpportunity.FC_Last_Sent_To_Zuora__c = Date.today();
        update testOpportunity;

        Test.startTest();

        PageReference testPage = Page.FC_OpportunityBillingAccountForm;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunityBillingAccountFormCtrl controller = new FC_OpportunityBillingAccountFormCtrl(standardController);

        controller.selectedBillingAccountAction = 'USE_EXISTING';
        controller.refreshUi();

        System.assertEquals(1, controller.billingAccounts.size());

        controller.selectedBillingAccountId = controller.billingAccounts[0].Id;
        PageReference testResultPage = controller.saveOpportunity();

        System.assertEquals(null, testResultPage);

        Test.stopTest();

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
                        Seg3__c = 'INFO');
        insert testProductGeographySeg3;

        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '12345');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Test First Name', LastName = 'Test Last name',
                AccountId = testAccount.Id);
        insert testContact;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today());
        insert testSubscription;

        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge =
                new Zuora__SubscriptionProductCharge__c(Name = 'C-1', Seg3_Record__c = testProductGeographySeg3.Id,
                        Zuora__Subscription__c = testSubscription.Id, Zuora__Type__c = 'Recurring');
        insert testSubscriptionProductCharge;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',
                AccountId = testAccount.Id, Amount = 100,
                StageName = 'New Opportunity', CloseDate = Date.today());
        insert testOpportunity;

        OpportunityContactRole testOpportunityContactRole = new OpportunityContactRole(
                OpportunityId = testOpportunity.Id, ContactId = testContact.Id, Role = 'Bill To');
        insert testOpportunityContactRole;

        OpportunityLineItem[] testOpportunityLineItems = new OpportunityLineItem[]{
                new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100)
        };
        insert testOpportunityLineItems;

        Contract testContract = new Contract(AccountId = testAccount.Id, FC_Subscription_Number__c = 'S-1',
                FC_Subscription__c = testSubscription.Id, FC_Price_Book__c = Test.getStandardPricebookId());
        insert testContract;
    }

}