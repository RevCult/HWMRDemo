@IsTest()
public class AdBookIntegration_Test {
    
    @TestSetup
    public static void init() {
        // Ensure URLs are configured for AdBook callouts
        AB2.Test_AdBookTestData.minimalSetupWithSettings();
        
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        PricebookEntry testPricebookEntry = new PricebookEntry(IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(), Product2Id = testProduct.Id, UnitPrice = 100);
        insert testPricebookEntry;
    }
    
    @IsTest()
    public static void autoPopulateBillingContact() {
        boolean insertOpp = false;
        Opportunity opp = testOpportunity(insertOpp);
        
        Contact billingContact = new Contact();
        billingContact.LastName = 'Billy Contact';
        billingContact.AB2__AB_Contact_Type_new__c = 'Billing;General';
        billingContact.AccountId = opp.AccountId;
        insert billingContact;
        
        // Will be copied to AB2__ABBillingContact__c
        opp.Billing_Contact__c = billingContact.Id;
        
        // Needed to make the trigger handler fire.
        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_OpportunityHandler'
        });
               
        Test.startTest();
        insert opp;
        Test.stopTest();
        
        Opportunity oppAfterInsert = [Select Id, AB2__ABBillingContact__c, Billing_Contact__c from Opportunity where Id = :opp.Id];
        System.assertEquals(oppAfterInsert.Billing_Contact__c, oppAfterInsert.AB2__ABBillingContact__c);
    }
    
    @IsTest()
    public static void autoPopulateDoubleClickAgency() {
        boolean insertOpp = false;
        Opportunity opp = testOpportunity(insertOpp);
        
        Account agencyAccount = new Account();
        agencyAccount.Name = 'Test Agency';
        agencyAccount.BillingPostalCode = '12345';
        agencyAccount.AB2__ABAccountType__c = 'Agency';
        insert agencyAccount;
        
        // Will be copied to AB2__AB_Agency__c
        opp.Agency_Name__c = agencyAccount.Id;
        
        // Needed to make the trigger handler fire.
        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_OpportunityHandler'
        });
        
        Test.startTest();
        insert opp;
        Test.stopTest();
        
        Opportunity oppAfterInsert = [Select Id, AB2__AB_Agency__c, Agency_Name__c from Opportunity where Id = :opp.Id];
        System.assertEquals(oppAfterInsert.Agency_Name__c, oppAfterInsert.AB2__AB_Agency__c);
    }
    
    @IsTest
    public static void updateOpportunityDetailsTest() {
        boolean insertOpp = false;
        Opportunity opp = testOpportunity(insertOpp);
        
        Account agencyAccount = new Account();
        agencyAccount.Name = 'Test Agency';
        agencyAccount.BillingPostalCode = '12345';
        // Explicitly required to prevent breakage from workflow field update
        agencyAccount.Media_Account_Type__c = 'AGENCY';
        agencyAccount.AB2__ABAccountType__c = 'Agency';
        insert agencyAccount;
        // Workflow field update can alter this field.
        Account agencyAccountAfterInsert = [Select Id,AB2__ABAccountType__c from Account where Id = :agencyAccount.Id];
        System.assertEquals('Agency',agencyAccountAfterInsert.AB2__ABAccountType__c);
        
        
        // Will be mapped back to Agency_Name__c after refresh from AdBook
        opp.AB2__AB_Agency__c = agencyAccount.Id;
        
        Contact billingContact = new Contact();
        billingContact.LastName = 'Billy Contact';
        billingContact.AB2__AB_Contact_Type_new__c = 'Billing;General';
        billingContact.AccountId = opp.AccountId;
        insert billingContact;
        
        // Will be mapped back to Billing_Contact__c after refresh from AdBook
        opp.AB2__ABBillingContact__c = billingContact.Id;
        
        insert opp;
        
        AdBookOpportunityRefreshedEvent refreshEventHandler = new AdBookOpportunityRefreshedEvent();
        Test.startTest();
        //AdBookIntegration.updateOpportunityDetails(opp.Id);
        boolean onlyRefreshDrops = false;
        refreshEventHandler.refreshedOpportunity(opp, onlyRefreshDrops);
        Test.stopTest();
        
        Opportunity oppAfterInsert = [Select Id, AB2__AB_Agency__c, Agency_Name__c, AB2__ABBillingContact__c, Billing_Contact__c from Opportunity where Id = :opp.Id];
        System.assertEquals(oppAfterInsert.AB2__AB_Agency__c, oppAfterInsert.Agency_Name__c);
        System.assertEquals(oppAfterInsert.AB2__ABBillingContact__c, oppAfterInsert.Billing_Contact__c);
    }
    
    @IsTest()
    public static void refreshedOpportunityEventAsync() {
        boolean insertOpp = true;
        Opportunity opp = testOpportunity(insertOpp);
            
        Test.startTest();
        refreshedOpportunityAsync(opp.Id);
        Test.stopTest();
    }
    
    @Future
    private static void refreshedOpportunityAsync(Id oppId) {
        Opportunity opp = [Select Id from Opportunity where Id = :oppId];
        boolean onlyRefreshDrops = false;
        AdBookOpportunityRefreshedEvent refreshEventHandler = new AdBookOpportunityRefreshedEvent();
        refreshEventHandler.refreshedOpportunity(opp, onlyRefreshDrops);
    }
    
    @IsTest()
    public static void mapAccountMediaAccountTypeToContactABContactType() {       
        Account advertiserAccount = new Account();
        advertiserAccount.Name = 'Test Advertiser';
        advertiserAccount.BillingPostalCode = '12345';
        advertiserAccount.Media_Account_Type__c = 'ADVERTISER';
        
        Account agencyAccount = new Account();
        agencyAccount.Name = 'Test Agency';
        agencyAccount.BillingPostalCode = '12345';
        agencyAccount.Media_Account_Type__c = 'AGENCY';
        
        insert new List<Account>{advertiserAccount, agencyAccount};
        
        Contact advertiserContact = new Contact();
        advertiserContact.LastName = 'Test Advertiser Contact';
        advertiserContact.AccountId = advertiserAccount.Id;
        
        Contact materialsAdvertiserContact = new Contact();
        materialsAdvertiserContact.LastName = 'Test Materials Advertiser Contact';
        materialsAdvertiserContact.AccountId = advertiserAccount.Id;
        materialsAdvertiserContact.AB2__AB_Contact_Type_new__c = 'Materials; General';
        
        Contact agencyContact = new Contact();
        agencyContact.LastName = 'Test Agency Contact';
        agencyContact.AccountId = agencyAccount.Id;
        
        Contact billingAgencyContact = new Contact();
        billingAgencyContact.LastName = 'Test Agency Contact';
        billingAgencyContact.AccountId = agencyAccount.Id;
        billingAgencyContact.AB2__AB_Contact_Type_new__c = 'Billing';
        
        insert new List<Contact>{advertiserContact, agencyContact, materialsAdvertiserContact, billingAgencyContact};
        
            for(Contact contactAfterInsert : 
                [Select Id, AB2__AB_Contact_Type_new__c, Media_Account_Type__c from Contact]) {
                    if(contactAfterInsert.Id == advertiserContact.Id ||
                       contactAfterInsert.Id == materialsAdvertiserContact.Id) {
                        System.assertEquals('ADVERTISER', contactAfterInsert.Media_Account_Type__c);
                        System.assert(contactAfterInsert.AB2__AB_Contact_Type_new__c.contains('Client'));
                    } else if(contactAfterInsert.Id == agencyContact.Id ||
                             contactAfterInsert.Id == billingAgencyContact.Id) {
                        System.assertEquals('AGENCY', contactAfterInsert.Media_Account_Type__c);
                        System.assert(contactAfterInsert.AB2__AB_Contact_Type_new__c.contains('Agency'));
                    } else {
                        System.assert(false, 'Unknown Contact Id: ' + contactAfterInsert.Id);
                    }
            }
        
    }
    
    @IsTest()
    public static void handleOpportunityLineItemTriggerPopulateFields() {
        boolean insertOpp = true;
        Opportunity opp = testOpportunity(insertOpp);
            
        // Needed to make the trigger handler fire.
        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_OpportunityLineItemHandler'
        });
        
        string rand = String.valueOf(Math.rint(Math.random() * 10000)) + DateTime.now().getTime();
        
        // (GMT-04:00) Eastern Daylight Time (America/New_York)
        string timeZoneSidKeyNewYork = 'America/New_York';
        
        User u = new User(Alias='testUser', Email='test'+rand+'@example.com', 
            EmailEncodingKey='UTF-8', LastName='Doe', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey=timeZoneSidKeyNewYork, UserName='hwTest' + rand + '@example.com');
        
        OpportunityLineItem oli = testOpportunityLineItem(opp);
        DateTime startDate = DateTime.newInstance(2018, 7, 4);
        DateTime endDate = DateTime.newInstance(2018, 7, 10);
        System.runAs(u) {
            Timezone tz = Timezone.getTimeZone(timeZoneSidKeyNewYork);
            
            oli.AB2__ABStartDate__c = startDate.date();
            oli.AB2__ABEndDate__c = endDate.date();
            
            Test.startTest();
            insert oli;
            Test.stopTest();
        }
        
        OpportunityLineItem oliAfterInsert = [Select Id, AB2__ABStartDate__c, HW_Line_Item_Start_Date__c, AB2__ABEndDate__c, HW_Line_Item_End_Date__c from OpportunityLineItem where Id = :oli.Id];        
        
        System.assertEquals(startDate.year(), oliAfterInsert.HW_Line_Item_Start_Date__c.year());
        System.assertEquals(startDate.month(), oliAfterInsert.HW_Line_Item_Start_Date__c.month());
        System.assertEquals(startDate.day(), oliAfterInsert.HW_Line_Item_Start_Date__c.day());
        
        System.assertEquals(endDate.year(), oliAfterInsert.HW_Line_Item_End_Date__c.year());
        System.assertEquals(endDate.month(), oliAfterInsert.HW_Line_Item_End_Date__c.month());
        System.assertEquals(endDate.day(), oliAfterInsert.HW_Line_Item_End_Date__c.day());
    }
    
    private static OpportunityLineItem testOpportunityLineItem(Opportunity opp) {
        PricebookEntry testPricebookEntry = [
                select Id
                from PricebookEntry
                where Product2.Name = 'Test Product' and Pricebook2Id = :Test.getStandardPricebookId()
                limit 1
        ];
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = testPricebookEntry.Id;
        return oli;
    }
    
    public static Opportunity testOpportunity(boolean insertOpp){
        // Setup test data
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingPostalCode = '12345';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.Amount = 100.56;
        opp.StageName = 'Proposal Stage';
        opp.CloseDate = Date.Today().addDays(15);
        opp.Type = 'New Customer';
        opp.ForecastCategoryName = 'Pipeline';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.recordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CPQ Opportunity').getRecordTypeId();
        
        // Should still be picked up if this field is null or 'N/A'
        opp.AB_DFP_Order_ID__c = 'N/A';
        opp.AB2__ABOrderID__c = '12345';
        
        if(insertOpp) {
            insert opp;  
        }
        
        return opp;
    }
}