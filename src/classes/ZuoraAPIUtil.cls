public with sharing class ZuoraAPIUtil{
 
 
public static Zuora.zApi zConnection{
    get {
        if (zConnection== null) {
        zConnection= new Zuora.zApi();
        zConnection.zlogin();
        }
    return zConnection;
    }
    set {
        zConnection= value;
    }
}


public static Zuora.zObject[] zQueryZuora(String zoqlObject, String zoqlQuery) {
    Zuora.zObject[] zobjects;     
    if (Test.isRunningTest()) {
         zobjects = getDummyZObjects(zoqlObject);
    } else {
        zobjects = zConnection.zquery(zoqlQuery); 
    }
    return zobjects;
}

public  static Zuora.ZObject[] getDummyZObjects(String objectName) {

Zuora.ZObject[] zobjects = new List<Zuora.ZObject>();

If (objectName == 'Account') {
    For (Integer I = 0; I < 10; i++) {
        Zuora.zobject zobject = new Zuora.zObject('Account');
        Zobject.setValue('Name', 'Test Account' + I);
        Zobject.setValue('BillCycleDay', 1);
        Zobject.setValue('Currency', 'USD');
        Zobject.setValue('Status', 'Active');
        Zobject.setValue('PaymentTerm', 'Net 30');        
        Zobjects.add(zobject);
    }
}Else If (objectName == 'Amendment') {
    For (Integer I = 0; I < 10; i++) {
        Zuora.zobject zobject = new Zuora.zObject('Amendment');
        Zobject.setValue('Name', 'Amendment | Test | ' + I);
        Zobject.setValue('EffectiveDate', System.now());
        Zobject.setValue('UpdatedDate', System.now());
        Zobject.setValue('Status', 'Active');
        Zobject.setValue('Type','RemoveProduct');
        Zobject.setValue('Code','Amend-'+ I);
        Zobjects.add(zobject);
    }
}Else If (objectName == 'RatePlan') {
    For (Integer I = 0; I < 10; i++) {
        Zuora.zobject zobject = new Zuora.zObject('RatePlan');
        Zobject.setValue('Name', 'RatePlan | Test | ' + I);
        Zobjects.add(zobject);
    }
    For (Integer I = 0; I < 10; i++) {
        Zuora.zobject zobject = new Zuora.zObject('RatePlan');
        Zobject.setValue('Name', 'RatePlan | Test 2 | ' + I);
        Zobject.setValue('AmendmentType','RemoveProduct');
        Zobjects.add(zobject);
    }
}Else If (objectName == 'RatePlanCharge') {
    For (Integer I = 0; I < 10; i++) {
        Zuora.zobject zobject = new Zuora.zObject('RatePlanCharge');
        Zobject.setValue('Name', 'RatePlanCharge | Test | ' + I);
         Zobject.setValue('EffectiveStartDate', System.now());
         Zobject.setValue('EffectiveEndDate', System.now());
         Zobject.setValue('ChargeNumber', 'Test Charge ' + I);
         Zobject.setValue('ChargeType', 'Recurring');
          Zobject.setValue('IsLastSegment', true);
        string RecordName = 'TestProdGeo' + I;
        string RecordId = '';
        Integer x = [SELECT COUNT()  FROM MetroclientProductGeography__c  where name = :RecordName ];
        if(x==1)
            RecordId = [SELECT Id FROM MetroclientProductGeography__c  where name = :RecordName  Limit 1 ].Id;
         Zobject.setValue('Record_Id__c', RecordId );    
        Zobjects.add(zobject);
    }
}Else If (objectName == 'Subscription') {
    For (Integer I = 0; I < 10; i++) {
       Zuora.zobject zobject = new Zuora.zObject('Subscription');
       Zobject.setValue('Name', 'Test Subscription ' + I);
        Zobject.setValue('Status', 'Active');
       Zobjects.add(zobject);
    }
}




Return zobjects;
}



}