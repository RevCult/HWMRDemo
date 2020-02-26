trigger Status on Zonda_Contract__c (after insert, after update) {
   List<Contract_User_Group_Association__c> association = new List<Contract_User_Group_Association__c>();
    
   // get the related groups for the contracts in this trigger
   Map<Id, sObject> contractsWithGrps = new Map<Id,sObject>(
       [Select Id, (Select Id From Contract_User_Group_Associations__r) From Zonda_Contract__c 
        Where Id IN :Trigger.New]);
    
   //List<Zonda_User_Group__c> grpList = new List <Zonda_User_Group__c>();
   //Map <Id, Name> groups = new Map<Id, Name> ([Select ID, (Select Id From Zonda_User_Group__c Where ID in (Select Id From Contract_User_Group_Associations__r)) From Zonda_Contract__c Where Id IN :Trigger.New])
    
}