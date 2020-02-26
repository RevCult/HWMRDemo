@isTest 
private class WF_Product_Delete_TriggerTest{

    static testMethod void testDelete(){
       

        Pricebook2 pb22 = new Pricebook2(Name='testDIE');
        insert pb22;

        Product2 pro2 = new Product2(Name='BXCD', isActive=true, product__c='XWE');
        insert pro2;
    
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                             isActive=true,UseStandardPrice = false);
        insert pbe2;

         
         Opportunity oppt = new Opportunity(Name ='New opp',StageName = 'Customer Won',Amount = 3000,CloseDate = System.today());
         insert oppt;
         //system.assert(oppt.Id!=null);

         OpportunityLineItem oppLineItem = new OpportunityLineItem(Quantity=2, OpportunityId=oppt.Id,UnitPrice=0.01,WF_Project_ID__c = '2',PriceBookEntryId=pbe2.Id);
         insert oppLineItem;
         //system.assert(oppLineItem.Id!=null);
        
         delete oppLineItem;
        
            
    }

}