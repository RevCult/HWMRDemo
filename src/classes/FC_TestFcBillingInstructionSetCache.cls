@isTest
private class FC_TestFcBillingInstructionSetCache {

    @isTest
    private static void testClearCache() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        FC_Billing_Instruction_Set__c testBillingInstructionSet = [
                select Id
                from FC_Billing_Instruction_Set__c
                where Opportunity__c = :testOpportunity.Id
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, FC_Billing_Instruction_Set__c> results = FC_FcBillingInstructionSetCache.findByIds(new Set<Id>{
                testBillingInstructionSet.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_FcBillingInstructionSetCache.findByIds(new Set<Id>{
                testBillingInstructionSet.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        FC_FcBillingInstructionSetCache.clearCache();
        results = FC_FcBillingInstructionSetCache.findByIds(new Set<Id>{
                testBillingInstructionSet.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(2, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByIds() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        FC_Billing_Instruction_Set__c testBillingInstructionSet = [
                select Id
                from FC_Billing_Instruction_Set__c
                where Opportunity__c = :testOpportunity.Id
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, FC_Billing_Instruction_Set__c> results = FC_FcBillingInstructionSetCache.findByIds(new Set<Id>{
                testBillingInstructionSet.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        results = FC_FcBillingInstructionSetCache.findByIds(new Set<Id>{
                testBillingInstructionSet.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

    }

    @isTest
    private static void testFindByOpportunityLineItemId() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        OpportunityLineItem testOpportunityLineItem = [
                select Id
                from OpportunityLineItem
                where OpportunityId = :testOpportunity.Id
                limit 1
        ];

        FC_Billing_Instruction_Set__c testBillingInstructionSet = [
                select Id
                from FC_Billing_Instruction_Set__c
                where Opportunity__c = :testOpportunity.Id
                limit 1
        ];

        Test.startTest();
        System.assertEquals(0, Limits.getQueries());
        Map<Id, FC_Billing_Instruction_Set__c> results = FC_FcBillingInstructionSetCache.findByOpportunityLineItemIds(new Set<Id>{
                testOpportunityLineItem.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        System.assertEquals(testBillingInstructionSet.Id, results.get(testOpportunityLineItem.Id).Id);
        results = FC_FcBillingInstructionSetCache.findByOpportunityLineItemIds(new Set<Id>{
                testOpportunityLineItem.Id
        });
        System.assertEquals(1, results.size());
        System.assertEquals(1, Limits.getQueries());
        System.assertEquals(testBillingInstructionSet.Id, results.get(testOpportunityLineItem.Id).Id);
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

        Zuora__Subscription__c testSubscription = new Zuora__Subscription__c(Name = 'S-1',
                Zuora__Account__c = testAccount.Id, Zuora__CustomerAccount__c = testCustomerAccount.Id,
                Zuora__TermEndDate__c = Date.today() + 365, Zuora__TermStartDate__c = Date.today());
        insert testSubscription;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',
                AccountId = testAccount.Id, Amount = 100,
                StageName = 'New Opportunity', CloseDate = Date.today());
        insert testOpportunity;

        OpportunityLineItem[] testOpportunityLineItems = new OpportunityLineItem[]{
                new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPricebookEntry.Id,
                        Quantity = 1, UnitPrice = 100)
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