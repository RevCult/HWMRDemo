/**
 * Created by pete on 1/7/16.
 */

@IsTest
private class TestAdminToolDataMaintenance {
    @testSetup static void setUpData() {
        // Need some Zonda Contracts
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

        // Need some Contract/User Group Associations
        List<Contract_User_Group_Association__c> junctions = new List<Contract_User_Group_Association__c>();
        for (Integer i=0; i<5; i++) {
            junctions.add(new Contract_User_Group_Association__c(
                    Zonda_Contract__c = contracts[i].Id,
                    Zonda_User_Group__c = userGroups[i].Id
            ));
        }
        insert junctions;
    }

    static testMethod void validateInserts() {
        List<Zonda_User_Group__c> allUserGroups = [SELECT Id, Coverage_String__c FROM Zonda_User_Group__c];
        for (Zonda_User_Group__c userGroup : allUserGroups) {
            system.assertEquals(userGroup.Coverage_String__c, 'ABC');
        }
    }

    static testMethod void testContractUpdates() {
        Zonda_Contract__c aContract = [SELECT Id, Coverage_String__c FROM Zonda_Contract__c LIMIT 1];
        Contract_User_Group_Association__c aJunction = [SELECT Id, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_Contract__c = :aContract.Id LIMIT 1];
        Zonda_User_Group__c theUserGroup = [SELECT Id, Coverage_String__c FROM Zonda_User_Group__c WHERE Id = :aJunction.Zonda_User_Group__c LIMIT 1];
        system.assertEquals(theUserGroup.Coverage_String__c, 'ABC');
        Test.startTest();
            aContract.Coverage_String__c = 'BCD';
            update aContract;
        Test.stopTest();
        theUserGroup = [SELECT Id, Coverage_String__c FROM Zonda_User_Group__c WHERE Id = :aJunction.Zonda_User_Group__c LIMIT 1];
        system.assertEquals(theUserGroup.Coverage_String__c, 'BCD');
    }

    static testMethod void testJunctionInsert() {
        Zonda_Contract__c aContract = [SELECT Id, Coverage_String__c FROM Zonda_Contract__c LIMIT 1];
        Zonda_Contract__c bContract = [SELECT Id, Coverage_String__c FROM Zonda_Contract__c WHERE Id != :aContract.Id LIMIT 1];
        Contract_User_Group_Association__c aJunction = [SELECT Id, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_Contract__c = :aContract.Id LIMIT 1];
        Zonda_User_Group__c theUserGroup = [SELECT Id, Coverage_String__c FROM Zonda_User_Group__c WHERE Id = :aJunction.Zonda_User_Group__c LIMIT 1];
        system.assertEquals(theUserGroup.Coverage_String__c, 'ABC');
        Test.startTest();
            Contract_User_Group_Association__c newJunction = new Contract_User_Group_Association__c(
                    Zonda_Contract__c = bContract.Id,
                    Zonda_User_Group__c = theUserGroup.Id
            );
            insert newJunction;
            update newJunction;
        Test.stopTest();
        theUserGroup = [SELECT Id, Coverage_String__c FROM Zonda_User_Group__c WHERE Id = :aJunction.Zonda_User_Group__c LIMIT 1];
        system.assertEquals(theUserGroup.Coverage_String__c, 'ABC|ABC');
    }
}