public without sharing class ProductSearchController {
    
    public String searchstr { get; set; }
    public String subcategory { get; set; }
    public String producttype { get; set; }
    public string productId{get;set;}
    
    public string WFProjectId{get;set;}
    public string displayMessage{get;set;}
    public Boolean showLoadError{get; set;}
    
    public List<DSMProductWrapper> productsWrapper{get;set;}
    
    public ProductSearchController() {
        WFProjectId = Apexpages.currentpage().getparameters().get('WFProjectId');
        showLoadError = false;
        displayMessage  = '';
        List<OpportunityLineItem> oltList = [Select Id,WF_Project_Id__c from OpportunityLineItem where WF_Project_Id__c =: WFProjectId];
        if(oltList.size() > 0){
            showLoadError = true;
            displayMessage = ' Products cannot be changed after project has been synced with SFDC ';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,displayMessage);
            ApexPages.addMessage(myMsg);
        }
        
        productsWrapper = new List<DSMProductWrapper>();
        productId ='';
    }
    
    public List<Selectoption> getsubcategories() {
        List<Selectoption> options = new List<Selectoption>();
        options.add(new selectoption( 'All', 'All'));
        options.add(new selectoption( 'Classified', 'Classified'));
        options.add(new selectoption( 'Demand Generation', 'Demand Generation'));
        options.add(new selectoption( 'Events', 'Events'));
        options.add(new selectoption( 'Exhibitions', 'Exhibitions'));
        options.add(new selectoption( 'Impressions/Branding', 'Impressions/Branding'));
        options.add(new selectoption( 'Print', 'Print'));
        options.add(new selectoption( 'Marketing', 'Marketing'));
        options.add(new selectoption( 'Metrostudy', 'Metrostudy'));
        options.add(new selectoption( 'SMS', 'SMS'));
        
        return options;
    }

/*

*/
    
    public List<Selectoption> getProducttypes() {
        List<Selectoption> options = new List<Selectoption>();
        options.add(new selectoption( 'All', 'All'));
        options.add(new selectoption( 'Back Copy Sales', 'Back Copy Sales'));
        options.add(new selectoption( 'Branded Event', 'Branded Event'));
        options.add(new selectoption( 'Consumer Specials', 'Consumer Specials'));
        options.add(new selectoption( 'Customer Engagement Program', 'Customer Engagement Program'));
        options.add(new selectoption( 'Demand Generation', 'Demand Generation'));
        options.add(new selectoption( 'Digital Edition', 'Digital Edition'));
        options.add(new selectoption( 'Digital Subscription','Digital Subscription'));
        options.add(new selectoption( 'Direct Mail List','Direct Mail List'));
        options.add(new selectoption( 'Directory Listing','Directory Listing'));
        options.add(new selectoption( 'Education','Education'));
        options.add(new selectoption( 'Email List Blast','Email List Blast'));
        options.add(new selectoption( 'Event Sponsorship','Event Sponsorship'));
        options.add(new selectoption( 'Event Sponsorship (Custom)','Event Sponsorship (Custom)'));
        options.add(new selectoption( 'Exhibitions Intercompany','Exhibitions Intercompany'));
        options.add(new selectoption( 'Hanley Wood Marketing','Hanley Wood Marketing'));
        options.add(new selectoption( 'HWTV (Sponsor Supplied)','HWTV (Sponsor Supplied)'));
        options.add(new selectoption( 'Marketing','Marketing'));
        options.add(new selectoption( 'Metrostudy','Metrostudy'));
        options.add(new selectoption( 'Metrostudy Intercompany','Metrostudy Intercompany'));
        options.add(new selectoption( 'Newsletter','Newsletter'));
        options.add(new selectoption( 'Paid Promo Allocation','Paid Promo Allocation'));
        options.add(new selectoption( 'Print','Print'));
        options.add(new selectoption( 'Product Spotlight Blast','Product Spotlight Blast'));
        options.add(new selectoption( 'Roadblock','Roadblock'));
        options.add(new selectoption( 'Run of Network','Run of Network'));
        options.add(new selectoption( 'Sponsored Circulation','Sponsored Circulation'));
        options.add(new selectoption( 'Strategic Marketing Services','Strategic Marketing Services'));
        options.add(new selectoption( 'Virtual Event','Virtual Event'));
        
        return options;
    }
    
    public void search() {
        if (searchstr.trim() == '' || searchstr == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please specify search term.');
            ApexPages.addMessage(myMsg);
            return ;
        }
        
        productsWrapper = new List<DSMProductWrapper>();
        string str ='%' + searchstr + '%';
        
        string query = ' select id, Product_Name__c ,Product_Type__c,Product_ID__c, Product_Category__c,name, Product_Subcategory__c from DSM_Products__c ';
        string whereclause =  ' where Inactive_Product__c != \'Yes\' AND';
        
        if (subcategory != null ) {
            if (subcategory != 'All') {
                whereclause += ' Product_Subcategory__c = ' + '\'' + subcategory +'\'' + ' AND ';   
            }      
        }  
        if (producttype != null) {
            if (producttype != 'All') {
                whereclause += ' Product_Type__c = ' + '\'' + producttype +'\'' + ' AND ';   
            }    
        }  
        
        if (searchstr != null) {
            whereclause += ' (Product_Name__c like ' + '\'' + str +'\') AND ';       
        }  
        
        query = query + whereclause;
        
        query = query.trim().substring (0, query.length() - 5)+' limit 1000';
        if ( searchstr != null) {
            //system.assert(false, query);
            //[select id, Product_Type__c, Product_Category__c,name, Product_Subcategory__c from DSM_Products__c where name like: str]
            for (DSM_Products__c prod: database.query(query)) {
                productsWrapper.add(new DSMProductWrapper(prod));
            }
        }
        if(productsWrapper.size() == 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Result: Records not found.');
            ApexPages.addMessage(myMsg);
        }
        //return productsWrapper;
        //return null;
    }
    
    
    public PageReference updateProject() {
        //system.assert(false,productId);
        displayMessage ='';
        
        List<OpportunityLineItem> oltList = [Select Id,WF_Project_Id__c from OpportunityLineItem where WF_Project_Id__c =: WFProjectId];
        if(oltList.size() > 0 ) {
            displayMessage = ' Error occured : Products cannot be changed after project has been synced with SFDC ';
        }
        else{
            //WFProjectId ='576061de00c2e7445a35ae5901af2b9f';
            DSM_Products__c prod = [select id, Product_ID__c, name,Product_Name__c,WF_Template_ID__c,
            Product_Type__c, Product_Category__c, Product_Subcategory__c from DSM_Products__c where id=: productId];
            //Boolean b = WorkFrontService.updateProject(WFProjectId, prod);
            displayMessage = WorkFrontService.updateProject(WFProjectId, prod);
            if (displayMessage == '') {
                displayMessage = ' Product has been updated successfully ';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,displayMessage);
                ApexPages.addMessage(myMsg);
            }
            else{
                List<String> lstMsg = displayMessage.split('"message":"');
                if(lstMsg.size() == 2){
                    if(lstMsg[1].split('"title"').size() == 2){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,lstMsg[1].split('","title"')[0]);
                        ApexPages.addMessage(myMsg);
                    }
                    else{
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,displayMessage);
                        ApexPages.addMessage(myMsg);
                    }
                }
                else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,displayMessage);
                    ApexPages.addMessage(myMsg);
                }
            }
        }
        
           
        
        return null;
    }
    
    public List<DSMProductWrapper> getProducts() {
        return productsWrapper;
    }
    
    public class DSMProductWrapper {
        public Boolean isSelected{get;set;}
        public DSM_Products__c product{get;set;}
        public DSMProductWrapper(DSM_Products__c product){
            this.product = product;
            isSelected = false;
        }
    }
    
    
}