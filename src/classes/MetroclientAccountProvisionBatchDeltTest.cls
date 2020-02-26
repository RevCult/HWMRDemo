@isTest(SeeAllData=true)
public class MetroclientAccountProvisionBatchDeltTest{
 @isTest static void MetroclientAccountProvisionBatchDeltTest()   
    {
    	GoogleIntegrationHelper.disableAsync = true;
        test.startTest(); 
        Account acc = TestFactoryMetroclient.makeAccount('Account 1');
        TestFactoryMetroclient.ProductGeographyFactory();        
        MetroclientProductGeography__c  prodGeo=  [SELECT Id FROM MetroclientProductGeography__c  where name = 'TestProdGeo1' Limit 1 ];
         
        Zuora__Subscription__c testSub =  TestFactoryMetroclient.makeSubscription(acc, 'Test Subscription 9',System.Today(), System.Today(),'Active' );
        Zuora__SubscriptionProductCharge__c testSubProdCharge =  TestFactoryMetroclient.makeSubscriptionProductCharge(testSub,prodGeo,'Test Charge 1',System.Today(), System.Today(),'Reocurring');
        Zuora__SubscriptionProductCharge__c testSubProdChargeB =  TestFactoryMetroclient.makeSubscriptionProductCharge(testSub,prodGeo, 'Test Charge 2',System.Today(), System.Today(),'OneTime'); 
        Zuora__SubscriptionProductCharge__c testSubProdChargeC =  TestFactoryMetroclient.makeSubscriptionProductCharge(testSub,prodGeo, 'Test Charge 3',System.Today(), System.Today(),'Reocurring'); 
        Zuora__SubscriptionProductCharge__c testSubProdChargeD =  TestFactoryMetroclient.makeSubscriptionProductCharge(testSub,prodGeo, 'Test Charge 4',System.Today(), System.Today(),'Reocurring'); 
     
        MetroclientAccountProductGeography__c testAccPG = TestFactoryMetroclient.makeAccountProductGeography(acc,prodGeo, testSub, testSubProdCharge, false, false );
        MetroclientAccountProductGeography__c testAccPG2 = TestFactoryMetroclient.makeAccountProductGeography(acc,prodGeo, testSub, testSubProdChargeB, true, false );
        MetroclientAccountProductGeography__c testAccPG3 = TestFactoryMetroclient.makeAccountProductGeography(acc,prodGeo, testSub, testSubProdChargeC, true, false );
        MetroclientAccountProductGeography__c testAccPG4 = TestFactoryMetroclient.makeAccountProductGeographySameDates(acc,prodGeo, testSub, testSubProdChargeD, false, false );
         
        SchedulableContext sc = null;
        MetroclientAccountProvisionBatchDelete b = new MetroclientAccountProvisionBatchDelete();
        b.execute(sc);              
        test.stopTest(); 
    }   
}