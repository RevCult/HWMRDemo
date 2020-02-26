public with sharing class z_generate_quote_pdf {

  public String defaultQuoteTemplateId {get;set;}
  public String attachmentId {get;set;}

  public zqu__Quote__c quote {get;set;}

  /**
   * Constructor
   */
  public z_generate_quote_pdf(ApexPages.StandardController controller) {
    ID recordId = controller.getRecord().Id;
    quote = getQuoteId(recordId);
  }

  /**
   * Queries for the Quote Object associated with this Record ID
   */
  public zqu__Quote__c getQuoteId(ID recordId) {
    List<zqu__Quote__c> quoteList = [
      SELECT
        Name, zqu__QuoteTemplate__r.zqu__Template_Id__c,
        zqu__SubscriptionType__c
      FROM
        zqu__Quote__c
      WHERE
        Id =: recordId];

    if (quoteList.size() == 0) {
      System.debug('Error: No quotes found with Id: ' + recordId);
      return null;
    } else {
      quote = quoteList[0];
      return quote;
    }
  }

  /**
   * Queries the Default Template for this SubscriptionType.
   */
  public void getDefaultQuoteTemplateId() {
    List<zqu__Quote_Template__c> quoteTemplateList = [
      SELECT 
        Name,zqu__IsDefault__c, zqu__Description__c, 
        zqu__Quote_Type__c, zqu__Template_Id__c 
      FROM
        zqu__Quote_Template__c
      WHERE
        zqu__Quote_Type__c = :quote.zqu__SubscriptionType__c];

    if (quoteTemplateList.size() == 0) {
      System.debug('No Quote Templates are setup');
      return;
    }
    
    this.defaultQuoteTemplateId = quote.zqu__QuoteTemplate__r.zqu__Template_Id__c;
    /*
    for (zqu__Quote_Template__c template : quoteTemplateList) {
      if (template.zqu__IsDefault__c) {
        this.defaultQuoteTemplateId = template.zqu__Template_Id__c;
        System.debug('Default Quote Template found with ID: ' 
          + this.defaultQuoteTemplateId);
      }
    }*/
  }

  /**
   * Generates PDF and attaches to Quote's parent Opportunity Object.
   */
  public PageReference generate() {
    // NOTE(chudy): Process Flow.
    if (quote != null) {
      /* TODO(chudy): No way to currently determine if this failed 
       * or not. */
      getDefaultQuoteTemplateId();

      // TODO(sandesh): Update Revenue Lines
      // TODO(sandesh): Update Taxes

      // NOTE(chudy): Generate Quote and attach to Opportunity
      if (defaultQuoteTemplateId == null) {
        return null;
        //generate();
      }
    }

    Map<String,Object> zuoraConfigInfo = 
      zqu.zQuoteUtil.getZuoraConfigInformation();

    Zuora.ZApi zApi = new Zuora.ZApi();

    Zuora.ZApi.LoginResult loginResult = zApi.zLogin();
    System.debug(loginResult.serverUrl);
    String quoteServletUrl = loginResult.serverUrl.contains('apisandbox') ?
      'https://apisandbox.zuora.com/apps/servlet/GenerateQuote' :
      'https://zuora.com/apps/servlet/GenerateQuote';

    String sessionId = UserInfo.getSessionId();

    String sfdcUrl = URL.getSalesforceBaseUrl().toExternalForm() 
      + '/services/Soap/u/10.0/' + UserInfo.getOrganizationId();

    PageReference generatePage = new PageReference(quoteServletUrl);
    generatePage.getParameters().put('templateId', defaultQuoteTemplateId);
    generatePage.getParameters().put('serverUrl', sfdcUrl);
    generatePage.getParameters().put('sessionId', sessionId);
    generatePage.getParameters().put('quoteId', quote.Id);
    generatePage.getParameters().put('attachToOpportunity', 'true');
    generatePage.getParameters().put('format', 'pdf');
    generatePage.getParameters().put('ZSession', loginResult.session);
    generatePage.getParameters().put('useSFDCLocale', '1');
    generatePage.getParameters().put('locale', UserInfo.getLocale());

    Http h = new Http();

    System.debug('Quote PDF URL = ' + generatePage.getUrl());

    HttpRequest req = new HttpRequest();
    req.setEndpoint(generatePage.getUrl());
    req.setMethod('GET');
	req.setTimeout(120000);
    HttpResponse res = h.send(req);

    if (res.getStatusCode() != 200) {
      appendMessage(ApexPages.Severity.ERROR, 'Error contacting Zuora');
      return null;
    }

    /* NOTE(chudy): I think Zuora handles the attaching it to the
     * opportunity through the https callout. We just check for success
     * here. */
    String zuoraResponse = res.getBody();
    String successMessage = 'Quote PDF document has been successfully';
    if (zuoraResponse.contains(successMessage)) {
      appendMessage(ApexPages.Severity.CONFIRM, 'Response Body: ' + zuoraResponse);
      attachmentId = zuoraResponse.split('AttachmentID:', 0)[1];
      // Not sure what happened here but the above split includes a +
      System.debug('Attachment ID Post Regex: ' + attachmentId);
      if (attachmentId.length() > 19) {
        attachmentId = attachmentId.substring(1,19);
      }
      
      // NOTE(chudy): The following will 
      String echoSignTemplate = 'a0qn00000008hYT';
      String quoteId = quote.Id;
      

      PageReference redirect = new PageReference('/apex/echosign_dev1__AgreementTemplateProcess?masterId='
        +quoteId+'&AttachmentId='+attachmentId);//+'&retURL=/'+quoteId);
      redirect.setRedirect(true);
      return redirect;
    } else {
      appendMessage(ApexPages.Severity.ERROR, 'Response Body: ' + zuoraResponse);
    }
    return null;
  }

  /**
   *  Display a message on the VF page
   */
  private static void appendMessage(ApexPages.Severity severity, 
      String message) {
    ApexPages.addMessage(new ApexPages.Message(severity, message));
  }

}