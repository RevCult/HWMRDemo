public with sharing class ZondaContractCoverageManagerViewOnlyExt {

    private Zonda_User_Group__c theCoverage;
    public String updatedCoverage {get; set;}

    public ZondaContractCoverageManagerViewOnlyExt(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new String[]{'Coverage_String__c'});
        }
        theCoverage = (Zonda_User_Group__c)stdController.getRecord();
        system.debug('Test'+theCoverage);
        updatedCoverage = theCoverage.Coverage_String__c;
        system.debug(updatedCoverage);
    }

    public PageReference apexUpdateCoverage() {
        system.debug('theCoverage.Coverage_String__c: '+theCoverage.Coverage_String__c);
        system.debug('updatedCoverage: '+updatedCoverage);
        theCoverage.Coverage_String__c = updatedCoverage;
        update theCoverage;
        //return new PageReference('/'+theCoverage.Id);
        return null;
    }
}