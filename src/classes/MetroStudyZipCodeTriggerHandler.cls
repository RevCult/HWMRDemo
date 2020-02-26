/****************************************************************************************************
*Description:       Trigger Handler class for MetroStudyZipCode

*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0     6-Jan-2016   Akash Pandey         
*****************************************************************************************************/

public with sharing class MetroStudyZipCodeTriggerHandler implements ITrigger{
    
    public MetroStudyZipCodeTriggerHandler(){}
    public void bulkBefore(){}
    public void bulkAfter(){}
    public void beforeInsert(){}
    public void beforeUpdate(){}
    public void beforeDelete(){}
    public void afterInsert(){
        updateAccountOnChangeOfMetroStudyMarket();
    }
    public void afterUpdate(){
        updateAccountOnChangeOfMetroStudyMarket();
    }
    public void afterDelete(){}
    public void afterUnDelete(){}
    public void andFinally(){}
    
    
/*-----------Service Methods-------------*/    
    
    public void updateAccountOnChangeOfMetroStudyMarket(){
        Set<String> zipcodes=new Set<String>();
        for(Metrostudy_ZIP_Code__c mzc:(List<Metrostudy_ZIP_Code__c>)trigger.new){
            zipcodes.add(mzc.name);    
        }
        if(zipcodes.size()>0){
            //if([select count() from Account where Strategic_Account__c=false AND shippingPostalCode in:zipcodes]>200){
                //Database.executeBatch(new MetroStudyZipCodeUpdateBatch(zipcodes));
           // }else{
                updateAccountOnChangeOfMetroStudyMarketFUTURE(zipcodes);
           // }
        }  
    }
    public static void updateAccountOnChangeOfMetroStudyMarketFUTURE(Set<String> zipcodes){
        system.debug('The zipcodes are ' + zipcodes);
        
        String Criteria = '';
         for(String zipcode : zipcodes){
            if(Criteria == ''){
                Criteria = 'shippingPostalCode like \''+zipcode +'%\' ';
            }
            else{
                Criteria += ' OR shippingPostalCode like \''+zipcode +'%\' ';
            }
        }
        system.debug('The criteria is ' + Criteria );
        Map<String,List<Account>> accountwithZIP=new Map<String,List<Account>>();
        String str = 'select id,Metrostudy_Sales_Region_Assignment_DBD__c,Metrostudy_Sales_Region_Assignment_RD__c,shippingPostalCode from account where Strategic_Account__c=false AND ('+Criteria+')';
        system.debug('The string is ' + str);
        for(Account a:database.query('select id,Metrostudy_Sales_Region_Assignment_DBD__c,Metrostudy_Sales_Region_Assignment_RD__c,shippingPostalCode from account where Strategic_Account__c=false AND ('+Criteria+')')){
            //accountwithZIP.put(a.shippingPostalCode,a);
             if(!accountwithZIP.containsKey(a.shippingPostalCode.substringBefore('-')))
                accountwithZIP.put(a.shippingPostalCode.substringBefore('-'),new List<Account>());
            accountwithZIP.get(a.shippingPostalCode.substringBefore('-')).add(a);
        }
        
        Map<String,List<String>> servicemap2=new Map<String,List<String>>();
        if(zipCodes.size()>0){
            //System.assert(false,[select Name,Metrostudy_Market__r.Geography__c,Metrostudy_Market__r.Geography__r.SalesRegion__c from Metrostudy_ZIP_Code__c where name in:zipCodes]);
            for(Metrostudy_ZIP_Code__c mzc:[select Name,Metrostudy_Market__r.Geography__c,Metrostudy_Market__r.Geography__r.SalesRegion__c from Metrostudy_ZIP_Code__c where name in:zipCodes]){
                
                if(mzc.Metrostudy_Market__c!=null && mzc.Metrostudy_Market__r.Geography__c!=null && mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c!=null){
                    if(!servicemap2.containsKey(mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c)){
                        servicemap2.put(mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c,new List<String>());
                    }
                    servicemap2.get(mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c).add(mzc.name);
                }
            }
        }
        Map<String,List<MetrostudySalesRegionAssignment__c>> finalServiceMap=new Map<String,List<MetrostudySalesRegionAssignment__c>>(); 
        if(servicemap2.size()>0){
            for(MetrostudySalesRegionAssignment__c msra:[select id,SalesRegion__c,User__r.name,Role__c from MetrostudySalesRegionAssignment__c  where SalesRegion__c in:serviceMap2.KeySet()]){
                if(servicemap2.containsKey(msra.SalesRegion__c)){
                    for(String key:servicemap2.get(msra.SalesRegion__c)){
                        if(!finalServiceMap.containsKey(key)){
                            finalServiceMap.put(key,new List<MetrostudySalesRegionAssignment__c>());
                        }
                        finalServiceMap.get(key).add(msra);
                    }
                }
            }
         }
            system.debug('Final service map is ' + finalServiceMap);
            List<Account> accsToBeUpdated = new List<Account>();
            system.debug('size of service map' + finalServiceMap.size());
            for(List<Account> acc:accountwithZIP.values()){
                for(Account a: acc){
                     a.Metrostudy_Sales_Region_Assignment_DBD__c = null;
                    a.Metrostudy_Sales_Region_Assignment_RD__c = null;
                    a.RD_Name_for_Dashboard_Filter__c = '';
                    
                    if(finalServiceMap.containsKey(a.shippingPostalCode.substringBefore('-'))){
                        for(MetrostudySalesRegionAssignment__c msra:finalServiceMap.get(a.shippingPostalCode.substringBefore('-'))){
                            
                            if(msra.Role__c=='DBD'){
                                a.Metrostudy_Sales_Region_Assignment_DBD__c=msra.id;
                            }
                            if(msra.Role__c=='RD'){
                                a.Metrostudy_Sales_Region_Assignment_RD__c=msra.id;
                                a.RD_Name_for_Dashboard_Filter__c=msra.User__r.name;
                            }
                            
                        }
                    }
                    accsToBeUpdated.add(a);
                }
            }
            if(accsToBeUpdated.size()>0)
                upsert accsToBeUpdated;
    }
}