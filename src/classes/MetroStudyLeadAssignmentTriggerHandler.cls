/*******************************************************************************************************************
** Module Name   : MetroStudyLeadAssignmentTriggerHandler
** Description   : Handler class for MSLeadAssignment trigger
** Throws        : NA
** Calls         : NA
** Test Class    : MetroStudyLeadAssignmentTH_test
** 
** Organization  : Rainmaker
**
** Revision History:-
** Version             Date            Author           Description of Action
** 1.0                 06/20/16        Rainmaker             
******************************************************************************************************************/

public with sharing class MetroStudyLeadAssignmentTriggerHandler implements ITrigger{
    
    public MetroStudyLeadAssignmentTriggerHandler(){}
    public void bulkBefore(){}
    public void bulkAfter(){}
    public void beforeInsert(){
       
        
    }
    public void beforeUpdate(){
        /* Commented as we only need to check this on Insert 
        if(Utility.IsLeadUpdate){
            updateLeadAssignment();
        }
        */
    }
    public void beforeDelete(){}
    public void afterInsert(){
    
     // use Utility.IsFromLeadInsert in update logic and set this to false
       if(Utility.IsFromLeadInsert){
            updateLeadAssignment();
        }
        
    }
    public void afterUpdate(){
    
        
       
    }
    public void afterDelete(){}
    public void afterUnDelete(){}
    public void andFinally(){}
    
    
/*-----------Service Methods-------------*/    
    
    public void updateLeadAssignment(){
        try{
            Set<String> zipCodeSet = new Set<String>();
            List<Lead> leadDBDList = new List<Lead>();
            List<Lead> leadRDList = new List<Lead>();
            //Map<String,Lead> zipCodesDBD=new Map<String,Lead>();
            //Map<String,Lead> zipCodesRD=new Map<String,Lead>();
            Map<String,Lead> LeadMap = new Map<String,Lead>();
            
            List<RecordType> MktIntelRecordType = [select id from RecordType where sObjecttype = 'Lead' AND  DeveloperName = 'Market_Intelligence_Lead_Record_Type' limit 1];
            Default_LeadOwner_MetroStudy__c defaultLeadOwner = Default_LeadOwner_MetroStudy__c.getValues('DefaultLeadOwner');        
            
           for(Lead L : (List<Lead>)trigger.new){
                LeadMap.put(L.Id, null);
            }
            
            if(LeadMap.size()>0){
                for(Lead L : [select Id, Name, RecordTypeId, How_may_we_help_you__c, LeadSource, Industry, postalCode, OwnerId FROM Lead WHERE Id in: LeadMap.keyset()]){
                    LeadMap.put(L.Id, L);
                }
            }
            
            if(LeadMap.size() > 0){
                for(Lead leadObj : LeadMap.values()){
                    system.debug('The how we may help you is ' + leadObj.How_may_we_help_you__c + 'Industry ' + leadObj.Industry + 'Lead Source ' + leadObj.leadsource);
                    if(MktIntelRecordType != null && MktIntelRecordType[0] != null && leadObj.RecordTypeId == MktIntelRecordType[0].id && leadObj.LeadSource != null && (leadObj.LeadSource.startsWith('MS_') ||leadObj.LeadSource == 'Jigsaw')  && (leadObj.LeadSource != 'MS_Marketing_Newsletter')  && leadObj.Industry != 'Building Product Manufacturer'){
                        //if(leadObj.How_may_we_help_you__c != 'Training Request' && leadObj.How_may_we_help_you__c != 'Media Request' && leadObj.How_may_we_help_you__c != 'Customer Support/Training Request' && leadObj.How_may_we_help_you__c != 'Billing Questions' && leadObj.How_may_we_help_you__c != 'Speakers Bureau Information' && leadObj.How_may_we_help_you__c != 'Contact a Local Market Expert' && leadObj.How_may_we_help_you__c != 'Technical Support'){
                        system.debug('The how we may help you is ' + leadObj.How_may_we_help_you__c + 'Industry ' + leadObj.Industry );
                        if(leadObj.How_may_we_help_you__c == null || leadObj.How_may_we_help_you__c == 'Purchase Information/Reports' || leadObj.How_may_we_help_you__c == 'Consulting/Market Study' || leadObj.How_may_we_help_you__c == 'Have a Sales Representative Contact Me' || leadObj.How_may_we_help_you__c == 'General Information' || leadObj.How_may_we_help_you__c == 'Other' || leadObj.How_may_we_help_you__c == 'Become a Member'){
                            zipCodeSet.add(leadobj.postalCode.substringBefore('-'));
                            leadDBDList.add(leadObj);
                            //zipCodesDBD.put(leadobj.postalCode.substringBefore('-'),leadObj);
                            
                        }
                        else if(leadObj.How_may_we_help_you__c == 'Training Request' || leadObj.How_may_we_help_you__c == 'Billing Questions' || leadObj.How_may_we_help_you__c == 'Speakers Bureau Information' || leadObj.How_may_we_help_you__c == 'Contact a Local Market Expert' || leadObj.How_may_we_help_you__c == 'Technical Support'){
                            //zipCodesRD.put(leadobj.postalCode.substringBefore('-'),leadObj);
                            zipCodeSet.add(leadobj.postalCode.substringBefore('-'));
                            leadRDList.add(leadObj);
                        }
                    }
                }
            }
            
            Map<String,List<String>> serviceMap1=new Map<String,List<String>>();
            if(zipCodeSet.size()>0){
                for(Metrostudy_ZIP_Code__c mzc:[select Name,Metrostudy_Market__r.Geography__c,Metrostudy_Market__r.Geography__r.SalesRegion__c from Metrostudy_ZIP_Code__c where name in:zipcodeSet]){
                    if(mzc.Metrostudy_Market__c!=null && mzc.Metrostudy_Market__r.Geography__c!=null && mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c!=null){
                        if(!serviceMap1.containsKey(mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c))
                            serviceMap1.put(mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c,new List<String>());
                        serviceMap1.get(mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c).add(mzc.name);
                    }
                }
            }
            Map<String,List<MetrostudySalesRegionAssignment__c>> finalServiceMap=new Map<String,List<MetrostudySalesRegionAssignment__c>>(); 
            if(serviceMap1.size()>0){
                for(MetrostudySalesRegionAssignment__c msra:[select id,SalesRegion__c,User__c,Role__c from MetrostudySalesRegionAssignment__c  where SalesRegion__c in:serviceMap1.keySet()]){
                    if(serviceMap1.containsKey(msra.SalesRegion__c)){
                        for(String key:serviceMap1.get(msra.SalesRegion__c)){
                            if(!finalServiceMap.containsKey(key)){
                                finalServiceMap.put(key,new List<MetrostudySalesRegionAssignment__c>());
                            }
                            finalServiceMap.get(key).add(msra);
                        }
                    }
                }
            }
            List<Lead> updateLeadList = new List<Lead>();
            if(finalServiceMap.size()>0){
                for(Lead leadObj: leadDBDList){
                    if(leadObj.PostalCode != null){
                        if(finalServiceMap.containsKey(leadObj.PostalCode.substringBefore('-'))){
                            for(MetrostudySalesRegionAssignment__c msra:finalServiceMap.get(leadObj.PostalCode.substringBefore('-'))){
                                if(msra.Role__c=='DBD'){
                                    if(msra.User__c != null)
                                        leadObj.OwnerId = msra.User__c;
                                    else{
                                        if(defaultLeadOwner != null && defaultLeadOwner.UserID__c !=null)
                                            leadObj.OwnerId = defaultLeadOwner.UserID__c; 
                                    }
                                    updateLeadList.add(leadObj);
                                }
                            }
                        }
                    }  
                }
                for(Lead leadObj: leadRDList){
                    if(leadObj.PostalCode != null){
                        if(finalServiceMap.containsKey(leadObj.PostalCode.substringBefore('-'))){
                            for(MetrostudySalesRegionAssignment__c msra:finalServiceMap.get(leadObj.PostalCode.substringBefore('-'))){
                                if(msra.Role__c=='RD'){
                                    if(msra.User__c != null)
                                        leadObj.OwnerId = msra.User__c;
                                    else{
                                        if(defaultLeadOwner != null && defaultLeadOwner.UserID__c !=null)
                                            leadObj.OwnerId = defaultLeadOwner.UserID__c; 
                                    }
                                    updateLeadList.add(leadObj);
                                }
                            }
                        }
                    }  
                }
            }
            
            if(updateLeadList.size() > 0){
                Utility.IsFromLeadInsert = false;
                update updateLeadList;
            }
        }
        catch(Exception e){
            system.debug(' ==== MetroStudyLeadAssignmentTriggerHandler ====> '+e.getLineNumber()+' == '+e.getMessage());
        }
    }  
}