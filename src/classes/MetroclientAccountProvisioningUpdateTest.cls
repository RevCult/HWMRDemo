@isTest(seeAllData=true)
public class MetroclientAccountProvisioningUpdateTest{

    static testMethod void myTest(){
    
        GoogleIntegrationHelper.disableAsync = true;
        TestFactoryMetroclient.ProductGeographyFactory();        
        MetroclientProductGeography__c  prodGeo=  [SELECT Id FROM MetroclientProductGeography__c  where name = 'TestProdGeo1' Limit 1 ];
        
        Account acc = TestFactoryMetroclient.makeAccount('Test Account');
        Zuora__Subscription__c testSub =  TestFactoryMetroclient.makeSubscription(acc, 'Test Subscription A',System.Today(), System.Today(),'Active' );
        Zuora__SubscriptionProductCharge__c testSubProdCharge =  TestFactoryMetroclient.makeSubscriptionProductCharge(testSub,prodGeo,'Test Charge A',System.Today(), System.Today(),'Reocurring');
       
        //MetroclientAccountProductGeography__c testAccPG = TestFactoryMetroclient.makeAccountProductGeography(acc,prodGeo);
        MetroclientAccountProductGeography__c testAccPG = TestFactoryMetroclient.makeAccountProductGeography(acc,prodGeo, testSub, testSubProdCharge, false, false );
           
    
        string Account = acc.ID;
        string Subscription=testSub.Id;
        string SubName = testSub.Name;
        string ExistSubId = null;
        string QuoteId = null;
        string SubType = 'New Subscription';
   
        test.startTest();
    
        MetroclientAccountProvisioningUpdate.UpdateAccountProvisioningFromZuora(Subscription,SubName,ExistSubId,SubType,QuoteId,Account); 
    
          
        SubType = 'Amend Subscription';
          
        
        MetroclientAccountProvisioningUpdate.UpdateAccountProvisioningFromZuora(Subscription,SubName,ExistSubId,SubType,QuoteId,Account); 
   
        
        SubType = 'Cancel Subscription';
         
        
        MetroclientAccountProvisioningUpdate.UpdateAccountProvisioningFromZuora(Subscription,SubName,ExistSubId,SubType,QuoteId,Account); 
  
   
        test.stopTest();
    
    }
    

}