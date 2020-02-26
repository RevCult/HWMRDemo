@isTest
class MetrostudyTest{
    @testSetup
    static void creatingTest(){
        MetroclientGeographyType__c mgt=new MetroclientGeographyType__c(name='Market',GeographyTypeId__c=4392);
        insert mgt;
        /*---------------record chain 1--------------------------------------*/
             
        MetrostudySalesRegion__c msr=new MetrostudySalesRegion__c(name='test');
        insert msr;
        MetrostudySalesRegionAssignment__c msraRD=new MetrostudySalesRegionAssignment__c(Name='testRD',Role__c='RD',SalesRegion__c=msr.id,User__c=userinfo.getUserId());
        insert msraRD;
        MetrostudySalesRegionAssignment__c msraDBD=new MetrostudySalesRegionAssignment__c(Name='testDBD',Role__c='DBD',SalesRegion__c=msr.id,User__c=userinfo.getUserId());
        insert msraDBD;
        MetroclientGeography__c mg=new MetroclientGeography__c(name='test',GeographyType__c=mgt.id,SalesRegion__c=msr.id);
        insert mg;
        MetrostudyMarket__c mm=new MetrostudyMarket__c(name='test',Geography__c=mg.id,MarketCode__c='IND');
        insert mm;
        Metrostudy_ZIP_Code__c mzip=new Metrostudy_ZIP_Code__c(Metrostudy_Market__c=mm.id,name='302004');
        insert mzip;
        
        /*---------------record chain 2 --------------------------------------*/
        
        MetrostudySalesRegion__c msr1=new MetrostudySalesRegion__c(name='test1');
        insert msr1;
        MetrostudySalesRegionAssignment__c msraRD1=new MetrostudySalesRegionAssignment__c(Name='test1RD',Role__c='RD',SalesRegion__c=msr1.id,User__c=userinfo.getUserId());
        insert msraRD1;
        MetrostudySalesRegionAssignment__c msraDBD1=new MetrostudySalesRegionAssignment__c(Name='test1DBD',Role__c='DBD',SalesRegion__c=msr1.id,User__c=userinfo.getUserId());
        insert msraDBD1;
        MetroclientGeography__c mg1=new MetroclientGeography__c(name='test1',GeographyType__c=mgt.id,SalesRegion__c=msr1.id);
        insert mg1;
        MetrostudyMarket__c mm1=new MetrostudyMarket__c(name='test1',Geography__c=mg1.id,MarketCode__c='INI');
        insert mm1;
        Metrostudy_ZIP_Code__c mzip1=new Metrostudy_ZIP_Code__c(Metrostudy_Market__c=mm1.id,name='302005');
        insert mzip1;
        
        
    }
    static testMethod void StrategicAccountTrigger_Test(){
        Account a=new Account(name='test',shippingpostalcode='302004', BillingPostalCode = '12345');
        insert a;
    }
    static testMethod void MetroStudyZipCodeTrigger_Test(){
        Account a=new Account(name='test',shippingpostalcode='302004', BillingPostalCode = '12345');
        insert a;
        List<Metrostudy_ZIP_Code__c> mzc=[select id from Metrostudy_ZIP_Code__c ];
        update mzc;
        MetroStudyZipCodeTriggerHandler mzcth=new MetroStudyZipCodeTriggerHandler();
        mzcth.bulkBefore();
        mzcth.beforeInsert();
        mzcth.beforeUpdate();
        mzcth.beforeDelete();
        mzcth.afterDelete();
        mzcth.afterUnDelete();
    }
    static testMethod void MetroStudyZipCodeBatch_Test(){
        Account a=new Account(name='test',shippingpostalcode='302004', BillingPostalCode = '12345');
        insert a;
        Account a1=new Account(name='test',shippingpostalcode='302005', BillingPostalCode = '12345');
        insert a1;
        Database.executeBatch(new MetroStudyZipCodeBatch([select createddate from Metrostudy_ZIP_Code__c][0].createddate),100);
    }
    
}