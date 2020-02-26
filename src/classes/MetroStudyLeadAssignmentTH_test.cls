/*******************************************************************************************************************
** Module Name   : MetroStudyLeadAssignmentTH_test
** Description   : Test class for MetroStudyLeadAssignmentTriggerHandler
** Throws        : NA
** Calls         : NA
** 
** Organization  : Rainmaker
**
** Revision History:-
** Version             Date            Author           Description of Action
** 1.0                 06/28/16        Rainmaker             
******************************************************************************************************************/
@isTest
private class MetroStudyLeadAssignmentTH_test{
    @testSetup static void testData() {
        MetrostudySalesRegion__c msr=new MetrostudySalesRegion__c(Abbreviation__c='test',User_DNU__c=userinfo.getUserId());
        insert msr;
        system.assert(msr.id != null);
        
        MetrostudySalesRegionAssignment__c msra=new MetrostudySalesRegionAssignment__c(SalesRegion__c=msr.id, Role__c = 'DBD', User__c=UserInfo.getuserId());
        insert msra;
        system.assert(msra.id != null);
        
        MetrostudySalesRegionAssignment__c msra2=new MetrostudySalesRegionAssignment__c(SalesRegion__c=msr.id, Role__c = 'RD', User__c=UserInfo.getuserId());
        insert msra2;
        system.assert(msra2.id != null);
        
        MetroclientGeographyType__c MGType = new MetroclientGeographyType__c(GeographyTypeId__c=12345);
        Insert MGType;
        system.assert(MGType.Id != null);
        
        MetroclientGeography__c MGObj = new MetroclientGeography__c(Name='Test Geo', SalesRegion__c=msr.Id,GeographyType__c=MGType.Id);
        Insert MGObj;
        System.assert(MGObj.Id != null);
        
        MetrostudyMarket__c MMObj = new MetrostudyMarket__c(Name='Test Market', Geography__c=MGObj.Id);
        Insert MMObj;
        System.assert(MMObj.id != null);
        
        Metrostudy_ZIP_Code__c ZCObj = new Metrostudy_ZIP_Code__c(Name='12345', Metrostudy_Market__c=MMObj.id);
        Insert ZCObj;
        System.assert(ZCObj.Id != null);
        
        Lead L = new Lead(Firstname='Test', LastName='Lead', Email='Test@lead.com', Company='Test',PostalCode='12345',
                          How_may_we_help_you__c='Training Request', Industry = 'Accounting', LeadSource = 'MS_BriefingAttendee');
        Insert L;
        System.assert(L.Id != null);
    }
    
    static testMethod void testMethod1(){
        Lead L = [select Id, FirstName FROM Lead LIMIT 1];
        L.FirstName = 'Test1';
        update L;
        delete L;
        
        Lead L2 = new Lead(Firstname='Test2', LastName='Lead2', Email='Test@lead.com', Company='Test',PostalCode='12345',
                          How_may_we_help_you__c='Download White Paper', Industry = 'Accounting', LeadSource = 'MS_BriefingAttendee');
        Insert L2;
        System.assert(L2.Id != null);
        
        L2.Firstname='Test3';
        update L2;
        delete L2;
    }
}