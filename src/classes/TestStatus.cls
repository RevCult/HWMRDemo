@isTest
private class TestStatus{
static testMethod void myUnitTest() { 

List<Zonda_Contract__c> contracts = new List<Zonda_Contract__c>();
        for (Integer i = 0; i<5; i++) {
            contracts.add(new Zonda_Contract__c(
                    Name = 'Contract '+i,
                    Coverage_String__c = 'ABC'
            ));
        }
        insert contracts;

        // Need some Zonda User Groups
        List<Zonda_User_Group__c> userGroups = new List<Zonda_User_Group__c>();
        for (Integer i = 0; i<5; i++) {
            userGroups.add(new Zonda_User_Group__c(
                    Name = 'User Group '+i
            ));
        }
        insert userGroups;

List<Contract_User_Group_Association__c> junctions = new List<Contract_User_Group_Association__c>();
for (Integer i=0; i<5; i++) {
            junctions.add(new Contract_User_Group_Association__c(
                    Zonda_Contract__c = contracts[i].Id,
                    Zonda_User_Group__c = userGroups[i].Id
            ));
        }
        insert junctions;
 }
 }