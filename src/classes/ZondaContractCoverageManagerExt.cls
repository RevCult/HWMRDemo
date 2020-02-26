public with sharing class ZondaContractCoverageManagerExt {

    private Zonda_Contract__c theContract;
    public String updatedCoverage {get; set;}
    public String updatedCoverageRegion {get; set;}
    public String updatedCoverageName {get; set;}

    public ZondaContractCoverageManagerExt(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new String[]{'Coverage_String__c'});
        }
        theContract = (Zonda_Contract__c)stdController.getRecord();
        updatedCoverage = theContract.Coverage_String__c;
        //updatedCoverageRegion = theContract.Coverage_Region__c; // Do not include this here. It causes an error in the VF page
        system.debug(updatedCoverage);
        system.debug(updatedCoverageRegion);
        system.debug('CoverageRegionName: '+updatedCoverageName);

    }

    public PageReference apexUpdateCoverage() {
        system.debug('theContract.Coverage_String__c: '+theContract.Coverage_String__c);
        system.debug('updatedCoverage: '+updatedCoverage);
        system.debug('CoverageRegion: '+updatedCoverageRegion);
        system.debug('CoverageRegionName: '+updatedCoverageName);
        
        theContract.Coverage_String__c = updatedCoverage;
        //theContract.Coverage_Region__c = updatedCoverageRegion;
        theContract.Coverage_Region_String__c = updatedCoverageRegion;
        theContract.County_Names__c = updatedCoverageName;
        update theContract;
        //return new PageReference('/'+theContract.Id);
        return null;
    }
    
    //public PageReference apexUpdateCoverageRegion() {
    //    system.debug('theContract.Coverage_Region__c: '+theContract.Coverage_Region__c);
    //    system.debug('updatedCoverageRegion: '+updatedCoverageRegion);
    //    theContract.Coverage_Region__c = updatedCoverageRegion;
    //    update theContract;
        //return new PageReference('/'+theContract.Id);
    //    return null;
    //}
}