@isTest(SeeAllData = True)
private class z_generate_quote_pdf_TEST
 {
      static zqu__Quote__c quote{
        get;
        set;
      }
 
     
 
     static testMethod void GenerateNewQuotePDF() {
     GoogleIntegrationHelper.disableAsync = true;
    Account acc = TestFactory.makeAccount();
    Contact con = TestFactory.makeContact( acc );
    Opportunity opp = TestFactory.makeOpportunity( acc );
    zqu__Quote_Template__c qt = TestFactory.makeQuoteTemplate();
    quote = TestFactory.makeQuote( opp, qt );
 
         //load the page
    ApexPages.StandardController sc = new ApexPages.StandardController(quote);
      z_generate_quote_pdf pdf = new z_generate_quote_pdf(sc);
 
 
     pdf.getDefaultQuoteTemplateId();
     //pdf.generate();
     
     }
 
 
 }