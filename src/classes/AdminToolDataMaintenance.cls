/**
 * Created by pete on 1/7/16.
 */

public with sharing class AdminToolDataMaintenance {

    /**
        SFDC-40
        When a Contract - User Group are linked and the contract is Active the coverage string needs to be passed down to the User Group from all associated contracts.
        If there are multiple contracts associated with a user group the coverage strings need to be combined.
        This will need to update when Coverage changes, Contract status changes, Contract Associations change...etc.
        Zonda_Contract__c.Coverage_String__c  --> Zonda_User_Group__c.Coverage_String__c
        The User Group information will be imported into the DB

        SFDC-50 (added 04.04.2016)
        1. Concatenate the distinct list of roles from all Contracts the User Group has associated
        2. If any of the Contracts associated with the User Group has the check box checked check the user group check box, else the check box on the User Group is unchecked
        3. Concatenate the distinct list of RSD emails from all Contracts the User Group has associated
     */

    public static void updateFieldsOnUserGroups(List<Zonda_Contract__c> contracts) {
        List<Contract_User_Group_Association__c> junctions = new List<Contract_User_Group_Association__c>();
        junctions = [SELECT Id, Zonda_Contract__c, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_Contract__c IN :contracts];
        if (!junctions.isEmpty()) {
            updateFieldsOnUserGroups(junctions);
        }
    }

    public static void updateFieldsOnUserGroups(List<Contract_User_Group_Association__c> junctions) {

        // get all the usergroups into memory
        Set<Id> distinctUserGroupIds = new Set<Id>();
        for (Contract_User_Group_Association__c junction : junctions) {
            distinctUserGroupIds.add(junction.Zonda_User_Group__c);
        }

        Map<Id, Zonda_User_Group__c> allUserGroups = new Map<Id, Zonda_User_Group__c>([SELECT Id, Status__c, Coverage_String__c, Role_s__c, Zonda_Pro__c, RSD_Email__c FROM Zonda_User_Group__c WHERE Id IN :distinctUserGroupIds]);
        // get all the contract associations for the user groups
        List<Contract_User_Group_Association__c> userGroupJunctions = [SELECT Id, Zonda_Contract__c, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_User_Group__c IN :distinctUserGroupIds];
        // get all the contracts for those associations into a Map
        Set<Id> distinctUserGroupContractIds = new Set<Id>();
        for (Contract_User_Group_Association__c junction : userGroupJunctions) {
            distinctUserGroupContractIds.add(junction.Zonda_Contract__c);
        }
        Map<Id, Zonda_Contract__c> allContracts = new Map<Id, Zonda_Contract__c>([SELECT Id, Coverage_String__c, Contract_Status__c, Role_s__c, Zonda_Pro__c, RSD_Email__c FROM Zonda_Contract__c WHERE Id IN :distinctUserGroupContractIds]);
        // build a map from userGroup to Contracts
        Map<Zonda_User_Group__c, List<Zonda_Contract__c>> mapUserGroupToContracts = new Map<Zonda_User_Group__c, List<Zonda_Contract__c>>();
        for (Contract_User_Group_Association__c junction : userGroupJunctions) {
            if (!mapUserGroupToContracts.containsKey(allUserGroups.get(junction.Zonda_User_Group__c))) {
                mapUserGroupToContracts.put(allUserGroups.get(junction.Zonda_User_Group__c), new List<Zonda_Contract__c>());
            }
            mapUserGroupToContracts.get(allUserGroups.get(junction.Zonda_User_Group__c)).add(allContracts.get(junction.Zonda_Contract__c));
        }
        // loop over the usergroups, then the contracts - if the Contract is Active, make sure the userGroup has its coverage string
        List<Zonda_User_Group__c> userGroupsToUpdate = new List<Zonda_User_Group__c>();
        for (Zonda_User_Group__c userGroup : mapUserGroupToContracts.keySet()) {
            String userGroupCoverageString = '';
            Set<String> distinctRolesForUserGroup = new Set<String>();
            Set<String> distinctRSDEmailsForUserGroup = new Set<String>();
            Boolean zondaPro = false;
            for (Zonda_Contract__c contract : mapUserGroupToContracts.get(userGroup)) {
                if (contract.Contract_Status__c == 'Active') {
                    if (userGroupCoverageString.length() != 0 && !userGroupCoverageString.endsWith('|')) {
                        userGroupCoverageString += '|';
                    }
                    userGroupCoverageString += contract.Coverage_String__c;

                    // if the contract has the role(s) field set, add all the values to the distinct set of strings
                    if (contract.Role_s__c != null) {
                        distinctRolesForUserGroup.addAll(contract.Role_s__c.split(';'));
                    }

                    // if the contract has the RSD Email field set, add the value to the distinct set of strings
                    if (contract.RSD_Email__c != null) {
                        distinctRSDEmailsForUserGroup.add(contract.RSD_Email__c);
                    }

                    // if zondaPro is still false - see if this contract has it checked and if it does - update the placeholder variable
                    if (!zondaPro) {
                        zondaPro = contract.Zonda_Pro__c;
                    }
                }
            }

            userGroup.Coverage_String__c = userGroupCoverageString;
            // take all the distinct RSD Emails from the Contracts and string them together with semi-colons for the user group
            userGroup.RSD_Email__c = String.join(new List<String>(distinctRSDEmailsForUserGroup), ';');
            // take all the distinct Role(s) from the Contracts and string them together with semi-colons for the user group
            userGroup.Role_s__c = String.join(new List<String>(distinctRolesForUserGroup), ';');
            // set the user group's Zonda Pro checkbox to the culmination of all the contracts' checkboxes (if all false, then false, otherwise true)
            userGroup.Zonda_Pro__c = zondaPro;
            // update da groups baby!
            userGroupsToUpdate.add(userGroup);
        }

        update userGroupsToUpdate;
    }

  ///**
  //   RSDs are set at the contract level and emails are passed to the User Groups
  //   */
  //  public static void updateRSDs(List<Zonda_Contract__c> contracts) {
  //      List<Contract_User_Group_Association__c> associations = new List<Contract_User_Group_Association__c>();
  //      associations = [SELECT Id, Zonda_Contract__c, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_Contract__c IN :contracts];
  //      if (!associations.isEmpty()) {
  //          updateRSDs(associations);
  //      }
  //  }

  //  public static void updateRSDs(List<Contract_User_Group_Association__c> associations) {

  //      // get all the usergroups into memory
  //      Set<Id> distinctUserGroupIds = new Set<Id>();
  //      for (Contract_User_Group_Association__c junction : associations) {
  //          distinctUserGroupIds.add(junction.Zonda_User_Group__c);
  //      }

  //      Map<Id, Zonda_User_Group__c> allUserGroups = new Map<Id, Zonda_User_Group__c>([SELECT Id, Status__c, RSD_Email__c FROM Zonda_User_Group__c WHERE Id IN :distinctUserGroupIds]);
  //      // get all the contract associations for the user groups
  //      List<Contract_User_Group_Association__c> userGroupAssociations = [SELECT Id, Zonda_Contract__c, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_User_Group__c IN :distinctUserGroupIds];
  //      // get all the contracts for those associations into a Map
  //      Set<Id> distinctUserGroupContractIds = new Set<Id>();
  //      for (Contract_User_Group_Association__c junction : userGroupAssociations) {
  //          distinctUserGroupContractIds.add(junction.Zonda_Contract__c);
  //      }
  //      Map<Id, Zonda_Contract__c> allContracts = new Map<Id, Zonda_Contract__c>([SELECT Id, RSD_Email__c, Contract_Status__c FROM Zonda_Contract__c WHERE Id IN :distinctUserGroupContractIds]);
  //      // build a map from userGroup to Contracts
  //      Map<Zonda_User_Group__c, List<Zonda_Contract__c>> mapUserGroupToContracts = new Map<Zonda_User_Group__c, List<Zonda_Contract__c>>();
  //      for (Contract_User_Group_Association__c junction : userGroupAssociations) {
  //          if (!mapUserGroupToContracts.containsKey(allUserGroups.get(junction.Zonda_User_Group__c))) {
  //              mapUserGroupToContracts.put(allUserGroups.get(junction.Zonda_User_Group__c), new List<Zonda_Contract__c>());
  //          }
  //          mapUserGroupToContracts.get(allUserGroups.get(junction.Zonda_User_Group__c)).add(allContracts.get(junction.Zonda_Contract__c));
  //      }
  //      // loop over the usergroups, then the contracts - if the Contract is Active, make sure the userGroup has its RSD email
  //      List<Zonda_User_Group__c> userGroupsToUpdate = new List<Zonda_User_Group__c>();
  //      for (Zonda_User_Group__c userGroup : mapUserGroupToContracts.keySet()) {
  //          String userGroupRSDemail = '';
  //          for (Zonda_Contract__c contract : mapUserGroupToContracts.get(userGroup)) {
  //              if (contract.Contract_Status__c == 'Active') {
  //                  if (userGroupRSDemail.length() != 0) {
  //                      userGroupRSDemail += '; ';
  //                  }
  //                  userGroupRSDemail += contract.RSD_Email__c;
  //              }
  //          }

  //          userGroup.RSD_Email__c = userGroupRSDemail;
  //          userGroupsToUpdate.add(userGroup);

  //      }

  //      update userGroupsToUpdate;
  //  }

  ///**
  //      Roles are set at the contract level and are passed to the User Groups
  //   */
  //  public static void updateRoles(List<Zonda_Contract__c> contracts) {
  //      List<Contract_User_Group_Association__c> associations = new List<Contract_User_Group_Association__c>();
  //      associations = [SELECT Id, Zonda_Contract__c, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_Contract__c IN :contracts];
  //      if (!associations.isEmpty()) {
  //          updateRoles(associations);
  //      }
  //  }

  //  public static void updateRoles(List<Contract_User_Group_Association__c> associations) {

  //      // get all the usergroups into memory
  //      Set<Id> distinctUserGroupIds = new Set<Id>();
  //      for (Contract_User_Group_Association__c junction : associations) {
  //          distinctUserGroupIds.add(junction.Zonda_User_Group__c);
  //      }

  //      Map<Id, Zonda_User_Group__c> allUserGroups = new Map<Id, Zonda_User_Group__c>([SELECT Id, Status__c, Role_s__c FROM Zonda_User_Group__c WHERE Id IN :distinctUserGroupIds]);
  //      // get all the contract associations for the user groups
  //      List<Contract_User_Group_Association__c> userGroupAssociations = [SELECT Id, Zonda_Contract__c, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_User_Group__c IN :distinctUserGroupIds];
  //      // get all the contracts for those associations into a Map
  //      Set<Id> distinctUserGroupContractIds = new Set<Id>();
  //      for (Contract_User_Group_Association__c junction : userGroupAssociations) {
  //          distinctUserGroupContractIds.add(junction.Zonda_Contract__c);
  //      }
  //      Map<Id, Zonda_Contract__c> allContracts = new Map<Id, Zonda_Contract__c>([SELECT Id, Role_s__c, Contract_Status__c FROM Zonda_Contract__c WHERE Id IN :distinctUserGroupContractIds]);
  //      // build a map from userGroup to Contracts
  //      Map<Zonda_User_Group__c, List<Zonda_Contract__c>> mapUserGroupToContracts = new Map<Zonda_User_Group__c, List<Zonda_Contract__c>>();
  //      for (Contract_User_Group_Association__c junction : userGroupAssociations) {
  //          if (!mapUserGroupToContracts.containsKey(allUserGroups.get(junction.Zonda_User_Group__c))) {
  //              mapUserGroupToContracts.put(allUserGroups.get(junction.Zonda_User_Group__c), new List<Zonda_Contract__c>());
  //          }
  //          mapUserGroupToContracts.get(allUserGroups.get(junction.Zonda_User_Group__c)).add(allContracts.get(junction.Zonda_Contract__c));
  //      }
  //      // loop over the usergroups, then the contracts - if the Contract is Active, make sure the userGroup has its Role(s)
  //      List<Zonda_User_Group__c> userGroupsToUpdate = new List<Zonda_User_Group__c>();
  //      for (Zonda_User_Group__c userGroup : mapUserGroupToContracts.keySet()) {
  //          String userGroupRSDemail = '';
  //          for (Zonda_Contract__c contract : mapUserGroupToContracts.get(userGroup)) {
  //              if (contract.Contract_Status__c == 'Active') {
  //                  if (userGroupRSDemail.length() != 0) {
  //                      userGroupRSDemail += '; ';
  //                  }
  //                  userGroupRSDemail += contract.Role_s__c;
  //              }
  //          }

  //          userGroup.Role_s__c = userGroupRSDemail;
  //          userGroupsToUpdate.add(userGroup);

  //      }

  //      update userGroupsToUpdate;
  //  }

    ///**
    //    SFDC-50
    //    1. Concatenate the distinct list of roles from all Contracts the User Group has associated
    //    2. If any of the Contracts associated with the User Group has the check box checked check the user group check box, else the check box on the User Group is unchecked
    //    3. Concatenate the distinct list of RSD emails from all Contracts the User Group has associated
    //*/
    //public static void updateFieldsOnUserGroups(List<Zonda_Contract__c> contracts) {
    //    List<Contract_User_Group_Association__c> associations = new List<Contract_User_Group_Association__c>();
    //    associations = [SELECT Id, Zonda_Contract__c, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_Contract__c IN :contracts];
    //    if (!associations.isEmpty()) {
    //        updateFieldsOnUserGroups(associations);
    //    }
    //}

    //public static void updateFieldsOnUserGroups(List<Contract_User_Group_Association__c> associations) {
    //    // get all the usergroups into memory
    //    Set<Id> distinctUserGroupIds = new Set<Id>();
    //    for (Contract_User_Group_Association__c junction : associations) {
    //        distinctUserGroupIds.add(junction.Zonda_User_Group__c);
    //    }

    //    Map<Id, Zonda_User_Group__c> allUserGroups = new Map<Id, Zonda_User_Group__c>([SELECT Id, Status__c, Role_s__c FROM Zonda_User_Group__c WHERE Id IN :distinctUserGroupIds]);
    //    // get all the contract associations for the user groups
    //    List<Contract_User_Group_Association__c> userGroupAssociations = [SELECT Id, Zonda_Contract__c, Zonda_User_Group__c FROM Contract_User_Group_Association__c WHERE Zonda_User_Group__c IN :distinctUserGroupIds];
    //    // get all the contracts for those associations into a Map
    //    Set<Id> distinctUserGroupContractIds = new Set<Id>();
    //    for (Contract_User_Group_Association__c junction : userGroupAssociations) {
    //        distinctUserGroupContractIds.add(junction.Zonda_Contract__c);
    //    }
    //    Map<Id, Zonda_Contract__c> allContracts = new Map<Id, Zonda_Contract__c>([SELECT Id, Role_s__c, Contract_Status__c FROM Zonda_Contract__c WHERE Id IN :distinctUserGroupContractIds]);
    //    // build a map from userGroup to Contracts
    //    Map<Zonda_User_Group__c, List<Zonda_Contract__c>> mapUserGroupToContracts = new Map<Zonda_User_Group__c, List<Zonda_Contract__c>>();
    //    for (Contract_User_Group_Association__c junction : userGroupAssociations) {
    //        if (!mapUserGroupToContracts.containsKey(allUserGroups.get(junction.Zonda_User_Group__c))) {
    //            mapUserGroupToContracts.put(allUserGroups.get(junction.Zonda_User_Group__c), new List<Zonda_Contract__c>());
    //        }
    //        mapUserGroupToContracts.get(allUserGroups.get(junction.Zonda_User_Group__c)).add(allContracts.get(junction.Zonda_Contract__c));
    //    }
    //    // loop over the usergroups, then the contracts - if the Contract is Active, make sure the userGroup has its Role(s)
    //    List<Zonda_User_Group__c> userGroupsToUpdate = new List<Zonda_User_Group__c>();
    //    for (Zonda_User_Group__c userGroup : mapUserGroupToContracts.keySet()) {
    //        String userGroupRSDemail = '';
    //        for (Zonda_Contract__c contract : mapUserGroupToContracts.get(userGroup)) {
    //            if (contract.Contract_Status__c == 'Active') {
    //                if (userGroupRSDemail.length() != 0) {
    //                    userGroupRSDemail += '; ';
    //                }
    //                userGroupRSDemail += contract.Role_s__c;
    //            }
    //        }

    //        userGroup.Role_s__c = userGroupRSDemail;
    //        userGroupsToUpdate.add(userGroup);

    //    }

    //    update userGroupsToUpdate;
    //}

 }
 


    //system.debug(contract.Zonda_Pro__c);
                //system.debug(userGroupZondaPro+'is this all ?');
                //Boolean result = userGroupZondaPro.contains('true');
                //System.debug('O/p will be true as it contains the String and Output is: '+result );
                //if (contains(userGroupZondaPro,'true'));
                // {
                //    system.debug('What');
                //}


                    //new Set<zondaPro>()
                    //set zondaPro mySet = new set zondaPro();
                    
                    //Set<String> s = new Set<String>{userGroupZondaProSetting};
                    //s.addAll(contract.Zonda_Pro__c);
                    //system.debug(userGroupZondaPro);
                    //system.debug(s.Zonda_Pro__c);
                    //if (s.contains('%true%')) {
                    //    system.debug('What');
                    //} else {
                    //    system.debug('nope');
                    //} 


                    //userGroupZondaPro += contract.Zonda_Pro__c;


                    //IF(contains(userGroupZondaPro, true), true, false)


                    //if (contains(userGroupZondaPro, true) == TRUE) {
                    //    userGroupZondaPro += true;
                    //}    

                    //    userGroupZondaProSetting += true;
                    //    system.debug(userGroupZondaProSetting+ '  here 1');
                    //} else {
                    //    userGroupZondaProSetting += false;
                    //    system.debug(userGroupZondaProSetting+ '  here 2');
                    //}


                    //userGroupZondaPro += contract.Zonda_Pro__c;
                    //system.debug(contract.Zonda_Pro__c);
                   // system.debug(userGroupZondaProSetting+ '  here 3');
                //}