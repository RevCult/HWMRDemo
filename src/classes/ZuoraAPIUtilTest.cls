@isTest(seeAllData=true)
public with sharing class ZuoraAPIUtilTest{
    static testMethod void myTest(){    
    
    
      test.startTest();
     
     List<Zuora.zObject> Account= ZuoraAPIUtil.zQueryZuora('Account','');
     List<Zuora.zObject> Amendment= ZuoraAPIUtil.zQueryZuora('Amendment','');
     List<Zuora.zObject> RatePlan= ZuoraAPIUtil.zQueryZuora('RatePlan','');
     List<Zuora.zObject> RatePlanCharge= ZuoraAPIUtil.zQueryZuora('RatePlanCharge','');
     List<Zuora.zObject> Subscription= ZuoraAPIUtil.zQueryZuora('Subscription','');
    
    
      test.stopTest();
    
    }

}