@isTest
private class FC_TestOpportunityHandler {

    @isTest
    private static void testInsert() {

        Account testAccount = [select Id from Account where Name = 'Test Account' limit 1];

        Contract testContract = [select Id from Contract where AccountId = :testAccount.Id limit 1];

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_OpportunityHandler'
        });

        Test.startTest();

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',
                AccountId = testAccount.Id, Amount = 100,
                StageName = 'New Opportunity', CloseDate = Date.today(),
                RecordTypeId = fcf.RecordTypeUtil.findByName('Opportunity.Metrostudy_Opportunity_Record_Type_Consult').Id,
                FC_Term_Type__c = 'TERMED', FC_Contract_Effective_Date__c = Date.today(), FC_Initial_Term__c = 12,
                ContractId = testContract.Id, FC_Renew__c = true);
        insert testOpportunity;

        Test.stopTest();

        testOpportunity = [
                select Id, FC_Consulting_Balance__c, FC_Contract_Effective_Date__c, FC_Service_Activation_Date__c,
                        FC_Target_Date__c, FC_Term_Start_Date__c, FC_Term_End_Date__c
                from Opportunity
                where Id = :testOpportunity.Id
                limit 1
        ];

        System.assertEquals(Date.today(), testOpportunity.FC_Contract_Effective_Date__c);
        System.assertEquals(Date.today(), testOpportunity.FC_Service_Activation_Date__c);
        System.assertEquals(Date.today(), testOpportunity.FC_Target_Date__c);
        System.assertEquals(Date.today() + 365, testOpportunity.FC_Term_Start_Date__c);
        System.assertEquals((Date.today() + 365).addMonths(24), testOpportunity.FC_Term_End_Date__c);
        System.assertEquals(0, testOpportunity.FC_Consulting_Balance__c);

    }

    @IsTest
    private static void testUpdate() {

        PricebookEntry testPricebookEntry = [
                select Id
                from PricebookEntry
                where Product2.Name = 'Test Product' and Pricebook2Id = :Test.getStandardPricebookId()
                limit 1
        ];

        Opportunity testOpportunity = [
                select Id, FC_Contract_Effective_Date__c, FC_Service_Activation_Date__c,
                        FC_Target_Date__c, FC_Term_Start_Date__c, FC_Term_End_Date__c, FC_Initial_Term__c
                from Opportunity
                where Name = 'Test Opportunity'
                limit 1
        ];

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_OpportunityHandler'
        });


        Test.startTest();

        testOpportunity.FC_Term_Type__c = 'EVERGREEN';
        testOpportunity.StageName = 'Closed Won';
        testOpportunity.Skip_Validation__c = true;
        update testOpportunity;

        testOpportunity = [
                select Id, FC_Contract_Effective_Date__c, FC_Service_Activation_Date__c,
                        FC_Target_Date__c, FC_Term_Start_Date__c, FC_Term_End_Date__c, FC_Initial_Term__c
                from Opportunity
                where Id = :testOpportunity.Id
                limit 1
        ];

        System.assertEquals(testOpportunity.FC_Contract_Effective_Date__c.addMonths(12),
                testOpportunity.FC_Term_End_Date__c);

        // Test recursion mitigation
        Integer currentDmlCount = Limits.getDmlStatements();
        testOpportunity.Skip_Validation__c = true;
        update testOpportunity;
        System.assertEquals(currentDmlCount + 1, Limits.getDmlStatements());

        insert new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPricebookEntry.Id,
                Quantity = 1, UnitPrice = 100, FC_Effective_Date__c = Date.today(),
                Billing_Frequency__c = 'One-Time');

        fcf.TriggerRunStatus.unblockAll();

        testOpportunity.FC_Term_Type__c = 'TERMED';
        testOpportunity.StageName = 'Closed Won';
        testOpportunity.Skip_Validation__c = true;
        update testOpportunity;

        testOpportunity = [
                select Id, FC_Contract_Effective_Date__c, FC_Service_Activation_Date__c,
                        FC_Target_Date__c, FC_Term_Start_Date__c, FC_Term_End_Date__c, FC_Initial_Term__c
                from Opportunity
                where Id = :testOpportunity.Id
                limit 1
        ];

        System.assertEquals(testOpportunity.FC_Contract_Effective_Date__c
                .addMonths(Integer.valueOf(testOpportunity.FC_Initial_Term__c)), testOpportunity.FC_Term_End_Date__c);

        Test.stopTest();

        testOpportunity = [
                select Id, FC_Consulting_Balance__c, FC_Contract_Effective_Date__c, FC_Service_Activation_Date__c,
                        FC_Target_Date__c, FC_Term_Start_Date__c, FC_Term_End_Date__c, FC_Initial_Term__c
                from Opportunity
                where Id = :testOpportunity.Id
                limit 1
        ];

        System.assertEquals(Date.today(), testOpportunity.FC_Contract_Effective_Date__c);
        System.assertEquals(Date.today(), testOpportunity.FC_Service_Activation_Date__c);
        System.assertEquals(Date.today(), testOpportunity.FC_Target_Date__c);
        System.assertEquals(Date.today(), testOpportunity.FC_Term_Start_Date__c);
        System.assertEquals(150, testOpportunity.FC_Consulting_Balance__c);

    }

    @testSetup
    private static void setup() {

        FC_Validation_Settings__c testValidationSettings = new FC_Validation_Settings__c(SetupOwnerId = UserInfo.getOrganizationId(), Skip_All_Validations__c = true);
        upsert testValidationSettings;

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

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'Test Account',
                Zuora__Account__c = testAccount.Id, Zuora__External_Id__c = 'A-1');
        insert testCustomerAccount;

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today(),
                Zuora__InitialTerm__c = '12 months', Zuora__RenewalTerm__c = '24 months');
        insert testSubscription;

        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge =
                new Zuora__SubscriptionProductCharge__c(Name = 'C-1',
                        Seg3_Record__c = testProductGeographySeg3.Id,
                        Zuora__Subscription__c = testSubscription.Id, Zuora__Type__c = 'One-Time',
                        Zuora__SubscriptionChargeNumber__c = 'C-1', Zuora__EffectiveStartDate__c = Date.today());
        insert testSubscriptionProductCharge;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',
                AccountId = testAccount.Id, Amount = 100,
                StageName = 'New Opportunity', CloseDate = Date.today(),
                RecordTypeId = fcf.RecordTypeUtil.findByName('Opportunity.Metrostudy_Opportunity_Record_Type_Consult').Id,
                FC_Term_Type__c = 'TERMED', FC_Contract_Effective_Date__c = Date.today(), FC_Initial_Term__c = 12,
                One_Time_Sale_Type__c = 'Consulting/Engagement', Scheduled_Delivery_Date__c = Date.today());
        insert testOpportunity;

        Contract testContract = new Contract(AccountId = testAccount.Id, FC_Subscription_Number__c = 'S-1',
                FC_Subscription__c = testSubscription.Id, FC_Price_Book__c = Test.getStandardPricebookId());
        insert testContract;

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

        fziiss__Invoice_Item__c testInvoiceItem = new fziiss__Invoice_Item__c(Name = 'Test Invoice Item',
                fziiss__ChargeAmount__c = 50,
                fziiss__Rate_Plan_Charge__c = testSubscriptionProductCharge.Id,
                fziiss__Subscription__c = testSubscription.Id,
                Opportunity__c = testOpportunity.Id);
        insert testInvoiceItem;

    }

}