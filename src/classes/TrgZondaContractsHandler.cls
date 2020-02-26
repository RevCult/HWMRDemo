/**
 * Created by pete on 1/7/16.
 */

public with sharing class TrgZondaContractsHandler {
    // If any of the User Groups don't have any active Zonda Contracts, and its status is not already "Expired", update them to "Expired"
    public static void handleExpiredContracts(String triggerContext, List<Zonda_Contract__c> triggerNew, Map<Id, Zonda_Contract__c> triggerNewMap, List<Zonda_Contract__c> triggerOld, Map<Id, Zonda_Contract__c> triggerOldMap) {
        Map<Id, Zonda_Contract__c> newlyExpiredContracts = new Map<Id, Zonda_Contract__c>();

        for (Zonda_Contract__c zc : triggerNew) {
            if (zc.Contract_Status__c == 'Expired') {
                newlyExpiredContracts.put(zc.Id, zc);
            }
        }

        if (newlyExpiredContracts.isEmpty()) return; // none of the contracts being updated or created are set to expired

        // If the Zonda Contract's status is set to expired, go find all the User Groups associated to it
        List<Contract_User_Group_Association__c> junctions = new List<Contract_User_Group_Association__c>();
        junctions = [SELECT Id, Zonda_Contract__c, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_Contract__c IN :newlyExpiredContracts.keySet()];

        if (junctions.isEmpty()) return; // none of the newly expired contracts have any user groups associated to them

        // For each of the newly expired contracts' User Groups - go check all the OTHER contracts on the User Group - if none of them are Active, then set the User Group to Expired
        Set<Id> distinctUserGroupIds = new Set<Id>();
        for (Contract_User_Group_Association__c junction : junctions) {
            distinctUserGroupIds.add(junction.Zonda_User_Group__c);
        }

        // get all the usergroups
        Map<Id, Zonda_User_Group__c> allUserGroups = new Map<Id, Zonda_User_Group__c>([SELECT Id, Status__c FROM Zonda_User_Group__c WHERE Id IN :distinctUserGroupIds]);
        // get all the contract associations for the user groups
        List<Contract_User_Group_Association__c> userGroupJunctions = [SELECT Id, Zonda_Contract__c, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_User_Group__c IN :distinctUserGroupIds];
        // get all the contracts for those associations into a Map
        Set<Id> distinctUserGroupContractIds = new Set<Id>();
        for (Contract_User_Group_Association__c junction : userGroupJunctions) {
            distinctUserGroupContractIds.add(junction.Zonda_Contract__c);
        }
        Map<Id, Zonda_Contract__c> allContracts = new Map<Id, Zonda_Contract__c>([SELECT Id, Contract_Status__c FROM Zonda_Contract__c WHERE Id IN :distinctUserGroupContractIds]);
        // build a map from userGroup to Contracts
        Map<Zonda_User_Group__c, List<Zonda_Contract__c>> mapUserGroupToContracts = new Map<Zonda_User_Group__c, List<Zonda_Contract__c>>();
        for (Contract_User_Group_Association__c junction : userGroupJunctions) {
            if (!mapUserGroupToContracts.containsKey(allUserGroups.get(junction.Zonda_User_Group__c))) {
                mapUserGroupToContracts.put(allUserGroups.get(junction.Zonda_User_Group__c), new List<Zonda_Contract__c>());
            }
            mapUserGroupToContracts.get(allUserGroups.get(junction.Zonda_User_Group__c)).add(allContracts.get(junction.Zonda_Contract__c));
        }
        // loop over the usergroups, then the contracts - if none are Active, set the usergroup to Expired
        List<Zonda_User_Group__c> userGroupsToUpdate = new List<Zonda_User_Group__c>();
        for (Zonda_User_Group__c userGroup : mapUserGroupToContracts.keySet()) {
            Boolean allContractsAreInactive = true;
            for (Zonda_Contract__c contract : mapUserGroupToContracts.get(userGroup)) {
                if (contract.Contract_Status__c == 'Active') {
                    allContractsAreInactive = false;
                }
            }
            if (allContractsAreInactive) {
                userGroup.Status__c = 'Expired';
                userGroupsToUpdate.add(userGroup);
            }
        }

        update userGroupsToUpdate;
    }

    public static void handleCanceledContracts(String triggerContext, List<Zonda_Contract__c> triggerNew, Map<Id, Zonda_Contract__c> triggerNewMap, List<Zonda_Contract__c> triggerOld, Map<Id, Zonda_Contract__c> triggerOldMap) {
        Map<Id, Zonda_Contract__c> newlyCanceledContracts = new Map<Id, Zonda_Contract__c>();

        for (Zonda_Contract__c zc : triggerNew) {
            if (zc.Contract_Status__c == 'Canceled') {
                newlyCanceledContracts.put(zc.Id, zc);
            }
        }

        if (newlyCanceledContracts.isEmpty()) return; // none of the contracts being updated or created are set to canceled

        // If the Zonda Contract's status is set to canceled, go find all the User Groups associated to it
        List<Contract_User_Group_Association__c> junctions = new List<Contract_User_Group_Association__c>();
        junctions = [SELECT Id, Zonda_Contract__c, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_Contract__c IN :newlyCanceledContracts.keySet()];

        if (junctions.isEmpty()) return; // none of the newly canceled contracts have any user groups associated to them

        // For each of the newly canceled contracts' User Groups - go check all the OTHER contracts on the User Group - if none of them are Active, then set the User Group to Canceled
        Set<Id> distinctUserGroupIds = new Set<Id>();
        for (Contract_User_Group_Association__c junction : junctions) {
            distinctUserGroupIds.add(junction.Zonda_User_Group__c);
        }

        // get all the usergroups
        Map<Id, Zonda_User_Group__c> allUserGroups = new Map<Id, Zonda_User_Group__c>([SELECT Id, Status__c FROM Zonda_User_Group__c WHERE Id IN :distinctUserGroupIds]);
        // get all the contract associations for the user groups
        List<Contract_User_Group_Association__c> userGroupJunctions = [SELECT Id, Zonda_Contract__c, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_User_Group__c IN :distinctUserGroupIds];
        // get all the contracts for those associations into a Map
        Set<Id> distinctUserGroupContractIds = new Set<Id>();
        for (Contract_User_Group_Association__c junction : userGroupJunctions) {
            distinctUserGroupContractIds.add(junction.Zonda_Contract__c);
        }
        Map<Id, Zonda_Contract__c> allContracts = new Map<Id, Zonda_Contract__c>([SELECT Id, Contract_Status__c FROM Zonda_Contract__c WHERE Id IN :distinctUserGroupContractIds]);
        // build a map from userGroup to Contracts
        Map<Zonda_User_Group__c, List<Zonda_Contract__c>> mapUserGroupToContracts = new Map<Zonda_User_Group__c, List<Zonda_Contract__c>>();
        for (Contract_User_Group_Association__c junction : userGroupJunctions) {
            if (!mapUserGroupToContracts.containsKey(allUserGroups.get(junction.Zonda_User_Group__c))) {
                mapUserGroupToContracts.put(allUserGroups.get(junction.Zonda_User_Group__c), new List<Zonda_Contract__c>());
            }
            mapUserGroupToContracts.get(allUserGroups.get(junction.Zonda_User_Group__c)).add(allContracts.get(junction.Zonda_Contract__c));
        }
        // loop over the usergroups, then the contracts - if none are Active, set the usergroup to Expired
        List<Zonda_User_Group__c> userGroupsToUpdate = new List<Zonda_User_Group__c>();
        for (Zonda_User_Group__c userGroup : mapUserGroupToContracts.keySet()) {
            Boolean allContractsAreInactive = true;
            for (Zonda_Contract__c contract : mapUserGroupToContracts.get(userGroup)) {
                if (contract.Contract_Status__c == 'Active') {
                    allContractsAreInactive = false;
                }
            }
            if (allContractsAreInactive) {
                userGroup.Status__c = 'Canceled';
                userGroupsToUpdate.add(userGroup);
            }
        }

        update userGroupsToUpdate;
    }
}