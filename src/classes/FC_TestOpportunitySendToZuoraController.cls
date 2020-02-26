@isTest
private class FC_TestOpportunitySendToZuoraController {

    @isTest
    private static void testSendToZuoraValidation() {

        Opportunity testOpportunity = [
                select Id, AccountId, Account.Name, CloseDate, ContractId,
                        Contract.FC_Subscription__c, Contract.FC_Subscription__r.Name,
                        Contract.FC_Subscription__r.Zuora__TermSettingType__c,
                        Contract.FC_Subscription_Number__c, FC_Auto_Renew__c, FC_Batch__c, FC_Bill_Cycle_Day__c,
                        FC_Bill_To_Contact__c, FC_Bill_To_Contact__r.Billing_Email_Address__c, FC_Bill_To_Contact__r.Email,
                        FC_Bill_To_Contact__r.Fax, FC_Bill_To_Contact__r.FirstName, FC_Bill_To_Contact__r.LastName,
                        FC_Bill_To_Contact__r.MailingCity, FC_Bill_To_Contact__r.MailingCountryCode,
                        FC_Bill_To_Contact__r.MailingPostalCode, FC_Bill_To_Contact__r.MailingState,
                        FC_Bill_To_Contact__r.MailingStateCode, FC_Bill_To_Contact__r.MailingStreet,
                        FC_Bill_To_Contact__r.Phone, FC_Billing_Account__c, FC_Billing_Account__r.Zuora__External_Id__c,
                        FC_Currency__c, FC_Contract_Effective_Date__c, FC_Initial_Term__c, FC_Invoice_Separately__c,
                        FC_Payment_Term__c, FC_Renew__c, FC_Renewal_Processed_On__c, FC_Renewal_Term__c,
                        FC_Service_Activation_Date__c, FC_Sold_To_Contact__c, FC_Sold_To_Contact__r.Email,
                        FC_Sold_To_Contact__r.Fax, FC_Sold_To_Contact__r.FirstName, FC_Sold_To_Contact__r.LastName,
                        FC_Sold_To_Contact__r.MailingCity, FC_Sold_To_Contact__r.MailingCountryCode,
                        FC_Sold_To_Contact__r.MailingPostalCode, FC_Sold_To_Contact__r.MailingState,
                        FC_Sold_To_Contact__r.MailingStateCode, FC_Sold_To_Contact__r.MailingStreet,
                        FC_Sold_To_Contact__r.Phone, FC_Subscription_Notes__c, FC_T_C_Term_Start_Date__c,
                        FC_Target_Date__c, FC_Term_Type__c, Metrostudy_Lead__c, Name, One_time_Sale_Type__c, Owner.Name,
                        Pricebook2Id, Purchase_Type__c, Region__c
                from Opportunity
                where Name = 'Test Invalid Opportunity'
                limit 1
        ];

        PageReference testPage = Page.FC_OpportunitySendToZuora;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());

        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunitySendToZuoraController controller = new FC_OpportunitySendToZuoraController(standardController);

        System.assertEquals(false, controller.hasAmendBillingInstructionSteps);
        System.assertEquals(false, controller.shouldRenew);
        controller.sendToZuora();

        testOpportunity = [select Id, StageName from Opportunity where Id = :testOpportunity.Id limit 1];

        System.assertNotEquals('Closed Won', testOpportunity.StageName);

        testOpportunity.FC_Bill_Cycle_Day__c = null;
        testOpportunity.FC_Bill_To_Contact__c = null;
        update testOpportunity;

        controller.sendToZuora();

        testOpportunity = [select Id, StageName from Opportunity where Id = :testOpportunity.Id limit 1];

        System.assertNotEquals('Closed Won', testOpportunity.StageName);

        Test.stopTest();

    }

    @isTest
    private static void testSendToZuoraNewSubscription() {

        Opportunity testOpportunity = [
                select Id, AccountId, Account.Name, CloseDate, ContractId,
                        Contract.FC_Subscription__c, Contract.FC_Subscription__r.Name,
                        Contract.FC_Subscription__r.Zuora__TermSettingType__c,
                        Contract.FC_Subscription_Number__c, FC_Auto_Renew__c, FC_Batch__c, FC_Bill_Case__c, FC_Bill_Cycle_Day__c,
                        FC_Bill_To_Contact__c, FC_Bill_To_Contact__r.Billing_Email_Address__c, FC_Bill_To_Contact__r.Email,
                        FC_Bill_To_Contact__r.Fax, FC_Bill_To_Contact__r.FirstName, FC_Bill_To_Contact__r.LastName,
                        FC_Bill_To_Contact__r.MailingCity, FC_Bill_To_Contact__r.MailingCountryCode,
                        FC_Bill_To_Contact__r.MailingPostalCode, FC_Bill_To_Contact__r.MailingState,
                        FC_Bill_To_Contact__r.MailingStateCode, FC_Bill_To_Contact__r.MailingStreet,
                        FC_Bill_To_Contact__r.Phone, FC_Billing_Account__c, FC_Billing_Account__r.Zuora__External_Id__c,
                        FC_Currency__c, FC_Contract_Effective_Date__c, FC_Initial_Term__c, FC_Invoice_Separately__c,
                        FC_Payment_Term__c, FC_Renew__c, FC_Renewal_Processed_On__c, FC_Renewal_Term__c,
                        FC_Service_Activation_Date__c, FC_Sold_To_Contact__c, FC_Sold_To_Contact__r.Email,
                        FC_Sold_To_Contact__r.Fax, FC_Sold_To_Contact__r.FirstName, FC_Sold_To_Contact__r.LastName,
                        FC_Sold_To_Contact__r.MailingCity, FC_Sold_To_Contact__r.MailingCountryCode,
                        FC_Sold_To_Contact__r.MailingPostalCode, FC_Sold_To_Contact__r.MailingState,
                        FC_Sold_To_Contact__r.MailingStateCode, FC_Sold_To_Contact__r.MailingStreet,
                        FC_Sold_To_Contact__r.Phone, FC_Subscription_Notes__c, FC_T_C_Term_Start_Date__c,
                        FC_Target_Date__c, FC_Term_Type__c, Metrostudy_Lead__c, Name, One_time_Sale_Type__c, Owner.Name,
                        Pricebook2Id, Purchase_Type__c, Region__c
                from Opportunity
                where Name = 'Test New Subscription New Account Opportunity'
                limit 1
        ];

        FC_Billing_Instruction_Set__c testBillingInstructionSet = [
                select Id
                from FC_Billing_Instruction_Set__c
                where Opportunity__c = :testOpportunity.Id
                limit 1
        ];

        PageReference testPage = Page.FC_OpportunitySendToZuora;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        FC_ZuoraCalloutMock mock = new FC_ZuoraCalloutMock();
        mock.testBillingInstructionSetId = testBillingInstructionSet.Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.stopTest(); // Remove when we don't need the hack to ignore the pending batch class

        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunitySendToZuoraController controller = new FC_OpportunitySendToZuoraController(standardController);

        System.assertEquals(false, controller.hasAmendBillingInstructionSteps);
        System.assertEquals(false, controller.shouldRenew);
        controller.sendToZuora();

        // Test.stopTest(); Hack to get tests running for now
        // FC_MetroclientAccountProvisionBatchable is being kicked off by FC_OpportunitySendToZuoraController:329
        // The async action is not correctly being issolated from the existing transactions
        // The batch class will likely need to be tested independently 
        // a support case may need to be filed with Salesforce if this can be issolated in and replicated in a simpler setup

        testOpportunity = [select Id, StageName from Opportunity where Id = :testOpportunity.Id limit 1];

        System.assertEquals('Closed Won', testOpportunity.StageName);
    }

    @isTest
    private static void testSendToZuoraExecutedNewSubscription() {

        Opportunity testOpportunity = [
                select Id, AccountId, Account.Name, CloseDate, ContractId,
                        Contract.FC_Subscription__c, Contract.FC_Subscription__r.Name,
                        Contract.FC_Subscription__r.Zuora__TermSettingType__c,
                        Contract.FC_Subscription_Number__c, FC_Auto_Renew__c, FC_Batch__c, FC_Bill_Case__c, FC_Bill_Cycle_Day__c,
                        FC_Bill_To_Contact__c, FC_Bill_To_Contact__r.Billing_Email_Address__c, FC_Bill_To_Contact__r.Email,
                        FC_Bill_To_Contact__r.Fax, FC_Bill_To_Contact__r.FirstName, FC_Bill_To_Contact__r.LastName,
                        FC_Bill_To_Contact__r.MailingCity, FC_Bill_To_Contact__r.MailingCountryCode,
                        FC_Bill_To_Contact__r.MailingPostalCode, FC_Bill_To_Contact__r.MailingState,
                        FC_Bill_To_Contact__r.MailingStateCode, FC_Bill_To_Contact__r.MailingStreet,
                        FC_Bill_To_Contact__r.Phone, FC_Billing_Account__c, FC_Billing_Account__r.Zuora__External_Id__c,
                        FC_Currency__c, FC_Contract_Effective_Date__c, FC_Initial_Term__c, FC_Invoice_Separately__c,
                        FC_Payment_Term__c, FC_Renew__c, FC_Renewal_Processed_On__c, FC_Renewal_Term__c,
                        FC_Service_Activation_Date__c, FC_Sold_To_Contact__c, FC_Sold_To_Contact__r.Email,
                        FC_Sold_To_Contact__r.Fax, FC_Sold_To_Contact__r.FirstName, FC_Sold_To_Contact__r.LastName,
                        FC_Sold_To_Contact__r.MailingCity, FC_Sold_To_Contact__r.MailingCountryCode,
                        FC_Sold_To_Contact__r.MailingPostalCode, FC_Sold_To_Contact__r.MailingState,
                        FC_Sold_To_Contact__r.MailingStateCode, FC_Sold_To_Contact__r.MailingStreet,
                        FC_Sold_To_Contact__r.Phone, FC_Subscription_Notes__c, FC_T_C_Term_Start_Date__c,
                        FC_Target_Date__c, FC_Term_Type__c, Metrostudy_Lead__c, Name, One_time_Sale_Type__c, Owner.Name,
                        Pricebook2Id, Purchase_Type__c, Region__c
                from Opportunity
                where Name = 'Test New Subscription New Account Opportunity'
                limit 1
        ];

        FC_Billing_Instruction_Set__c testBillingInstructionSet = [
                select Id
                from FC_Billing_Instruction_Set__c
                where Opportunity__c = :testOpportunity.Id
                limit 1
        ];

        FC_Billing_Instruction_Step__c[] testBillingInstructionSteps = [
                select Id
                from FC_Billing_Instruction_Step__c
                where Billing_Instruction_Set__r.Opportunity__c = :testOpportunity.Id
        ];
        for (FC_Billing_Instruction_Step__c testBillingInstructionStep : testBillingInstructionSteps) {
            testBillingInstructionStep.Status__c = 'Executed';
        }
        update testBillingInstructionSteps;

        PageReference testPage = Page.FC_OpportunitySendToZuora;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        FC_ZuoraCalloutMock mock = new FC_ZuoraCalloutMock();
        mock.testBillingInstructionSetId = testBillingInstructionSet.Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunitySendToZuoraController controller = new FC_OpportunitySendToZuoraController(standardController);

        System.assertEquals(false, controller.hasAmendBillingInstructionSteps);
        System.assertEquals(false, controller.shouldRenew);
        controller.sendToZuora();

        Test.stopTest();

        System.assertEquals(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity());

    }

    @isTest
    private static void testSendToZuoraNewSubscriptionKnownSubscribeError() {

        Opportunity testOpportunity = [
                select Id, AccountId, Account.Name, CloseDate, ContractId,
                        Contract.FC_Subscription__c, Contract.FC_Subscription__r.Name,
                        Contract.FC_Subscription__r.Zuora__TermSettingType__c,
                        Contract.FC_Subscription_Number__c, FC_Auto_Renew__c, FC_Batch__c, FC_Bill_Case__c, FC_Bill_Cycle_Day__c,
                        FC_Bill_To_Contact__c, FC_Bill_To_Contact__r.Billing_Email_Address__c, FC_Bill_To_Contact__r.Email,
                        FC_Bill_To_Contact__r.Fax, FC_Bill_To_Contact__r.FirstName, FC_Bill_To_Contact__r.LastName,
                        FC_Bill_To_Contact__r.MailingCity, FC_Bill_To_Contact__r.MailingCountryCode,
                        FC_Bill_To_Contact__r.MailingPostalCode, FC_Bill_To_Contact__r.MailingState,
                        FC_Bill_To_Contact__r.MailingStateCode, FC_Bill_To_Contact__r.MailingStreet,
                        FC_Bill_To_Contact__r.Phone, FC_Billing_Account__c, FC_Billing_Account__r.Zuora__External_Id__c,
                        FC_Currency__c, FC_Contract_Effective_Date__c, FC_Initial_Term__c, FC_Invoice_Separately__c,
                        FC_Payment_Term__c, FC_Renew__c, FC_Renewal_Processed_On__c, FC_Renewal_Term__c,
                        FC_Service_Activation_Date__c, FC_Sold_To_Contact__c, FC_Sold_To_Contact__r.Email,
                        FC_Sold_To_Contact__r.Fax, FC_Sold_To_Contact__r.FirstName, FC_Sold_To_Contact__r.LastName,
                        FC_Sold_To_Contact__r.MailingCity, FC_Sold_To_Contact__r.MailingCountryCode,
                        FC_Sold_To_Contact__r.MailingPostalCode, FC_Sold_To_Contact__r.MailingState,
                        FC_Sold_To_Contact__r.MailingStateCode, FC_Sold_To_Contact__r.MailingStreet,
                        FC_Sold_To_Contact__r.Phone, FC_Subscription_Notes__c, FC_T_C_Term_Start_Date__c,
                        FC_Target_Date__c, FC_Term_Type__c, Metrostudy_Lead__c, Name, One_time_Sale_Type__c,
                        Owner.Name, Pricebook2Id, Purchase_Type__c, Region__c
                from Opportunity
                where Name = 'Test New Subscription New Account Opportunity'
                limit 1
        ];

        PageReference testPage = Page.FC_OpportunitySendToZuora;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        FC_ZuoraCalloutMock mock = new FC_ZuoraCalloutMock();
        mock.testSubscribeKnownError = true;
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();

        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunitySendToZuoraController controller = new FC_OpportunitySendToZuoraController(standardController);

        System.assertEquals(false, controller.hasAmendBillingInstructionSteps);
        System.assertEquals(false, controller.shouldRenew);
        controller.sendToZuora();

        Test.stopTest();

        testOpportunity = [select Id, StageName from Opportunity where Id = :testOpportunity.Id limit 1];

        System.assertNotEquals('Closed Won', testOpportunity.StageName);
    }

    @isTest
    private static void testSendToZuoraNewSubscriptionUpdateError() {

        Opportunity testOpportunity = [
                select Id, AccountId, Account.Name, CloseDate, ContractId,
                        Contract.FC_Subscription__c, Contract.FC_Subscription__r.Name,
                        Contract.FC_Subscription__r.Zuora__TermSettingType__c,
                        Contract.FC_Subscription_Number__c, FC_Auto_Renew__c, FC_Batch__c, FC_Bill_Case__c, FC_Bill_Cycle_Day__c,
                        FC_Bill_To_Contact__c, FC_Bill_To_Contact__r.Billing_Email_Address__c, FC_Bill_To_Contact__r.Email,
                        FC_Bill_To_Contact__r.Fax, FC_Bill_To_Contact__r.FirstName, FC_Bill_To_Contact__r.LastName,
                        FC_Bill_To_Contact__r.MailingCity, FC_Bill_To_Contact__r.MailingCountryCode,
                        FC_Bill_To_Contact__r.MailingPostalCode, FC_Bill_To_Contact__r.MailingState,
                        FC_Bill_To_Contact__r.MailingStateCode, FC_Bill_To_Contact__r.MailingStreet,
                        FC_Bill_To_Contact__r.Phone, FC_Billing_Account__c, FC_Billing_Account__r.Zuora__External_Id__c,
                        FC_Currency__c, FC_Contract_Effective_Date__c, FC_Initial_Term__c, FC_Invoice_Separately__c,
                        FC_Payment_Term__c, FC_Renew__c, FC_Renewal_Processed_On__c, FC_Renewal_Term__c,
                        FC_Service_Activation_Date__c, FC_Sold_To_Contact__c, FC_Sold_To_Contact__r.Email,
                        FC_Sold_To_Contact__r.Fax, FC_Sold_To_Contact__r.FirstName, FC_Sold_To_Contact__r.LastName,
                        FC_Sold_To_Contact__r.MailingCity, FC_Sold_To_Contact__r.MailingCountryCode,
                        FC_Sold_To_Contact__r.MailingPostalCode, FC_Sold_To_Contact__r.MailingState,
                        FC_Sold_To_Contact__r.MailingStateCode, FC_Sold_To_Contact__r.MailingStreet,
                        FC_Sold_To_Contact__r.Phone, FC_Subscription_Notes__c, FC_T_C_Term_Start_Date__c,
                        FC_Target_Date__c, FC_Term_Type__c, Metrostudy_Lead__c, Name, One_time_Sale_Type__c, Owner.Name,
                        Pricebook2Id, Purchase_Type__c, Region__c
                from Opportunity
                where Name = 'Test New Subscription New Account Opportunity'
                limit 1
        ];

        PageReference testPage = Page.FC_OpportunitySendToZuora;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        FC_ZuoraCalloutMock mock = new FC_ZuoraCalloutMock();
        mock.testUpdateSubscriptionError = true;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunitySendToZuoraController controller = new FC_OpportunitySendToZuoraController(standardController);

        System.assertEquals(false, controller.hasAmendBillingInstructionSteps);
        System.assertEquals(false, controller.shouldRenew);
        controller.sendToZuora();

        Test.stopTest();

        testOpportunity = [select Id, StageName from Opportunity where Id = :testOpportunity.Id limit 1];

        System.assertNotEquals('Closed Won', testOpportunity.StageName);
    }

    @isTest
    private static void testSendToZuoraRenewSubscriptionError() {

        Opportunity testOpportunity = [
                select Id, AccountId, Account.Name, CloseDate, ContractId,
                        Contract.FC_Subscription__c, Contract.FC_Subscription__r.Name,
                        Contract.FC_Subscription__r.Zuora__TermSettingType__c,
                        Contract.FC_Subscription_Number__c, FC_Auto_Renew__c, FC_Batch__c, FC_Bill_Case__c, FC_Bill_Cycle_Day__c,
                        FC_Bill_To_Contact__c, FC_Bill_To_Contact__r.Billing_Email_Address__c, FC_Bill_To_Contact__r.Email,
                        FC_Bill_To_Contact__r.Fax, FC_Bill_To_Contact__r.FirstName, FC_Bill_To_Contact__r.LastName,
                        FC_Bill_To_Contact__r.MailingCity, FC_Bill_To_Contact__r.MailingCountryCode,
                        FC_Bill_To_Contact__r.MailingPostalCode, FC_Bill_To_Contact__r.MailingState,
                        FC_Bill_To_Contact__r.MailingStateCode, FC_Bill_To_Contact__r.MailingStreet,
                        FC_Bill_To_Contact__r.Phone, FC_Billing_Account__c, FC_Billing_Account__r.Zuora__External_Id__c,
                        FC_Currency__c, FC_Contract_Effective_Date__c, FC_Initial_Term__c, FC_Invoice_Separately__c,
                        FC_Payment_Term__c, FC_Renew__c, FC_Renewal_Processed_On__c, FC_Renewal_Term__c,
                        FC_Service_Activation_Date__c, FC_Sold_To_Contact__c, FC_Sold_To_Contact__r.Email,
                        FC_Sold_To_Contact__r.Fax, FC_Sold_To_Contact__r.FirstName, FC_Sold_To_Contact__r.LastName,
                        FC_Sold_To_Contact__r.MailingCity, FC_Sold_To_Contact__r.MailingCountryCode,
                        FC_Sold_To_Contact__r.MailingPostalCode, FC_Sold_To_Contact__r.MailingState,
                        FC_Sold_To_Contact__r.MailingStateCode, FC_Sold_To_Contact__r.MailingStreet,
                        FC_Sold_To_Contact__r.Phone, FC_Subscription_Notes__c, FC_T_C_Term_Start_Date__c,
                        FC_Target_Date__c, FC_Term_Type__c, Metrostudy_Lead__c,Name, One_time_Sale_Type__c, Owner.Name,
                        Pricebook2Id, Purchase_Type__c, Region__c
                from Opportunity
                where Name = 'Test Renew Opportunity'
                limit 1
        ];

        PageReference testPage = Page.FC_OpportunitySendToZuora;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        FC_ZuoraCalloutMock mock = new FC_ZuoraCalloutMock();
        mock.testRenewSubscriptionError = true;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunitySendToZuoraController controller = new FC_OpportunitySendToZuoraController(standardController);

        System.assertEquals(false, controller.hasAmendBillingInstructionSteps);
        System.assertEquals(true, controller.shouldRenew);
        controller.sendToZuora();

        Test.stopTest();

        testOpportunity = [select Id, StageName from Opportunity where Id = :testOpportunity.Id limit 1];

        System.assertNotEquals('Closed Won', testOpportunity.StageName);
    }

    @isTest
    private static void testSendToZuoraExistingSubscription() {

        Opportunity testOpportunity = [
                select Id, AccountId, Account.Name, CloseDate, ContractId,
                        Contract.FC_Subscription__c, Contract.FC_Subscription__r.Name,
                        Contract.FC_Subscription__r.Zuora__TermSettingType__c,
                        Contract.FC_Subscription_Number__c, FC_Auto_Renew__c, FC_Batch__c, FC_Bill_Case__c, FC_Bill_Cycle_Day__c,
                        FC_Bill_To_Contact__c, FC_Bill_To_Contact__r.Billing_Email_Address__c, FC_Bill_To_Contact__r.Email,
                        FC_Bill_To_Contact__r.Fax, FC_Bill_To_Contact__r.FirstName, FC_Bill_To_Contact__r.LastName,
                        FC_Bill_To_Contact__r.MailingCity, FC_Bill_To_Contact__r.MailingCountryCode,
                        FC_Bill_To_Contact__r.MailingPostalCode, FC_Bill_To_Contact__r.MailingState,
                        FC_Bill_To_Contact__r.MailingStateCode, FC_Bill_To_Contact__r.MailingStreet,
                        FC_Bill_To_Contact__r.Phone, FC_Billing_Account__c, FC_Billing_Account__r.Zuora__External_Id__c,
                        FC_Currency__c, FC_Contract_Effective_Date__c, FC_Initial_Term__c, FC_Invoice_Separately__c,
                        FC_Payment_Term__c, FC_Renew__c, FC_Renewal_Processed_On__c, FC_Renewal_Term__c,
                        FC_Service_Activation_Date__c, FC_Sold_To_Contact__c, FC_Sold_To_Contact__r.Email,
                        FC_Sold_To_Contact__r.Fax, FC_Sold_To_Contact__r.FirstName, FC_Sold_To_Contact__r.LastName,
                        FC_Sold_To_Contact__r.MailingCity, FC_Sold_To_Contact__r.MailingCountryCode,
                        FC_Sold_To_Contact__r.MailingPostalCode, FC_Sold_To_Contact__r.MailingState,
                        FC_Sold_To_Contact__r.MailingStateCode, FC_Sold_To_Contact__r.MailingStreet,
                        FC_Sold_To_Contact__r.Phone, FC_Subscription_Notes__c, FC_T_C_Term_Start_Date__c,
                        FC_Target_Date__c, FC_Term_Type__c, Metrostudy_Lead__c, Name, One_time_Sale_Type__c, Owner.Name,
                        Pricebook2Id, Purchase_Type__c, Region__c
                from Opportunity
                where Name = 'Test Existing Subscription Opportunity'
                limit 1
        ];

        PageReference testPage = Page.FC_OpportunitySendToZuora;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());

        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunitySendToZuoraController controller = new FC_OpportunitySendToZuoraController(standardController);
        controller.amendmentBatchSize = 9;

        System.assertEquals(false, controller.hasAmendBillingInstructionSteps);
        System.assertEquals(false, controller.shouldRenew);
        controller.sendToZuora();

        Test.stopTest();

        testOpportunity = [select Id, StageName from Opportunity where Id = :testOpportunity.Id limit 1];

        System.assertEquals('Closed Won', testOpportunity.StageName);
    }

    @isTest
    private static void testSendToZuoraRenewSubscription() {

        Opportunity testOpportunity = [
                select Id, AccountId, Account.Name, CloseDate, ContractId,
                        Contract.FC_Subscription__c, Contract.FC_Subscription__r.Name,
                        Contract.FC_Subscription__r.Zuora__TermSettingType__c,
                        Contract.FC_Subscription_Number__c, FC_Auto_Renew__c, FC_Batch__c, FC_Bill_Case__c, FC_Bill_Cycle_Day__c,
                        FC_Bill_To_Contact__c, FC_Bill_To_Contact__r.Billing_Email_Address__c, FC_Bill_To_Contact__r.Email,
                        FC_Bill_To_Contact__r.Fax, FC_Bill_To_Contact__r.FirstName, FC_Bill_To_Contact__r.LastName,
                        FC_Bill_To_Contact__r.MailingCity, FC_Bill_To_Contact__r.MailingCountryCode,
                        FC_Bill_To_Contact__r.MailingPostalCode, FC_Bill_To_Contact__r.MailingState,
                        FC_Bill_To_Contact__r.MailingStateCode, FC_Bill_To_Contact__r.MailingStreet,
                        FC_Bill_To_Contact__r.Phone, FC_Billing_Account__c, FC_Billing_Account__r.Zuora__External_Id__c,
                        FC_Currency__c, FC_Contract_Effective_Date__c, FC_Initial_Term__c, FC_Invoice_Separately__c,
                        FC_Payment_Term__c, FC_Renew__c, FC_Renewal_Processed_On__c, FC_Renewal_Term__c,
                        FC_Service_Activation_Date__c, FC_Sold_To_Contact__c, FC_Sold_To_Contact__r.Email,
                        FC_Sold_To_Contact__r.Fax, FC_Sold_To_Contact__r.FirstName, FC_Sold_To_Contact__r.LastName,
                        FC_Sold_To_Contact__r.MailingCity, FC_Sold_To_Contact__r.MailingCountryCode,
                        FC_Sold_To_Contact__r.MailingPostalCode, FC_Sold_To_Contact__r.MailingState,
                        FC_Sold_To_Contact__r.MailingStateCode, FC_Sold_To_Contact__r.MailingStreet,
                        FC_Sold_To_Contact__r.Phone, FC_Subscription_Notes__c, FC_T_C_Term_Start_Date__c,
                        FC_Target_Date__c, FC_Term_Type__c, Metrostudy_Lead__c, Name, One_time_Sale_Type__c, Owner.Name,
                        Pricebook2Id, Purchase_Type__c, Region__c
                from Opportunity
                where Name = 'Test Renew Opportunity'
                limit 1
        ];

        PageReference testPage = Page.FC_OpportunitySendToZuora;
        testPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(testPage);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());

        ApexPages.StandardController standardController = new ApexPages.StandardController(testOpportunity);
        FC_OpportunitySendToZuoraController controller = new FC_OpportunitySendToZuoraController(standardController);

        System.assertEquals(false, controller.hasAmendBillingInstructionSteps);
        System.assertEquals(true, controller.shouldRenew);
        controller.sendToZuora();

        Test.stopTest();

        testOpportunity = [select Id, StageName from Opportunity where Id = :testOpportunity.Id limit 1];

        System.assertEquals('Closed Won', testOpportunity.StageName);
    }


    @testSetup
    private static void setup() {
        System.runAs(new User(Id = UserInfo.getUserId())){
        Profile testSalesProfile = [select Id from Profile where Name = 'Media - Sales Rep' limit 1];

        User[] testSalesUsers = new User[]{
                new User(FirstName = 'Test', LastName = 'Sales 1', ProfileId = testSalesProfile.Id,
                        Username = FC_UuidUtil.uuidV4() + '@example.com', Email = FC_UuidUtil.uuidV4() + '@example.com',
                        Alias = FC_UuidUtil.uuidV4().left(8), CommunityNickname = FC_UuidUtil.uuidV4(),
                        TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US'),
                new User(FirstName = 'Test', LastName = 'Sales 2', ProfileId = testSalesProfile.Id,
                        Username = FC_UuidUtil.uuidV4() + '@example.com', Email = FC_UuidUtil.uuidV4() + '@example.com',
                        Alias = FC_UuidUtil.uuidV4().left(8), CommunityNickname = FC_UuidUtil.uuidV4(),
                        TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US', IsActive = false)
        };
        insert testSalesUsers;

        MetrostudySalesRegion__c testSalesRegion = new MetrostudySalesRegion__c(Name = 'Test Sales Region');
        insert testSalesRegion;

        MetrostudySalesRegionAssignment__c[] testSalesRegionAssignments = new MetrostudySalesRegionAssignment__c[]{
                new MetrostudySalesRegionAssignment__c(Name = 'Test Sales Region Assignment 1',
                        SalesRegion__c = testSalesRegion.Id, User__c = testSalesUsers[0].Id, Role__c = 'RD'),
                new MetrostudySalesRegionAssignment__c(Name = 'Test Sales Region Assignment 2',
                        SalesRegion__c = testSalesRegion.Id, User__c = testSalesUsers[1].Id, Role__c = 'RD')
        };
        insert testSalesRegionAssignments;

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
                GeographyType__c = testGeographyType.Id, SalesRegion__c = testSalesRegion.Id);
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
                        FC_Renew__c = true, FC_Contract_Effective_Date__c = Date.today(), FC_Term_Type__c = 'TERMED',
                        Metrostudy_Lead__c = testSalesUsers[0].FirstName + ' ' + testSalesUsers[0].LastName),
                new Opportunity(Name = 'Test New Subscription New Account Opportunity',
                        AccountId = testAccount.Id, Amount = 100,
                        StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30,
                        FC_Bill_To_Contact__c = testContacts[0].Id, FC_Sold_To_Contact__c = testContacts[0].Id, FC_Contract_Effective_Date__c = Date.today(),
                        FC_Batch__c = 'Batch1', FC_Currency__c = 'USD', FC_Payment_Term__c = 'Due Upon Receipt', FC_T_C_Term_Start_Date__c = Date.today() + 15,
                        FC_Term_Type__c = 'TERMED', Metrostudy_Lead__c = testSalesUsers[0].FirstName + ' ' + testSalesUsers[0].LastName),
                new Opportunity(Name = 'Test Existing Subscription Opportunity',
                        AccountId = testAccount.Id, Amount = 100, ContractId = testContract.Id,
                        StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30,
                        FC_Bill_To_Contact__c = testContacts[0].Id, FC_Sold_To_Contact__c = testContacts[0].Id, FC_Contract_Effective_Date__c = Date.today(),
                        FC_Term_Type__c = 'TERMED', Metrostudy_Lead__c = testSalesUsers[0].FirstName + ' ' + testSalesUsers[0].LastName),
                new Opportunity(Name = 'Test Invalid Opportunity', AccountId = testAccount.Id, Amount = 100, FC_Bill_To_Contact__c = testContacts[1].Id,
                        FC_Sold_To_Contact__c = testContacts[1].Id, StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30,
                        Metrostudy_Lead__c = testSalesUsers[0].FirstName + ' ' + testSalesUsers[0].LastName)
        };
        insert testOpportunities;

        String[] uuids = new List<String>();
        for (Integer i = 0; i < 6; i++) {
            uuids.add(FC_UuidUtil.uuidV4());
        }
        OpportunityLineItem[] testOpportunityLineItems = new OpportunityLineItem[]{
                new OpportunityLineItem(OpportunityId = testOpportunities[1].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[0],
                        FC_Zuora_Action__c = 'Add', FC_RD_Assignment__c = testSalesRegionAssignments[0].Id),
                new OpportunityLineItem(OpportunityId = testOpportunities[2].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[1],
                        FC_Zuora_Action__c = 'Add', FC_RD_Assignment__c = testSalesRegionAssignments[1].Id),
                new OpportunityLineItem(OpportunityId = testOpportunities[2].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[2],
                        FC_Zuora_Action__c = 'Add', FC_RD_Assignment__c = testSalesRegionAssignments[0].Id),
                new OpportunityLineItem(OpportunityId = testOpportunities[2].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[3],
                        FC_Zuora_Action__c = 'Add', FC_RD_Assignment__c = testSalesRegionAssignments[1].Id),
                new OpportunityLineItem(OpportunityId = testOpportunities[2].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[4],
                        FC_Zuora_Action__c = 'Add', FC_RD_Assignment__c = testSalesRegionAssignments[0].Id),
                new OpportunityLineItem(OpportunityId = testOpportunities[3].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[5],
                        FC_Zuora_Action__c = 'Add', FC_RD_Assignment__c = testSalesRegionAssignments[1].Id)
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
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'New',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Add').Id),
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[2].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'New',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Modify').Id),
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[3].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'New',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Remove').Id),
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[4].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'New',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Add').Id),
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[5].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'New',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Subscribe').Id)
                };
        insert testBillingInstructionSteps;
        }
    }

}