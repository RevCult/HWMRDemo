public with sharing class FC_DelManualAgreementController {
    
    public echosign_dev1__SIGN_Agreement__c clientAgreement{get;set;}

    public FC_DelManualAgreementController(ApexPages.StandardController stdController) {
    
         this.clientAgreement = (echosign_dev1__SIGN_Agreement__c) stdController.getRecord();
    
    }

     public PageReference selectPage(){

        String returnUrl;
        Map<String, String> parameterListing = apexpages.currentpage().getparameters();
        Set<string> keys = parameterListing.keySet();
        if(keys.contains('retURL')){
            String parentId = apexpages.currentpage().getparameters().get('retURL');
            returnUrl = '/' + parentId;
        }
        if(keys.contains('delID')){
            delete this.clientAgreement;
        }

        PageReference pgRef = new PageReference(returnUrl);

        pgRef.setRedirect(true);

        return pgRef;

    }
}