public with sharing class AccountRD_DBDUpdate {
    public static void executeAccountRD_DBDUpdate(List<Account> newAcc) {
        Set<String> zipCodes = new Set<String>();
        for (Account a : newAcc) {
            //if(!a.Strategic_Account__c){
            if (a.shippingPostalCode != null)
                zipCodes.add(a.shippingPostalCode.substringBefore('-'));
            //}
        }
        Map<String, List<String>> serviceMap1 = new Map<String, List<String>>();
        if (zipCodes.size() > 0) {
            for (Metrostudy_ZIP_Code__c mzc : [select Name,Metrostudy_Market__r.Geography__c,Metrostudy_Market__r.Geography__r.SalesRegion__c from Metrostudy_ZIP_Code__c where name in:zipCodes]) {
                if (mzc.Metrostudy_Market__c != null && mzc.Metrostudy_Market__r.Geography__c != null && mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c != null) {
                    if (!serviceMap1.containsKey(mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c))
                        serviceMap1.put(mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c, new List<String>());
                    serviceMap1.get(mzc.Metrostudy_Market__r.Geography__r.SalesRegion__c).add(mzc.name);
                }
            }
        }
        Map<String, List<MetrostudySalesRegionAssignment__c>> finalServiceMap = new Map<String, List<MetrostudySalesRegionAssignment__c>>();
        if (serviceMap1.size() > 0) {
            for (MetrostudySalesRegionAssignment__c msra : [select id,SalesRegion__c,User__r.name,Role__c from MetrostudySalesRegionAssignment__c where SalesRegion__c in:serviceMap1.keySet()]) {
                if (serviceMap1.containsKey(msra.SalesRegion__c)) {
                    for (String key : serviceMap1.get(msra.SalesRegion__c)) {
                        if (!finalServiceMap.containsKey(key)) {
                            finalServiceMap.put(key, new List<MetrostudySalesRegionAssignment__c>());
                        }
                        finalServiceMap.get(key).add(msra);
                    }
                }
            }
        }
        if (finalServiceMap.size() > 0) {
            for (Account a : newAcc) {
                if (!a.Strategic_Account__c) {
                    a.Metrostudy_Sales_Region_Assignment_DBD__c = null;
                }
                a.Metrostudy_Sales_Region_Assignment_RD__c = null;
                a.RD_Name_for_Dashboard_Filter__c = '';
                if (a.shippingPostalCode != null) {
                    if (finalServiceMap.containsKey(a.shippingPostalCode.substringBefore('-'))) {
                        for (MetrostudySalesRegionAssignment__c msra : finalServiceMap.get(a.shippingPostalCode.substringBefore('-'))) {
                            if (!a.Strategic_Account__c) {
                                if (msra.Role__c == 'DBD') {
                                    a.Metrostudy_Sales_Region_Assignment_DBD__c = msra.id;
                                }
                            }
                            if (msra.Role__c == 'RD') {
                                a.Metrostudy_Sales_Region_Assignment_RD__c = msra.id;
                                a.RD_Name_for_Dashboard_Filter__c = msra.User__r.name;
                            }
                        }
                    }
                }
            }
        }
    }
}