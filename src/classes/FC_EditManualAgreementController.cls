public with sharing class FC_EditManualAgreementController {
    
    public echosign_dev1__SIGN_Agreement__c clientAgreement{get;set;}
    private ApexPages.StandardController scController;
    public String returnUrl {get;set;}

    public FC_EditManualAgreementController(ApexPages.StandardController stdController) {

        scController = stdController;
        Map<String, String> parameterListing = apexpages.currentpage().getparameters();
        Set<string> keys = parameterListing.keySet();
        if(keys.contains('retURL')){
            String parentId = apexpages.currentpage().getparameters().get('retURL');
            this.returnUrl = '/' + parentId;
        }

        echosign_dev1__SIGN_Agreement__c  ecdObject = (echosign_dev1__SIGN_Agreement__c) stdController.getRecord();

        this.clientAgreement = [Select Id, FC_Manual_EchoSign__c,echosign_dev1__Account__c, Name,echosign_dev1__Status__c,echosign_dev1__Recipient2__c,echosign_dev1__Opportunity__c,Quote__c,echosign_dev1__SignatureType__c,echosign_dev1__DateSigned__c,echosign_dev1__AgreementLocale__c From echosign_dev1__SIGN_Agreement__c where id = :ecdObject.Id];

    }

    public PageReference selectPage(){

        PageReference pgRef  = null;

        if(!this.clientAgreement.FC_Manual_EchoSign__c){

            String url = '/apex/echosign_dev1__EchoSignAgreementAdvanced?retURL=' + this.returnUrl;
            pgRef = new PageReference(url);
            pgRef.setRedirect(true);

        }

        return pgRef;

    }

    public PageReference save(){

        update this.clientAgreement;

        System.debug('-- ' + returnUrl);
        PageReference pgRef = new PageReference(this.returnUrl);

        pgRef.setRedirect(true);

        return pgRef;
    }

    public PageReference cancel(){

            return scController.cancel();

    }

}