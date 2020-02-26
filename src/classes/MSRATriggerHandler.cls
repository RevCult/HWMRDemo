/****************************************************************************************************
*Description:       Trigger Handler class for MetrostudySalesRegionAssignment

*Revision   |Date          |Author             |AdditionalNotes
*====================================================================================================
*   1.0     6-April-2016   Akash Pandey      When Employee field in the Metrostudy Sales Region Assignment
                                             object is updated, it needs to update the RD_Name_for_Dashboard_Filter__c
                                             field on Account.
                                             
* Test Class - MSRATriggerHandler_test     
*****************************************************************************************************/
public with sharing class MSRATriggerHandler implements ITrigger{
    public MSRATriggerHandler(){}
    public void bulkBefore(){}
    public void bulkAfter(){}
    public void beforeInsert(){}
    public void beforeUpdate(){}
    public void beforeDelete(){}
    public void afterInsert(){}
    public void afterUpdate(){
        updateAccountOnChangeOfEmployee();
    }
    public void afterDelete(){}
    public void afterUnDelete(){}
    public void andFinally(){} 
    
/*----------------------------------------Service Methods-----------------------------------------------------*/
    public void updateAccountOnChangeOfEmployee(){
        Set<Id> msRegions=new Set<Id>();
        for(MetrostudySalesRegionAssignment__c msra:(List<MetrostudySalesRegionAssignment__c>)trigger.new){
            if(((Map<Id,MetrostudySalesRegionAssignment__c>)trigger.oldMap).containsKey(msra.id) && ((Map<Id,MetrostudySalesRegionAssignment__c>)trigger.oldMap).get(msra.id).User__c != msra.User__c){
                msRegions.add(msra.SalesRegion__c);
            }
        }
        if(msRegions.size()>0){
            Map<Id,String> serviceMap=new Map<Id,String>();
            for(MetrostudySalesRegionAssignment__c msra1:[select SalesRegion__c,user__r.name from MetrostudySalesRegionAssignment__c where SalesRegion__c in:msRegions]){
                serviceMap.put(msra1.SalesRegion__c,msra1.user__r.name);
            }
            List<Account> accList=[select id,Metrostudy_Sales_Region_Assignment_RD__r.SalesRegion__c,RD_Name_for_Dashboard_Filter__c from account where Metrostudy_Sales_Region_Assignment_RD__r.SalesRegion__c in:msRegions];
            for(Account a:accList){
                a.RD_Name_for_Dashboard_Filter__c=serviceMap.get(a.Metrostudy_Sales_Region_Assignment_RD__r.SalesRegion__c);
            }
            update accList;
        }
    }       
}