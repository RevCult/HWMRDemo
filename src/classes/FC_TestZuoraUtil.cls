@isTest
private class FC_TestZuoraUtil {

    @isTest
    private static void testBuildGenerateInvoiceForSubscriptionRequest() {

        Test.startTest();

        FC_ZuoraClient.UpdateSubscriptionRequest request = FC_ZuoraUtil.buildGenerateInvoiceForSubscriptionRequest(Date.today());

        Test.stopTest();

        System.assertEquals(Date.today(), request.targetDate);
        System.assertEquals(true, request.runBilling);

    }

    @isTest
    private static void testBuildRenewSubscriptionRequest() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Renew Opportunity' limit 1];

        Test.startTest();

        FC_ZuoraClient.RenewSubscriptionRequest request = FC_ZuoraUtil.buildRenewSubscriptionRequest(testOpportunity);

        Test.stopTest();

        System.assertEquals(false, request.runBilling);

    }

    @isTest
    private static void testBuildSubscribeActionRequest() {

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
                        FC_Target_Date__c, FC_Term_Type__c, Name, Owner.Name, Pricebook2Id, Region__c
                from Opportunity
                where Name = 'Test New Subscription New Account Opportunity'
                limit 1
        ];

        FC_Billing_Instruction_Step__c[] testBillingInstructionSteps = [

                select Id, RecordType.DeveloperName, Bill_Cycle_Day__c, Bill_Cycle_Type__c,
                        Billing_Instruction_Description__c, Billing_Instruction_Set__c,
                        Billing_Period__c, Billing_Period_Alignment__c,
                        Contract_Effective_Date__c, Description__c,
                        End_Date_Condition__c, Execute_Immediately__c, List_Price__c,
                        Metrostudy_Product_Geography_Seg3__c, Metrostudy_Product_Geography_Seg3__r.Charge_Type__c,
                        Metrostudy_Product_Geography_Seg3__r.Geography__c,
                        Metrostudy_Product_Geography_Seg3__r.Geography_Type__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Geography__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Geography__r.Geography__r.Seg2__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZuoraId__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZProduct__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZProduct__r.Name,
                        Metrostudy_Product_Geography_Seg3__r.Seg3__c, Price__c,
                        Product_Rate_Plan__c, Product_Rate_Plan__r.zqu__ZuoraId__c, Quantity__c, RecordTypeId, Specific_Billing_Period__c,
                        Specific_End_Date__c, Status__c, Trigger_Date__c, Trigger_Event__c, Up_To_Periods__c,
                        Up_To_Periods_Type__c, Weekly_Bill_Cycle_Day__c
                from FC_Billing_Instruction_Step__c
                where Billing_Instruction_Set__r.Opportunity__c = :testOpportunity.Id
                and Status__c != 'Executed'
                and Execute_Immediately__c = true
        ];


        Test.startTest();

        FC_ZuoraClient.SubscribeActionRequest request = FC_ZuoraUtil.buildSubscribeActionRequest(testBillingInstructionSteps, testOpportunity);

        Test.stopTest();

        System.assertEquals(false, request.subscribes[0].Account.AutoPay);
        System.assertEquals(testOpportunity.FC_Batch__c, request.subscribes[0].Account.Batch);
        System.assertEquals(testOpportunity.FC_Bill_Cycle_Day__c, request.subscribes[0].Account.BillCycleDay);
        System.assertEquals(testOpportunity.AccountId, request.subscribes[0].Account.CrmId);
        System.assertEquals(testOpportunity.FC_Currency__c, request.subscribes[0].Account.Currency_x);
        System.assertEquals(FC_Billing_Instruction_Settings__c.getOrgDefaults().Check_Payment_Method_Zuora_ID__c,
                request.subscribes[0].Account.DefaultPaymentMethodId);
        System.assertEquals(true, request.subscribes[0].Account.InvoiceDeliveryPrefsEmail);
        System.assertEquals(true, request.subscribes[0].Account.InvoiceDeliveryPrefsPrint);
        System.assertEquals(testOpportunity.Account.Name, request.subscribes[0].Account.Name);
        System.assertEquals(testOpportunity.FC_Payment_Term__c, request.subscribes[0].Account.PaymentTerm);
        System.assertEquals(testOpportunity.Owner.Name, request.subscribes[0].Account.SalesRepName);
        System.assertEquals(testOpportunity.FC_Bill_To_Contact__r.MailingStreet,
                request.subscribes[0].BillToContact.Address1 + '\n' + request.subscribes[0].BillToContact.Address2);
        System.assertEquals(testOpportunity.FC_Bill_To_Contact__r.MailingCity,
                request.subscribes[0].BillToContact.City);
        System.assertEquals(testOpportunity.FC_Bill_To_Contact__r.MailingCountryCode,
                request.subscribes[0].BillToContact.Country);
        System.assertEquals(testOpportunity.FC_Bill_To_Contact__r.Fax, request.subscribes[0].BillToContact.Fax);
        System.assertEquals(testOpportunity.FC_Bill_To_Contact__r.FirstName, request.subscribes[0].BillToContact.FirstName);
        System.assertEquals(testOpportunity.FC_Bill_To_Contact__r.LastName, request.subscribes[0].BillToContact.LastName);
        System.assertEquals(testOpportunity.FC_Bill_To_Contact__r.MailingPostalCode, request.subscribes[0].BillToContact.PostalCode);
        System.assertEquals(testOpportunity.FC_Bill_To_Contact__r.MailingStateCode, request.subscribes[0].BillToContact.State);
        System.assertEquals(testOpportunity.FC_Bill_To_Contact__r.Billing_Email_Address__c, request.subscribes[0].BillToContact.WorkEmail);
        System.assertEquals(testOpportunity.FC_Sold_To_Contact__r.MailingStreet,
                request.subscribes[0].SoldToContact.Address1 + '\n' + request.subscribes[0].SoldToContact.Address2);
        System.assertEquals(testOpportunity.FC_Sold_To_Contact__r.MailingCity,
                request.subscribes[0].SoldToContact.City);
        System.assertEquals(testOpportunity.FC_Sold_To_Contact__r.MailingCountryCode,
                request.subscribes[0].SoldToContact.Country);
        System.assertEquals(testOpportunity.FC_Sold_To_Contact__r.Fax, request.subscribes[0].SoldToContact.Fax);
        System.assertEquals(testOpportunity.FC_Sold_To_Contact__r.FirstName, request.subscribes[0].SoldToContact.FirstName);
        System.assertEquals(testOpportunity.FC_Sold_To_Contact__r.LastName, request.subscribes[0].SoldToContact.LastName);
        System.assertEquals(testOpportunity.FC_Sold_To_Contact__r.MailingPostalCode, request.subscribes[0].SoldToContact.PostalCode);
        System.assertEquals(testOpportunity.FC_Sold_To_Contact__r.MailingStateCode, request.subscribes[0].SoldToContact.State);
        System.assertEquals(testOpportunity.FC_Sold_To_Contact__r.Email, request.subscribes[0].SoldToContact.WorkEmail);
        System.assertEquals(false, request.subscribes[0].PreviewOptions.EnablePreviewMode);
        System.assertEquals(false, request.subscribes[0].SubscribeOptions.GenerateInvoice);
        System.assertEquals(false, request.subscribes[0].SubscribeOptions.ProcessPayments);
        System.assertEquals(testOpportunity.FC_Target_Date__c,
                request.subscribes[0].SubscribeOptions.SubscribeInvoiceProcessingOptions.InvoiceTargetDate);
        System.assertEquals(testOpportunity.FC_Auto_Renew__c, request.subscribes[0].SubscriptionData.Subscription.AutoRenew);
        System.assertEquals(testOpportunity.FC_Contract_Effective_Date__c, request.subscribes[0].SubscriptionData.Subscription.ContractEffectiveDate);
        System.assertEquals(testOpportunity.FC_Initial_Term__c, request.subscribes[0].SubscriptionData.Subscription.InitialTerm);
        System.assertEquals(testOpportunity.FC_Invoice_Separately__c, request.subscribes[0].SubscriptionData.Subscription.IsInvoiceSeparate);
        System.assertEquals(testOpportunity.CloseDate, request.subscribes[0].SubscriptionData.Subscription.OpportunityCloseDate_q);
        System.assertEquals(testOpportunity.Id, request.subscribes[0].SubscriptionData.Subscription.OpportunityID_c);
        System.assertEquals(testOpportunity.Name, request.subscribes[0].SubscriptionData.Subscription.OpportunityName_q);
        System.assertEquals(testOpportunity.Region__c, request.subscribes[0].SubscriptionData.Subscription.Region_c);
        System.assertEquals(testOpportunity.FC_Renewal_Term__c, request.subscribes[0].SubscriptionData.Subscription.RenewalTerm);
        System.assertEquals(testOpportunity.FC_Service_Activation_Date__c, request.subscribes[0].SubscriptionData.Subscription.ServiceActivationDate);
        System.assertEquals(testOpportunity.FC_Contract_Effective_Date__c, request.subscribes[0].SubscriptionData.Subscription.TermStartDate);
        System.assertEquals(testOpportunity.FC_Term_Type__c, request.subscribes[0].SubscriptionData.Subscription.TermType);
        System.assertEquals(testBillingInstructionSteps[0].Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZuoraId__c,
                request.subscribes[0].SubscriptionData.RatePlanData[0].RatePlan.ProductRatePlanId);
        System.assertEquals(String.valueOf(testBillingInstructionSteps[0].Bill_Cycle_Day__c),
                String.valueOf(request.subscribes[0].SubscriptionData.RatePlanData[0].RatePlanChargeData[0].RatePlanCharge.BillCycleDay));
        System.assertEquals(testBillingInstructionSteps[0].Billing_Instruction_Set__c,
                request.subscribes[0].SubscriptionData.RatePlanData[0].RatePlanChargeData[0].RatePlanCharge.BillingInstructionSetId_c);
        System.assertEquals(testBillingInstructionSteps[0].Billing_Period__c,
                request.subscribes[0].SubscriptionData.RatePlanData[0].RatePlanChargeData[0].RatePlanCharge.BillingPeriod);

    }

    @isTest
    private static void testBuildUpdateSubscriptionRequestTermStartDate() {

        Opportunity testOpportunity = [select Id, CloseDate, Name from Opportunity where Name = 'Test Existing Subscription Opportunity' limit 1];

        Test.startTest();

        FC_ZuoraClient.UpdateSubscriptionRequest request = FC_ZuoraUtil.buildUpdateSubscriptionRequest(
                Date.today(), testOpportunity, false);

        Test.stopTest();

        System.assertEquals(testOpportunity.CloseDate, request.OpportunityCloseDate_q);
        System.assertEquals(testOpportunity.Id, request.OpportunityID_c);
        System.assertEquals(testOpportunity.Name, request.OpportunityName_q);
        System.assertEquals(false, request.preview);
        System.assertEquals(Date.today(), request.termStartDate);

    }

    @isTest
    private static void testBuildUpdateSubscriptionForTCAmendment() {

        Test.startTest();
        FC_ZuoraClient.UpdateSubscriptionRequest request = FC_ZuoraUtil.buildUpdateSubscriptionRequest(
                'TERMED', 12, 'Month', 'RENEW_WITH_SPECIFIC_TERM', 12, 'Month', Date.today(), true);
        Test.stopTest();

        System.assertEquals('TERMED', request.termType);
        System.assertEquals(12, request.currentTerm);
        System.assertEquals('Month', request.currentTermPeriodType);
        System.assertEquals('RENEW_WITH_SPECIFIC_TERM', request.renewalSetting);
        System.assertEquals(12, request.renewalTerm);
        System.assertEquals('Month', request.renewalTermPeriodType);
        System.assertEquals(Date.today(), request.termStartDate);
        System.assertEquals(true, request.autoRenew);

    }

    @isTest
    private static void testBuildUpdateSubscriptionRequestBillingInstructionSteps() {

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
                        FC_Target_Date__c, FC_Term_Type__c, Name, Owner.Name, Pricebook2Id, Region__c
                from Opportunity
                where Name = 'Test Existing Subscription Opportunity'
                limit 1
        ];

        FC_Billing_Instruction_Step__c[] testBillingInstructionSteps = [

                select Id, RecordType.DeveloperName, Bill_Cycle_Day__c, Bill_Cycle_Type__c,
                        Billing_Instruction_Description__c, Billing_Instruction_Set__c,
                        Billing_Instruction_Set__r.Charge_Number__c,
                        Billing_Period__c, Billing_Period_Alignment__c,
                        Contract_Effective_Date__c, Description__c,
                        End_Date_Condition__c, Execute_Immediately__c, List_Price__c,
                        Metrostudy_Product_Geography_Seg3__c, Metrostudy_Product_Geography_Seg3__r.Charge_Type__c,
                        Metrostudy_Product_Geography_Seg3__r.Geography__c,
                        Metrostudy_Product_Geography_Seg3__r.Geography_Type__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Geography__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Geography__r.Geography__r.Seg2__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZuoraId__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZProduct__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZProduct__r.Name,
                        Metrostudy_Product_Geography_Seg3__r.Seg3__c, Price__c,
                        Product_Rate_Plan__c, Product_Rate_Plan__r.zqu__ZuoraId__c, Quantity__c, RecordTypeId, Specific_Billing_Period__c,
                        Specific_End_Date__c, Status__c, Trigger_Date__c, Trigger_Event__c, Up_To_Periods__c,
                        Up_To_Periods_Type__c, Weekly_Bill_Cycle_Day__c
                from FC_Billing_Instruction_Step__c
                where Billing_Instruction_Set__r.Opportunity__c = :testOpportunity.Id
                and Status__c != 'Executed'
                and Execute_Immediately__c = true
        ];

        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        Test.startTest();

        FC_ZuoraClient.UpdateSubscriptionRequest request =
                FC_ZuoraUtil.buildUpdateSubscriptionRequest(testBillingInstructionSteps, testOpportunity, false);

        Test.stopTest();

        System.assertEquals(1, request.add.size());
        System.assertEquals(1, request.update_x.size());
        System.assertEquals(1, request.remove.size());
    }

    @testSetup
    private static void setup() {

        FC_Billing_Instruction_Settings__c testBillingInstructionSettings =
                new FC_Billing_Instruction_Settings__c(SetupOwnerId = UserInfo.getOrganizationId(),
                        Check_Payment_Method_Zuora_ID__c = '1234567890');
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
                        AccountId = testAccount.Id, Amount = 100,
                        StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30,
                        FC_Renew__c = true),
                new Opportunity(Name = 'Test New Subscription New Account Opportunity',
                        AccountId = testAccount.Id, Amount = 100,
                        StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30,
                        FC_Bill_To_Contact__c = testContact.Id, FC_Sold_To_Contact__c = testContact.Id),
                new Opportunity(Name = 'Test Existing Subscription Opportunity',
                        AccountId = testAccount.Id, Amount = 100, ContractId = testContract.Id,
                        StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30,
                        FC_Bill_To_Contact__c = testContact.Id, FC_Sold_To_Contact__c = testContact.Id)
        };
        insert testOpportunities;

        String[] uuids = new List<String>();
        for (Integer i = 0; i < 5; i++) {
            uuids.add(FC_UuidUtil.uuidV4());
        }
        OpportunityLineItem[] testOpportunityLineItems = new OpportunityLineItem[]{
                new OpportunityLineItem(OpportunityId = testOpportunities[1].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[0]),
                new OpportunityLineItem(OpportunityId = testOpportunities[2].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[1]),
                new OpportunityLineItem(OpportunityId = testOpportunities[2].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[2]),
                new OpportunityLineItem(OpportunityId = testOpportunities[2].Id, PricebookEntryId = testPricebookEntry.Id,
                        FC_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Quantity = 1, UnitPrice = 100, FC_UUID__c = uuids[3]),
                new OpportunityLineItem(OpportunityId = testOpportunities[2].Id, PricebookEntryId = testPricebookEntry.Id,
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
        update testOpportunityLineItems;

        FC_Billing_Instruction_Step__c[] testBillingInstructionSteps =
                new FC_Billing_Instruction_Step__c[]{
                        new FC_Billing_Instruction_Step__c(Billing_Instruction_Set__c = testBillingInstructionSets[0].Id,
                                Contract_Effective_Date__c = Date.today(), Billing_Period__c = 'Month',
                                Metrostudy_Product_Geography_Seg3__c = testProductGeographySeg3.Id, Status__c = 'New',
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Add').Id),
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
                                Execute_Immediately__c = true, RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Remove').Id)
                };
        insert testBillingInstructionSteps;

    }

}