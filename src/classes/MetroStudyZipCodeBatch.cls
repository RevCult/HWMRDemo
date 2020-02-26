/****************************************************************************************************
*Description:       MetroStudyZipCode batch

*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0     7-April-2016   Akash Pandey         
*****************************************************************************************************/

public class MetroStudyZipCodeBatch implements Database.Batchable<sObject>,Database.stateful {
    public final datetime tempdatetime;
    public MetroStudyZipCodeBatch(datetime tempdatetime){
        this.tempdatetime=tempdatetime;
    }
    public  Iterable<SObject> start(Database.BatchableContext BC) {
        List<Metrostudy_ZIP_Code__c> returnResult = [SELECT Id,Metrostudy_Market__c,Name FROM Metrostudy_ZIP_Code__c WHERE CreatedDate >=:tempdatetime];
        return returnResult;
    }
    public void execute(Database.BatchableContext BC, List<Metrostudy_ZIP_Code__c> scope){
        
        List<String> zipcodes = new List<String>();
        for(Metrostudy_ZIP_Code__c zipcode : scope){
            zipcodes.add(zipcode.name);
        }
        String Criteria = '';
         for(String zipcode : zipcodes){
            if(Criteria == ''){
                Criteria = 'shippingPostalCode like \''+zipcode +'%\' ';
            }
            else{
                Criteria += ' OR shippingPostalCode like \''+zipcode +'%\' ';
            }
        }
        system.debug('The zipcodes are ' + zipcodes + 'size ' + zipcodes.size());
        Map<String,List<Account>> accountwithZIP=new Map<String,List<Account>>();
         for(Account a:database.query('select id,Metrostudy_Sales_Region_Assignment_DBD__c,Metrostudy_Sales_Region_Assignment_RD__c,shippingPostalCode from account where Strategic_Account__c=false AND ('+Criteria+')')){
            //accountwithZIP.put(a.shippingPostalCode,a);
            
            if(!accountwithZIP.containsKey(a.shippingPostalCode.substringBefore('-')))
                accountwithZIP.put(a.shippingPostalCode.substringBefore('-'),new List<Account>());
            accountwithZIP.get(a.shippingPostalCode.substringBefore('-')).add(a);
        }
        
        //Map<String,Account> accountwithZIP=new Map<String,Account>();
        //for(Account a:scope){
        //    accountwithZIP.put(a.shippingPostalCode,a);
        //}
        Map<String,List<String>> serviceMap1=new Map<String,List<String>>();
        for(Metrostudy_ZIP_Code__c mzc:[select Metrostudy_Market__r.Geography__c,Name,Metrostudy_Market__r.Geography__r.SalesRegion__c from Metrostudy_ZIP_Code__c where name in:accountwithZIP.keySet()]){
            if(mzc.Metrostudy_Market__c!=null && mzc.Metrostudy_Market__r.Geography__c!=null && mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c!=null){
                if(!serviceMap1.containsKey(mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c))
                    serviceMap1.put(mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c,new List<String>());
                serviceMap1.get(mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c).add(mzc.name);
            }
        }
        system.debug('size of service map' + serviceMap1.size());
        Map<String,List<MetrostudySalesRegionAssignment__c>> finalServiceMap=new Map<String,List<MetrostudySalesRegionAssignment__c>>(); 
        if(serviceMap1.size()>0){
            for(MetrostudySalesRegionAssignment__c msra:[select id,SalesRegion__c,User__r.name,Role__c from MetrostudySalesRegionAssignment__c  where SalesRegion__c in:serviceMap1.keySet()]){
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
            List<Account> accsToBeUpdated = new List<Account>();
            system.debug('size of service map' + finalServiceMap.size());
            for(List<Account> acc:accountwithZIP.values()){
                for(Account a: acc){
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
    public void finish(Database.BatchableContext BC){}
}