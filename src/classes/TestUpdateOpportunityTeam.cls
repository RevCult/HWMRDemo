@isTest(seeAllData = true)
public with sharing class TestUpdateOpportunityTeam {

    static testMethod void myUnitTest() {
    	
    	Pricebook2 pb = [Select Id From Pricebook2 where IsStandard = true];
    	
    	RecordType r = [Select r.SobjectType, r.Name, r.Id From RecordType r where id =  '01280000000BiIi'];
       
        //Create Account
        Account acc = new Account();
        acc.Name = 'Test';
        try{
        	insert acc;
        }
        catch(Exception e){
        	System.debug('Error to insert  Account:'+e);
        }
        
        //Create Opportunity
        Opportunity oppObj = new Opportunity();
        oppObj.AccountId = acc.Id;
        oppObj.Name = 'Test';
        oppObj.Amount = 100.56;
        oppObj.CloseDate = Date.Today().addDays(15);
        oppObj.StageName = 'Proposal Stage';
        oppObj.Type = 'New Customer';
        oppObj.ForecastCategoryName = 'Pipeline';
        oppObj.Pricebook2Id = pb.Id;
        oppObj.RecordTypeId = r.Id;
        
        try{
        	insert oppObj;
        }
        catch(Exception e){
        	System.debug('Error to insert  Opportunity:'+e);
        }
       
        //Create Product
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Product__c = 'TEST';
        p.Marketing_Product__c = true;
        p.MetroStudy_Product__c = true;
        try{
        	insert p;
        }
        catch(Exception e){
        	System.debug('Error to insert Product2 :'+e);
        }
              
        
        //Create PricebookEntry
        PricebookEntry pbeObj = new  PricebookEntry();
        try{
	        pbeObj.Product2Id = p.Id;
	        pbeObj.Pricebook2Id = pb.Id;
	        pbeObj.UnitPrice = 10;
	        pbeObj.IsActive = true;
        	insert pbeObj;
        }
        catch(Exception e){
        	System.debug('Error to insert PricebookEntry:'+e);
        }
        
        // Insert OpportunityLineItem
        OpportunityLineItem oli = new opportunitylineitem(UnitPrice=10000.00, Quantity=10, 
        								opportunityid=oppObj.id, pricebookEntryId=pbeObj.id);
 		try{
        	insert oli;
        }
        catch(Exception e){
        	System.debug('Error to insert OpportunityLineItem:'+e);
        }        
    }
    
}