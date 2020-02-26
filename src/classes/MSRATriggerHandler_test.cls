@isTest
class MSRATriggerHandler_test {
    static testMethod void m1(){
        MetrostudySalesRegion__c msr=new MetrostudySalesRegion__c(Abbreviation__c='test',User_DNU__c=userinfo.getUserId());
        insert msr;
        MetrostudySalesRegionAssignment__c msra=new MetrostudySalesRegionAssignment__c(SalesRegion__c=msr.id);
        insert msra;
        Account a=new Account(name='test',Metrostudy_Sales_Region_Assignment_RD__c=msra.id, BillingPostalCode = '12345');
        insert a;
        msra.User__c=userinfo.getUserId();
        upsert msra;
        MSRATriggerHandler msrat=new MSRATriggerHandler();
        msrat.bulkBefore();
        msrat.bulkAfter();
        msrat.beforeInsert();
        msrat.beforeUpdate();
        msrat.beforeDelete();
        msrat.afterInsert();
        msrat.afterDelete();
        msrat.afterUnDelete();
        msrat.andFinally();
    }
}