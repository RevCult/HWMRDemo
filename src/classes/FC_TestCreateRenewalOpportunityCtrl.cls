@isTest
private class FC_TestCreateRenewalOpportunityCtrl {

    @isTest
    private static void testCreateRenewalOpportunitySuccess() {

        Opportunity testOriginalOpportunity = [
                select Id, Contract.FC_Next_Charge_Date__c, Contract.FC_Subscription_Start_Date__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        PageReference testPage = Page.FC_CreateRenewalOpportunity;
        testPage.getParameters().put('id', testOriginalOpportunity.Id);
        Test.setCurrentPage(testPage);
        Test.startTest();

        FC_CreateRenewalOpportunityController controller = new FC_CreateRenewalOpportunityController(new ApexPages.StandardController(testOriginalOpportunity));
        controller.createRenewalOpportunity();

        Test.stopTest();

        System.assertEquals(ApexPages.Severity.CONFIRM, ApexPages.getMessages()[0].getSeverity());

    }

    @isTest
    private static void testCreateRenewalOpportunityError() {

        Opportunity testOriginalOpportunity = [
                select Id, Contract.FC_Next_Charge_Date__c, Contract.FC_Subscription_Start_Date__c, Contract.FC_Subscription__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        update new Zuora__Subscription__c(Id = testOriginalOpportunity.Contract.FC_Subscription__c, Zuora__NextChargeDate__c = null);

        testOriginalOpportunity = [
                select Id, Contract.FC_Next_Charge_Date__c, Contract.FC_Subscription_Start_Date__c, Contract.FC_Subscription__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        PageReference testPage = Page.FC_CreateRenewalOpportunity;
        testPage.getParameters().put('id', testOriginalOpportunity.Id);
        Test.setCurrentPage(testPage);
        Test.startTest();

        FC_CreateRenewalOpportunityController controller = new FC_CreateRenewalOpportunityController(new ApexPages.StandardController(testOriginalOpportunity));
        controller.createRenewalOpportunity();

        Test.stopTest();

        System.assertEquals(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity());

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

        Contact testContact = new Contact(FirstName = 'Test First', LastName = 'Test Last', Email = 'test@example.com',
                AccountId = testAccount.Id);
        insert testContact;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__NextChargeDate__c = Date.today() + 365,
                Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today(),
                Zuora__InitialTerm__c = '12 months', Zuora__RenewalTerm__c = '24 months');
        insert testSubscription;

        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = new Zuora__SubscriptionProductCharge__c(Name = 'C-1',
                Zuora__External_Id__c = 'C-1', Zuora__Subscription__c = testSubscription.Id,
                Zuora__SubscriptionChargeNumber__c = 'C-1', Zuora__Price__c = 100, Zuora__Type__c = 'Recurring',
                Zuora__BillingPeriod__c = 'Annual', Seg3_Record__c = testProductGeographySeg3.Id);
        insert testSubscriptionProductCharge;

        Contract testContract = new Contract(AccountId = testAccount.Id, FC_Subscription_Number__c = 'S-1',
                FC_Subscription__c = testSubscription.Id, FC_Price_Book__c = Test.getStandardPricebookId());
        insert testContract;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',
                AccountId = testAccount.Id, Amount = 100, ContractId = testContract.Id,
                StageName = 'New Opportunity', CloseDate = Date.today(),
                RecordTypeId = fcf.RecordTypeUtil.findByName('Opportunity.Network_Opportunity').Id,
                FC_Term_Type__c = 'TERMED', FC_Contract_Effective_Date__c = Date.today(), FC_Initial_Term__c = 12,
                Scheduled_Delivery_Date__c = Date.today(), Channel_Type__c = 'Direct', Purchase_Type__c = 'One-time',
                One_time_Sale_Type__c = 'Custom Export/Report', MS_Products__c = 'Custom Export/Report', OwnerId = testSalesUser.Id);
        insert testOpportunity;

        OpportunityContactRole testOpportunityContactRole = new OpportunityContactRole(OpportunityId = testOpportunity.Id, ContactId = testContact.Id,
                IsPrimary = true, Role = 'Bill To');
        insert testOpportunityContactRole;

        OpportunityLineItem[] testOpportunityLineItems = new OpportunityLineItem[]{
                new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100, FC_Effective_Date__c = Date.today(),
                        Billing_Frequency__c = 'One-Time')
        };
        insert testOpportunityLineItems;

        FC_Billing_Instruction_Set__c testBillingInstructionSet =
                new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunity.Id,
                        Opportunity_Line_Item_ID__c = testOpportunityLineItems[0].Id);
        insert testBillingInstructionSet;

        testOpportunityLineItems[0].FC_Billing_Instruction_Set__c = testBillingInstructionSet.Id;
        update testOpportunityLineItems;

        FC_Billing_Instruction_Step__c testBillingInstructionStep =
                new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSet.Id);
        insert testBillingInstructionStep;

    }

}