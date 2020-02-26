/**
 * Created by pete on 1/7/16.
 */

@IsTest
public class TestZondaContractsTrigger {

    @testSetup static void setUpData() {
        // Need some Zonda Contracts
        Account accnte = new Account();
        accnte.name='test1';
        accnte.type='prospect';
        accnte.Industry='Banking';
        accnte.BillingPostalCode='500029';
        insert accnte;
        
        List<Zonda_Contract__c> contracts = new List<Zonda_Contract__c>();
        for (Integer i = 0; i<5; i++) {
            contracts.add(new Zonda_Contract__c(
                    Name = 'Contract '+i
                   // Account__c=accnte.id
            ));
        }
        insert contracts;

        // Need some Zonda User Groups
        List<Zonda_User_Group__c> userGroups = new List<Zonda_User_Group__c>();
        for (Integer i = 0; i<5; i++) {
            userGroups.add(new Zonda_User_Group__c(
                    Name = 'User Group '+i,
                    Coverage_String__c= '06065'+i
               //   Coverage_String__c = 06065|06071;
            ));
           
        }
        insert userGroups;

        // Need some Contract/User Group Associations
        List<Contract_User_Group_Association__c> junctions = new List<Contract_User_Group_Association__c>();
        for (Integer i=0; i<5; i++) {
            junctions.add(new Contract_User_Group_Association__c(
                    Zonda_Contract__c = contracts[i].Id,
                    Zonda_User_Group__c = userGroups[i].Id
            ));
        }
        insert junctions;
        
      /*  Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        Account accnt = new Account();
        accnt.name='test1';
        accnt.type='prospect';
        accnt.Industry='Banking';
        insert accnt;
        
        Zonda_Contract__c zoncon = new Zonda_Contract__c();
        zoncon.Name='contracttest';
        zoncon.Subscription_End_Date__c = date.today()+30;
        zoncon.RSD__c=u.id;
        zoncon.Contract_Creation_Date__c = date.today()-5;
        zoncon.Account__c=accnt.id;
        zoncon.Role_s__c='Sales & Marketing';
        zoncon.contract_status__c='Expired';
        insert zoncon;*/
    }

    static testMethod void testExpiredContracts() {
        List<Zonda_User_Group__c> expiredUserGroups = [SELECT Id,Coverage_String__c  FROM Zonda_User_Group__c WHERE Status__c = 'Expired'];
        List<Zonda_User_Group__c> notExpiredUserGroups = [SELECT Id,Coverage_String__c  FROM Zonda_User_Group__c WHERE Status__c != 'Expired'];

        system.assertEquals(expiredUserGroups.size(), 0);
        system.assertEquals(notExpiredUserGroups.size(), 5);

        Test.startTest();
            List<Zonda_Contract__c> contracts = [SELECT Id, Contract_Status__c FROM Zonda_Contract__c];

            for (Zonda_Contract__c contract : contracts) {
                contract.Contract_Status__c = 'Expired';
            }

            update contracts;
        Test.stopTest();

        expiredUserGroups = [SELECT Id,Coverage_String__c  FROM Zonda_User_Group__c WHERE Status__c = 'Expired'];
        notExpiredUserGroups = [SELECT Id,Coverage_String__c  FROM Zonda_User_Group__c WHERE Status__c != 'Expired'];

        system.assertEquals(expiredUserGroups.size(), 5);
        system.assertEquals(notExpiredUserGroups.size(), 0);
    }

    static testMethod void testCanceledContracts() {
        List<Zonda_User_Group__c> canceledUserGroups = [SELECT Id,Coverage_String__c  FROM Zonda_User_Group__c WHERE Status__c = 'Canceled'];
        List<Zonda_User_Group__c> notCanceledUserGroups = [SELECT Id,Coverage_String__c  FROM Zonda_User_Group__c WHERE Status__c != 'Canceled'];

        system.assertEquals(canceledUserGroups.size(), 0);
        system.assertEquals(notCanceledUserGroups.size(), 5);

        Test.startTest();
        List<Zonda_Contract__c> contracts = [SELECT Id, Contract_Status__c FROM Zonda_Contract__c];

        for (Zonda_Contract__c contract : contracts) {
            contract.Contract_Status__c = 'Canceled';
        }

        update contracts;
        Test.stopTest();

        canceledUserGroups = [SELECT Id,Coverage_String__c  FROM Zonda_User_Group__c WHERE Status__c = 'Canceled'];
        notCanceledUserGroups = [SELECT Id,Coverage_String__c  FROM Zonda_User_Group__c WHERE Status__c != 'Canceled'];

        system.assertEquals(canceledUserGroups.size(), 5);
        system.assertEquals(notCanceledUserGroups.size(), 0);
    }
     static testMethod void testZondaContractCoverageManagerExt() {
         List<Zonda_Contract__c> contracts = [SELECT Id,Coverage_String__c, Contract_Status__c FROM Zonda_Contract__c];
         Zonda_Contract__c cont = [SELECT Id, Coverage_String__c,Contract_Status__c FROM Zonda_Contract__c limit 1];
         ApexPages.StandardController sc = new ApexPages.StandardController(cont);
        ZondaContractCoverageManagerExt de = new ZondaContractCoverageManagerExt(sc);
        de.apexUpdateCoverage();
     
     }
     
     static testMethod void testZondaContractCoverageManagerViewOnly() {
         List<Zonda_User_Group__c > contracts = [SELECT Id,Coverage_String__c FROM Zonda_User_Group__c];
         Zonda_User_Group__c cont = [SELECT Id,Coverage_String__c FROM Zonda_User_Group__c limit 1];
         ApexPages.StandardController scw = new ApexPages.StandardController(cont);
        ZondaContractCoverageManagerViewOnlyExt deonly = new ZondaContractCoverageManagerViewOnlyExt(scw);
        deonly.updatedCoverage='test';
        deonly.apexUpdateCoverage();
     
     }
     
     
     
}