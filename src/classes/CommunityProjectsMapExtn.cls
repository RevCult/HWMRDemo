public class CommunityProjectsMapExtn {
    // public Project__c project {get;set;}
    public string CommunityId {get;set;}
    public list<Project__c> projectsList {get;set;}
    public decimal lat {get;set;}
    public decimal lang {get;set;} 
    public list<latlangwrapper> commuPrjlist {get;set;}
    
    public CommunityProjectsMapExtn(ApexPages.StandardController stdController) {
        commuPrjlist = new list<latlangwrapper>();
        CommunityId = apexPages.currentPage().getParameters().get('id');
        Community__c community = new Community__c();
        if(CommunityId != Null){
            community = [select id,Name,Location__Latitude__s,Location__Longitude__s,(select id,Name,Location__Latitude__s,Location__Longitude__s from Projects_Village__r),(select id,Name,Location__Latitude__s,Location__Longitude__s from Projects_Master_Plan__r),(select id,Name,Location__Latitude__s,Location__Longitude__s from Projects_Neighborhood__r) from Community__c where id=:CommunityId];
        }
        CommunityId = community.id;
        if(community != null){
            projectsList = new list<Project__c>();
            if(community.Projects_Village__r.size() > 0){
                for(Project__c prj : community.Projects_Village__r){
                    if(prj.Location__Latitude__s != null && prj.Location__Longitude__s != null){
                        projectsList.add(prj);
                    }
                }
            }
            if(community.Projects_Master_Plan__r.size() > 0){
                for(Project__c prj : community.Projects_Master_Plan__r){
                    if(prj.Location__Latitude__s != null && prj.Location__Longitude__s != null){
                        projectsList.add(prj);
                    }
                } 
            }
            if(community.Projects_Neighborhood__r.size() > 0){
                for(Project__c prj : community.Projects_Neighborhood__r){
                    if(prj.Location__Latitude__s != null && prj.Location__Longitude__s != null){
                        projectsList.add(prj);
                    }
                } 
            }
        }
        system.debug('projectsList size=='+projectsList.size());
        if(community != null){
            lat = community.Location__Latitude__s;
            lang = community.Location__Longitude__s;
            commuPrjlist.add(new latlangwrapper(community.id,community.name,community.Location__Latitude__s,community.Location__Longitude__s));
        }
        for(Project__c prj : projectsList){
            if(lat == null){
                lat = prj.Location__Latitude__s;
                lang = prj.Location__Longitude__s;
            }
            commuPrjlist.add(new latlangwrapper(prj.id,prj.name,prj.Location__Latitude__s,prj.Location__Longitude__s));
        }
    }
    
    public class latlangwrapper{
        public id id{get;set;}
        public string name{get;set;}
        public decimal lat{get;set;}
        public decimal lang{get;set;}
        
        public latlangwrapper(id id,string name,decimal lat,decimal lang){
            this.id = id;
            this.name = name;
            this.lat = lat;
            this.lang = lang;
        }
    }
}