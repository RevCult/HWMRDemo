public without sharing class FC_GenerateQuoteRedirectController {

    private final ApexPages.StandardController standardController;
    private final zqu__Quote__c quoteRecord;
    
    public FC_GenerateQuoteRedirectController(ApexPages.StandardController standardController) {
        this.standardController = standardController;
        this.quoteRecord = (zqu__Quote__c) standardController.getRecord();
    }
    
    public PageReference redirectPdf() {
        if (!isValid()) {
            return null;
        }
        return redirect('pdf');    
    }
    
    public PageReference redirectDoc() {
        if (!isValid()) {
            return null;
        }
        return redirect('doc');
    }
    
    private Boolean isValid() {
        FC_Approval_Settings__c fcApprovalSettings = FC_Approval_Settings__c.getInstance();
        if (quoteRecord.zqu__QuoteTemplate__c == null) {
            PageReference prEditQuoteDetail = Page.zqu__EditQuoteDetail;
            prEditQuoteDetail.getParameters().put('id', quoteRecord.Id);
            prEditQuoteDetail.setRedirect(true);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'Please select a quote template by editing the quote details. ' +
                                                       '<a href="' + prEditQuoteDetail.getUrl() + '">Take me there!</a>'));
            return false;
        }

        if (quoteRecord.Original_Record_Type_Name__c == 'Default' || quoteRecord.Original_Record_Type_Name__c == 'Amendment') {
            ID quoteId = quoteRecord.Id;
            String chargeSoqlTemplate = 'select Id, zqu__ListPrice__c, zqu__EffectivePrice__c ' +
                    'from {0} where ProductName__c = \'\'Residential Economic Report\'\' and {1} = :quoteId';
            String chargeSoql = String.format(chargeSoqlTemplate, 
                    new String[] { quoteRecord.Original_Record_Type_Name__c == 'Amendment' ? 'zqu__QuoteRatePlanCharge__c' : 'zqu__QuoteCharge__c',
                            quoteRecord.Original_Record_Type_Name__c == 'Amendment' ? 'zqu__QuoteRatePlan__r.zqu__Quote__c' : 'zqu__Quote__c' });
            for (SObject charge : Database.query(chargeSoql)) {
                Decimal listPrice = (Decimal) charge.get('zqu__ListPrice__c');
                Decimal effectivePrice = (Decimal) charge.get('zqu__EffectivePrice__c');
                if (!fcApprovalSettings.Bypass_DBD_Approval__c && effectivePrice < listPrice) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Discounting not allowed on REE Product.'));
                    return false;
                }
            }
        }

        return true;
    }
    
    private PageReference redirect(String format) {
        URL zuoraInstanceUrl = null;
        String zuoraSessionId = '';
        if (!Test.isRunningTest()) {
            Zuora.zApi zApiInstance = new Zuora.zApi();
            Zuora.zApi.LoginResult loginResult = zApiInstance.zlogin();
            zuoraSessionId = loginResult.Session;
            zuoraInstanceUrl = new URL(loginResult.ServerUrl);
        } else {
            zuoraSessionId = 'abcdef123456';
            zuoraInstanceUrl = new URL('https://example.zuora.com');
        }
        String endpointUrl = zuoraInstanceUrl.getProtocol()+ '://' + zuoraInstanceUrl.getHost() + '/apps/servlet/GenerateQuote';
        Map<String, String> params = new Map<String, String> {
            'attachToOpportunity' => 'true',
            'format' => format,
            'locale' => 'en_US',
            'quoteId' => quoteRecord.Id,
            'serverUrl' => FC_InstanceUtils.getBaseUrlForInstance() + '/services/Soap/u/10.0/' + UserInfo.getOrganizationId(),
            'sessionId' => UserInfo.getSessionID(),
            'templateId' => quoteRecord.zqu__QuoteTemplate__r.zqu__Template_Id__c,
            'useSFDCLocale' => '1',
            'ZSession' => zuoraSessionId
        };
        String[] paramList = new List<String>();
        for (String key : params.keySet()) {
            paramList.add(String.join(new String[] { key, EncodingUtil.urlEncode(params.get(key), 'UTF-8') }, '='));
        }
        String paramString = String.join(paramList, '&');
        endpointUrl = String.join(new String[] { endpointUrl, paramString }, '?');
        System.debug('********* REQUEST 1: ' + endpointUrl);
        Http httpClient = new Http();
        HttpRequest request1 = new HttpRequest();
        request1.setEndpoint(endpointUrl);
        request1.setTimeout(120000);
        request1.setMethod('GET');
        request1.setHeader('Connection', 'close');
        HttpResponse response1 = httpClient.send(request1);
        System.debug('********* RESPONSE 1: ' + response1.getBody());

        if (response1.getStatusCode() != 200) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                           String.format('Request 1: {0} - {1}', 
                                                                         new String[] { String.valueOf(response1.getStatusCode()),
                                                                             response1.getStatus() })));
                return null;
        }
        return standardController.view();
    }
}