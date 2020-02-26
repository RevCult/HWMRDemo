@isTest
private class TestAccounttype {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        Account accnt = new Account();
        accnt.name='test1';
        accnt.type='prospect';
        accnt.Industry='Banking';
        accnt.BillingPostalCode='590009';
        insert accnt;
        
        Zonda_Contract__c zoncon = new Zonda_Contract__c();
        zoncon.Name='contracttest';
        zoncon.Subscription_End_Date__c = date.today()+30;
        zoncon.RSD__c=u.id;
        zoncon.Contract_Creation_Date__c = date.today()-5;
        zoncon.Account__c=accnt.id;
        zoncon.Role_s__c='Sales & Marketing';
        zoncon.contract_status__c='Expired';
        insert zoncon;
        
        zoncon.contract_status__c='Active';
       update zoncon;
    }
}