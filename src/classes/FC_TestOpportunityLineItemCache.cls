@isTest
private class FC_TestOpportunityLineItemCache {

    @isTest
    private static void testClearCache() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        OpportunityLineItem testOpportunityLineItem = [
                select Id
                from OpportunityLineItem
                where OpportunityId = :testOpportunity.Id
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, OpportunityLineItem> results = FC_OpportunityLineItemCache.findByIds(new Set<Id>{
                testOpportunityLineItem.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_OpportunityLineItemCache.findByIds(new Set<Id>{
                testOpportunityLineItem.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        FC_OpportunityLineItemCache.clearCache();
        results = FC_OpportunityLineItemCache.findByIds(new Set<Id>{
                testOpportunityLineItem.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(2, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByIds() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        OpportunityLineItem testOpportunityLineItem = [
                select Id
                from OpportunityLineItem
                where OpportunityId = :testOpportunity.Id
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, OpportunityLineItem> results = FC_OpportunityLineItemCache.findByIds(new Set<Id>{
                testOpportunityLineItem.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_OpportunityLineItemCache.findByIds(new Set<Id>{
                testOpportunityLineItem.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByUuids() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        OpportunityLineItem testOpportunityLineItem = [
                select Id, FC_UUID__c
                from OpportunityLineItem
                where OpportunityId = :testOpportunity.Id
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<String, OpportunityLineItem> results = FC_OpportunityLineItemCache.findByUuids(new Set<String>{
                testOpportunityLineItem.FC_UUID__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_OpportunityLineItemCache.findByUuids(new Set<String>{
                testOpportunityLineItem.FC_UUID__c
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindBillingInstructionSetIds() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        FC_Billing_Instruction_Set__c testBillingInstructionSet = [
                select Id
                from FC_Billing_Instruction_Set__c
                where Opportunity__c = :testOpportunity.Id
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, OpportunityLineItem> results = FC_OpportunityLineItemCache.findByBillingInstructionSetIds(new Set<Id>{
                testBillingInstructionSet.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_OpportunityLineItemCache.findByBillingInstructionSetIds(new Set<Id>{
                testBillingInstructionSet.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByOpportunityIds() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, Set<OpportunityLineItem>> results = FC_OpportunityLineItemCache.findByOpportunityIds(new Set<Id>{
                testOpportunity.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_OpportunityLineItemCache.findByOpportunityIds(new Set<Id>{
                testOpportunity.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @testSetup
    private static void setup() {

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

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',
                AccountId = testAccount.Id, Amount = 100,
                StageName = 'New Opportunity', CloseDate = Date.today());
        insert testOpportunity;

        OpportunityLineItem[] testOpportunityLineItems = new OpportunityLineItem[]{
                new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100, FC_UUID__c = FC_UuidUtil.uuidV4())
        };
        insert testOpportunityLineItems;

        FC_Billing_Instruction_Set__c testBillingInstructionSet =
                new FC_Billing_Instruction_Set__c(Opportunity__c = testOpportunity.Id,
                        Opportunity_Line_Item_ID__c = testOpportunityLineItems[0].Id);
        insert testBillingInstructionSet;

        testOpportunityLineItems[0].FC_Billing_Instruction_Set__c = testBillingInstructionSet.Id;
        update testOpportunityLineItems;

    }

}