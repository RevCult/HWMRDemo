@isTest
private class DirectoryCategoriesTest {
    
    private static testmethod void test1() {
        Account a = new Account(name = 'test account', BillingPostalCode = '12345');
        insert a;
        
        Opportunity o = new Opportunity( name =' test opp', closedate = date.today(), stagename = 'Open', accountId = a.id);
        insert o;
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
       
        Product2 prod = new Product2 (Product__c='test', Name='Concrete Construction | Directory Listing (Premium)', Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prod;
        
        Id standardPb = Test.getStandardPricebookId();
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prod.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
       
        Opportunitylineitem lineitem = new Opportunitylineitem(Directory_Categories__c ='test',  Premium_Directory_Categories__c= 'pc',
        opportunityId = o.id,PriceBookEntryID=pbe1.id, quantity=4, UnitPrice = 1);
        
        insert lineitem;
        
        Directory_Category__c dc1 = new Directory_Category__c(name = 'test', Directory_Brands__c='Concrete Construction');
        insert dc1;
        
                
        Test.startTest();
        Apexpages.standardController sc = new Apexpages.standardController(lineitem);
        
        DirectoryCategories dc = new DirectoryCategories(sc);
        dc.search();
        dc.search2();
        
        dc.save();
        Test.stopTest();
    }

}