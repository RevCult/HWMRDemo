public with sharing class DirectoryCategories {
    
    
    public OpportunityLineItem lineitem {get;set;}
    
    public List<DirectoryCategoryWrapper> directoryCategories{get;set;}
    public List<DirectoryCategoryWrapper> premiumDirectoryCategories{get;set;}
    public String SearchAC{get;set;}
    public String SearchPC{get;set;}
    
    public DirectoryCategories(Apexpages.standardController controller) {
        
        try {
            SearchAC = '';
            SearchPC = '';
            directoryCategories = new List<DirectoryCategoryWrapper>();
            premiumDirectoryCategories = new List<DirectoryCategoryWrapper>();
            
            if (controller.getId() != null) {
                
                lineitem = [select id, Directory_Brand__c, Directory_Categories__c, Premium_Directory_Categories__c, Premium_Directory__c from OpportunityLineItem 
                where id =: controller.getId()];
                
                if (lineitem.Directory_Brand__c != null) {
                    
                    Set<String> setDC = new Set<String>();
                    if (lineitem.Directory_Categories__c != null) {
                        for(String dc: lineitem.Directory_Categories__c.split(';')) {
                            setDC.add(dc);
                        }
                    }
                    
                    for (Directory_Category__c dc :[select id,name from Directory_Category__c where Directory_Brands__c includes (:lineitem.Directory_Brand__c) order by name ]) {
                         directoryCategories.add(new DirectoryCategoryWrapper(dc, setDC.contains(dc.name))); 
                    }
                    
                    if (lineitem.Premium_Directory__c) {
                    
                        setDC = new Set<String>();
                        if (lineitem.Premium_Directory_Categories__c != null) {
                            for(String dc: lineitem.Premium_Directory_Categories__c.split(';')) {
                                setDC.add(dc);
                            }
                        }
                    
                        for (Directory_Category__c dc :[select id,name from Directory_Category__c where Directory_Brands__c includes (:lineitem.Directory_Brand__c) order by name ]) {
                             premiumDirectoryCategories.add(new DirectoryCategoryWrapper(dc, setDC.contains(dc.name))); 
                        }
                    }
                }
                
            
            }
        }
        catch(Exception e) {
            Apexpages.addMessages(e);
        }
        
    }
    
    public void search(){
        try{
            if (lineitem != null && SearchAC != null && lineitem.Directory_Brand__c != null) { 
                Set<String> setDC = new Set<String>();
                
                if (lineitem.Directory_Categories__c != null) {
                    for(String dc: lineitem.Directory_Categories__c.split(';')) {
                        setDC.add(dc);
                    }
                }
                
                string searchText = '%'+SearchAC+'%';
                directoryCategories = new List<DirectoryCategoryWrapper>();
                for (Directory_Category__c dc : [select id,name from Directory_Category__c where Directory_Brands__c includes (:lineitem.Directory_Brand__c) AND Name like :searchText order by name]) {
                     directoryCategories.add(new DirectoryCategoryWrapper(dc, setDC.contains(dc.name))); 
                }
            }
        }
        catch(Exception e){
            Apexpages.addMessages(e);
        }
    }
    
    public void search2(){
        try{
            if (lineitem != null && SearchPC != null && lineitem.Directory_Brand__c != null) { 
                Set<String> setDC = new Set<String>();
                
                if (lineitem.Premium_Directory__c) {
                    if (lineitem.Premium_Directory_Categories__c != null) {
                        for(String dc: lineitem.Premium_Directory_Categories__c.split(';')) {
                            setDC.add(dc);
                        }
                    }
                    string searchText = '%'+SearchPC+'%';
                    premiumDirectoryCategories = new List<DirectoryCategoryWrapper>();
                    for (Directory_Category__c dc : [select id,name from Directory_Category__c where Directory_Brands__c includes (:lineitem.Directory_Brand__c) AND Name like :searchText  order by name]) {
                         premiumDirectoryCategories.add(new DirectoryCategoryWrapper(dc, setDC.contains(dc.name))); 
                    }
                }
            }
        }
        catch(Exception e){
            apexpages.addMessages(e);
        }
    }
    
    public class DirectoryCategoryWrapper {
        
        public Boolean isSelected{get;set;}
        public Directory_Category__c dc{get;set;}
        public DirectoryCategoryWrapper(Directory_Category__c dc, Boolean isSelected) {
            this.dc = dc;
            this.isSelected = isSelected;
        }
    }
    
    public Pagereference save() {
        
        try {
            string dcname ='';
            if (lineitem.Premium_Directory__c) {
                
                
                integer count = 0;
                for (DirectoryCategoryWrapper dcw: premiumDirectoryCategories) {
                    if (dcw.isselected) {
                        if (dcname =='') {
                            dcname = dcw.dc.name;
                        }
                        else {
                            dcname += ';'+ dcw.dc.name;
                        }
                        
                        count ++;
                    }
                }
                
                if (count > 3 ) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please select up to 3 premium directory categories.');
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                lineitem.Premium_Directory_Categories__c = dcname;
            }
            
            dcname ='';
            for (DirectoryCategoryWrapper dcw: directoryCategories) {
                if (dcw.isselected) {
                    if (dcname =='') {
                        dcname = dcw.dc.name;
                    }
                    else {
                        dcname += ';'+ dcw.dc.name;
                    }
                }
            }
            lineitem.Directory_Categories__c = dcname;
            update lineitem;
            
            return new Pagereference('/'+lineitem.id);
        }
        catch(Exception e) {
            Apexpages.addMessages(e);
        }
        return null;
    }
    
}