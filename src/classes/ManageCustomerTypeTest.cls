/******************************************************************************
*
* @description  Tests Manage Customer Type Class
* @author       10KView
* @date         2nd June 2017
*
*****************************************************************************/
@isTest (SeeAllData = false)
private class ManageCustomerTypeTest {
    
    private static Integer numOfTestRecords = 1;


    /******************************************************************************
    *
    * @description  Create Required Test Data
    * @params       none
    * @return       void
    *
    *****************************************************************************/
     @testSetup static void createTestData() {

        // Empty lists
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        List<Opportunity> oList = new List<Opportunity>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();


        // Create Test Product w/Pricebook Entry
        List<Product2> pList = (List<Product2>)TestFactoryHandler.createSObjectList(new Product2(  Name = 'Test Product', 
                                                                                                    CanUseRevenueSchedule = true), 1, 'TestFactoryHandler.Product2Defaults');
        insert pList;       

        for (Product2 p: pList){
                PricebookEntry pbe = (PricebookEntry)TestFactoryHandler.createSObject(new PricebookEntry ( Product2Id = p.Id, 
                                                                                                            Pricebook2Id = Test.getStandardPricebookId(), 
                                                                                                            UnitPrice = 10, 
                                                                                                            IsActive = true));
                    pbeList.add(pbe);
        }

        insert pbeList;

        // Create Test Accounts
        List<Account> aList = (List<Account>)TestFactoryHandler.createSObjectList(new Account(), numOfTestRecords, 'TestFactoryHandler.AccountDefaults');
        insert aList; // insert test accounts


        // Loop test accounts to create opps
        for (Account acc: aList){
            // Call single instance test factory for opp, one per account
            Opportunity o = (Opportunity)TestFactoryHandler.createSObject(new Opportunity(  Name = 'Test' + acc.Name ,
                                                                                            AccountId = acc.Id,
                                                                                            StageName = 'Active',
                                                                                            CloseDate = Date.today()));
            oList.add(o);
            
        }

        insert oList; // insert test opps


     }

    /******************************************************************************
    *
    * @description  1 Test Non-customer updates
    * @params       none
    * @return       void
    *
    *****************************************************************************/
    
    @isTest static void test_NonCustomer() {
        // Implement test code

        System.debug(LoggingLevel.ERROR, '******* 1 Running test_NonCustomer ******** ');
        
        List<Opportunity> oList = [select Id from Opportunity]; // Delete Test Opportunities to force Non-customer..
        delete oList;
        
        Test.startTest();

            Database.executeBatch(new CustomerTypeBatchHandler());

        Test.stopTest();

        List<Account> queryAcccounts = [select Id, Name, Marketing_Customer_Type__c, Media_Customer_Type__c from Account];
        System.assertEquals(queryAcccounts[0].Marketing_Customer_Type__c, 'Non-customer','**** Something went wrong with test_NonCustomer...');
        System.assertEquals(queryAcccounts[0].Media_Customer_Type__c, 'Non-customer','**** Something went wrong with test_NonCustomer...');
        

    }
    
    
    /******************************************************************************
    *
    * @description  2 Test Past Customer Marketing
    * @params       none
    * @return       void
    *
    *****************************************************************************/
    @isTest static void test_PastCustomer_Marketing(){
    
        // Prepare test data for Past Customer Marketing
        List<Opportunity> queryOpp = [select Id, AccountId from Opportunity];
        List<PricebookEntry> queryPBE = [select Product2Id, Pricebook2Id, UnitPrice, IsActive from PricebookEntry];
        List<OpportunityLineItem> insertOLI = new List<OpportunityLineItem>();
        
        for (Opportunity o: queryOpp){
            
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.PricebookEntryId = queryPBE[0].Id;
            oli.OpportunityId = queryOpp[0].Id;
            oli.Marketing_Product__c = true;
            oli.MetroStudy_Product__c = false;
            oli.Quantity = 1;
            oli.UnitPrice = 100;
            oli.HW_Line_Item_Start_Date__c = System.now()-400;
            oli.HW_Line_Item_End_Date__c = System.now()-390;
            insertOLI.add(oli);

        }
        
        try{
            insert insertOLI; // Update test data
        } catch (Exception e){
            System.debug(LoggingLevel.ERROR, '******* Exception test_PastCustomer_Marketing  ******** ' + e);
        }

        

        Test.startTest();

            Database.executeBatch(new CustomerTypeBatchHandler()); // Run Batch Job

        Test.stopTest();

        // Check Account has been updated correctly
        List<Account> queryAcccounts = [select Id, Name, Marketing_Customer_Type__c, Media_Customer_Type__c from Account];
        System.assertEquals(queryAcccounts[0].Marketing_Customer_Type__c, 'Past customer','**** Something went wrong with test_PastCustomer_Marketing...');
        

    }

    /******************************************************************************
    *
    * @description  3 Test Past Customer Media
    * @params       none
    * @return       void
    *
    *****************************************************************************/

    
    @isTest static void test_PastCustomer_Media(){

        // Prepare test data for Past Customer Marketing
        List<Opportunity> queryOpp = [select Id, AccountId from Opportunity];
        List<PricebookEntry> queryPBE = [select Product2Id, Pricebook2Id, UnitPrice, IsActive from PricebookEntry];
        List<OpportunityLineItem> insertOLI = new List<OpportunityLineItem>();
        
        for (Opportunity o: queryOpp){
            
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.PricebookEntryId = queryPBE[0].Id;
            oli.OpportunityId = queryOpp[0].Id;
            oli.Marketing_Product__c = false;
            oli.MetroStudy_Product__c = false;
            oli.Quantity = 1;
            oli.UnitPrice = 100;
            oli.HW_Line_Item_Start_Date__c = System.now()-400;
            oli.HW_Line_Item_End_Date__c = System.now()-390;
            insertOLI.add(oli);

        }

        try{
            insert insertOLI; // Update test data
        } catch (Exception e){
            System.debug(LoggingLevel.ERROR, '******* Exception test_PastCustomer_Marketing  ******** ' + e);
        }


        Test.startTest();

            Database.executeBatch(new CustomerTypeBatchHandler()); // Run Batch Job

        Test.stopTest();

        // Check Account has been updated correctly
        List<Account>   queryAcccounts = [select Id, Name, Marketing_Customer_Type__c, Media_Customer_Type__c from Account];
        System.assertEquals(queryAcccounts[0].Media_Customer_Type__c, 'Past customer','**** Something went wrong with test_PastCustomer_Media...');

    }

    /******************************************************************************
    *
    * @description  4 Test Current Customer Media
    * @params       none
    * @return       void
    *
    *****************************************************************************/

    @isTest static void test_CurrentCustomer_Media(){

        // Prepare test data for Past Customer Marketing
        List<Opportunity> queryOpp = [select Id, AccountId from Opportunity];
        List<PricebookEntry> queryPBE = [select Product2Id, Pricebook2Id, UnitPrice, IsActive from PricebookEntry];
        List<OpportunityLineItem> insertOLI = new List<OpportunityLineItem>();
        
        for (Opportunity o: queryOpp){
            
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.PricebookEntryId = queryPBE[0].Id;
            oli.OpportunityId = queryOpp[0].Id;
            oli.Marketing_Product__c = false;
            oli.MetroStudy_Product__c = false;
            oli.Quantity = 1;
            oli.UnitPrice = 100;
            oli.HW_Line_Item_Start_Date__c = System.now();
            oli.HW_Line_Item_End_Date__c = System.now()+30;
            insertOLI.add(oli);

        }

        try{
            insert insertOLI; // Update test data
        } catch (Exception e){
            System.debug(LoggingLevel.ERROR, '******* Exception test_PastCustomer_Marketing  ******** ' + e);
        }

        Test.startTest();

            Database.executeBatch(new CustomerTypeBatchHandler()); // Run Batch Job

        Test.stopTest();

        // Check Account has been updated correctly
        List<Account> queryAcccounts = [select Id, Name, Marketing_Customer_Type__c, Media_Customer_Type__c from Account];
        System.assertEquals(queryAcccounts[0].Media_Customer_Type__c, 'Current customer','**** Something went wrong with test_CurrentCustomer_Media...');

    }

    /******************************************************************************
    *
    * @description  5 Test Current Customer Marketing
    * @params       none
    * @return       void
    *
    *****************************************************************************/
    @isTest static void test_CurrentCustomer_Marketing(){

        // Prepare test data for Past Customer Marketing
        List<Opportunity> queryOpp = [select Id, AccountId from Opportunity];
        List<PricebookEntry> queryPBE = [select Product2Id, Pricebook2Id, UnitPrice, IsActive from PricebookEntry];
        List<OpportunityLineItem> insertOLI = new List<OpportunityLineItem>();
        
        for (Opportunity o: queryOpp){
            
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.PricebookEntryId = queryPBE[0].Id;
            oli.OpportunityId = queryOpp[0].Id;
            oli.Marketing_Product__c = true;
            oli.MetroStudy_Product__c = false;
            oli.Quantity = 1;
            oli.UnitPrice = 100;
            oli.HW_Line_Item_Start_Date__c = System.now();
            oli.HW_Line_Item_End_Date__c = System.now()+30;
            insertOLI.add(oli);

        }

        try{
            insert insertOLI; // Update test data
        } catch (Exception e){
            System.debug(LoggingLevel.ERROR, '******* Exception test_PastCustomer_Marketing  ******** ' + e);
        }

        Test.startTest();

            Database.executeBatch(new CustomerTypeBatchHandler()); // Run Batch Job

        Test.stopTest();

        // Check Account has been updated correctly
        List<Account> queryAcccounts = [select Id, Name, Marketing_Customer_Type__c, Media_Customer_Type__c from Account];
        System.assertEquals(queryAcccounts[0].Marketing_Customer_Type__c, 'Current customer','**** Something went wrong with test_CurrentCustomer_Marketing...');

    }
    
    
    
    
}