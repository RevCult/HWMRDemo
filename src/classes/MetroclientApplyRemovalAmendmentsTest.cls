@isTest
public class MetroclientApplyRemovalAmendmentsTest{
 @isTest static void MetroclientApplyRemovalAmendmentsTest()   
    {
       test.startTest(); 
        
        Account acc = TestFactoryMetroclient.makeAccount('Account 1');
        Account acc2 = TestFactoryMetroclient.makeAccount('Account 2');
          
        TestFactoryMetroclient.ProductGeographyFactory();        
        MetroclientProductGeography__c  prodGeo=  [SELECT Id FROM MetroclientProductGeography__c  where name = 'TestProdGeo1' Limit 1 ];
        MetroclientProductGeography__c  prodGeo2=  [SELECT Id FROM MetroclientProductGeography__c  where name = 'TestProdGeo2' Limit 1 ];
        MetroclientProductGeography__c  prodGeo3=  [SELECT Id FROM MetroclientProductGeography__c  where name = 'TestProdGeo3' Limit 1 ];
        
        Zuora__Subscription__c testSub =  TestFactoryMetroclient.makeSubscription(acc, 'Test Subscription A',System.Today(), System.Today(),'Active' );
        Zuora__SubscriptionProductCharge__c testSubProdCharge =  TestFactoryMetroclient.makeSubscriptionProductCharge(testSub,prodGeo,'Test Charge A',System.Today(), System.Today(),'Reocurring');
        Zuora__SubscriptionProductCharge__c testSubProdChargeB =  TestFactoryMetroclient.makeSubscriptionProductCharge(testSub,prodGeo, 'Test Charge b',System.Today(), System.Today(),'OneTime'); //will flag different Record Id and different Account
        Zuora__SubscriptionProductCharge__c testSubProdChargeC =  TestFactoryMetroclient.makeSubscriptionProductCharge(testSub,prodGeo2, 'Test Charge c',System.Today(), System.Today(),'Reocurring'); //will flag new provisioning
        Zuora__SubscriptionProductCharge__c testSubProdChargeD =  TestFactoryMetroclient.makeSubscriptionProductCharge(testSub,prodGeo, 'Test Charge d',System.Today(), System.Today(),'Reocurring'); 
        Zuora__SubscriptionProductCharge__c testSubProdChargeE =  TestFactoryMetroclient.makeSubscriptionProductCharge(testSub,prodGeo, 'Test Charge e',System.Today(), System.Today(),'Reocurring'); 
       
        Zuora__Subscription__c testSubB =  TestFactoryMetroclient.makeSubscription(acc2, 'Test Subscription B',System.Today(), System.Today(),'Active' );
        Zuora__SubscriptionProductCharge__c testSubProdChargeB1 =  TestFactoryMetroclient.makeSubscriptionProductCharge(testSubB,prodGeo,'Test Charge B-1',System.Today(), System.Today(),'Reocurring');
        
        MetroclientAccountProductGeography__c testAccPG = TestFactoryMetroclient.makeAccountProductGeography(acc,prodGeo, testSub, testSubProdCharge, false, false );
        MetroclientAccountProductGeography__c testAccPG2 = TestFactoryMetroclient.makeAccountProductGeography(acc2,prodGeo2, testSub, testSubProdChargeB, true, false );
        MetroclientAccountProductGeography__c testAccPG4 = TestFactoryMetroclient.makeAccountProductGeographySameDates(acc,prodGeo, testSub, testSubProdChargeD, false, false );
        MetroclientAccountProductGeography__c testAccPG5 = TestFactoryMetroclient.makeAccountProductGeographySameDates(acc2,prodGeo2, testSub, testSubProdChargeE, false, false );
        MetroclientAccountProductGeography__c testAccPG6 = TestFactoryMetroclient.makeAccountProductGeography(acc2,prodGeo2, testSub, testSubProdChargeB, false, false );
        
        
        MetroclientSubscriptionAmendmentLog__c testAmdLog = TestFactoryMetroclient.makeAmendmentLog('MS-A0001', testSub, testSubProdCharge, 'RemoveProduct', System.Today());
        MetroclientSubscriptionAmendmentLog__c testAmdLog2 = TestFactoryMetroclient.makeAmendmentLog('MS-A0002', testSub, testSubProdChargeB, 'RemoveProduct', System.Today());
       
        //Zuora__CustomerAccount__c testBillAcc= TestFactoryMetroclient.makeBillingAccount(acc);
        
        
      
       SchedulableContext sc = null;
       MetroclientApplyRemovalAmendments b = new MetroclientApplyRemovalAmendments ();
       b.execute(sc);              
       test.stopTest(); 
    }   
}