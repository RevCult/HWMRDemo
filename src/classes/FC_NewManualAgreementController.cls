public with sharing class FC_NewManualAgreementController {

    public Boolean isOpportunity;

    public String returnUrl {get;set;}

    public echosign_dev1__SIGN_Agreement__c clientAgreement{get;set;}

    public Attachment agreementDocument {get; set;}

    public FC_NewManualAgreementController() {
    

        Map<String, String> parameterListing = apexpages.currentpage().getparameters();
        Set<string> keys = parameterListing.keySet();
        Id oppId, quoteId;
        this.clientAgreement = new  echosign_dev1__SIGN_Agreement__c();
        this.clientAgreement.echosign_dev1__SignatureType__c = 'Written Signature';
        this.clientAgreement.FC_Manual_EchoSign__c = true;
        this.clientAgreement.echosign_dev1__Status__c = 'Signed';
        this.clientAgreement.echosign_dev1__DateSigned__c = datetime.now();
        if(keys.contains('opportunityId')){
            this.isOpportunity = true;
            oppId = apexpages.currentpage().getparameters().get('opportunityId');
            this.clientAgreement.echosign_dev1__Opportunity__c = oppId;
            List<Opportunity> oppList = [Select Id, AccountId, Name from Opportunity where id = :oppId ];

            this.clientAgreement.echosign_dev1__Account__c = oppList[0].AccountId;
            //this.clientAgreement.Name =  oppList[0].Name;
            returnUrl = '/' + oppId;
        }
        if(keys.contains('quoteId')){
            this.isOpportunity = false;
            quoteId = apexpages.currentpage().getparameters().get('quoteId');
            List<zqu__Quote__c> quoteList = [Select Id, zqu__Opportunity__c, zqu__Account__c,zqu__BillToContact__c, Name from zqu__Quote__c where id = :quoteId ];
            this.clientAgreement.echosign_dev1__Account__c = quoteList[0].zqu__Account__c;
            //this.clientAgreement.Name =  quoteList[0].Name;
            this.clientAgreement.echosign_dev1__Opportunity__c = quoteList[0].zqu__Opportunity__c;
            this.clientAgreement.echosign_dev1__Recipient2__c = quoteList[0].zqu__BillToContact__c;

            this.clientAgreement.Quote__c = quoteId;
            returnUrl =  '/' + quoteId;
        }
        
    }

    public void createDocument(){
        Attachment att = new Attachment();
        att.OwnerId = UserInfo.getUserId();
        this.agreementDocument = att;
    } 

    public PageReference save(){

        if(String.isBlank(this.clientAgreement.Name) ){
            this.clientAgreement.Name =  this.agreementDocument.Name;
        }

        insert this.clientAgreement;

        this.agreementDocument.ParentId = this.clientAgreement.Id;
        insert this.agreementDocument;
        Attachment parentObjectAtt = this.agreementDocument.clone(false,true,false,false);

        parentObjectAtt.ParentId = this.isOpportunity ? this.clientAgreement.echosign_dev1__Opportunity__c : this.clientAgreement.Quote__c;
        
        insert parentObjectAtt;

        System.debug('-- ' + returnUrl);
        PageReference pgRef = new PageReference(this.returnUrl);

        pgRef.setRedirect(true);

        return pgRef;
    }

    public PageReference cancel(){

        PageReference pgRef = new PageReference(this.returnUrl);

        pgRef.setRedirect(true);

        return pgRef;
    }


}