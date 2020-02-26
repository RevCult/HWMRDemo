public without sharing class BuilderProjectListExt {

    public Id selectedBuilder {get; set;}
    public String selectedProject {get; set;}
    public String countyFilter {get; set;}
    public String stateFilter {get; set;}
    public String flagFilter {get; set;}
    public String meyersDispFilter {get; set;}
    public String projectStatusFilter {get; set;}
    public String updateCycleFilter {get; set;}
    public String searchTerm {get; set;}
    public String projectSearchTerm {get; set;}

    private final Builder__c theBuilder;
    public List<Project__c> theProjects {get; set;}
    public List<ProjectWithStatus> projectsWithStatus {get; set;}
    public ApexPages.StandardSetController projectSetController {get; set;}
    public ApexPages.StandardSetController projectsWithStatusSetController {get; set;}
    public List<Project__c> projectSet {get; set;}
    public String userId {get; set;}
    public String userType {get; set;}
    public String userName {get; set;}
    public String pageMode {get; set;} // 'builder' or 'dataUser'

    private List<Project_Update_Request__c> openPURsForTheProjects = new List<Project_Update_Request__c>();
    private List<Project_Update_Request__c> completedPURsForTheProjects = new List<Project_Update_Request__c>();
    private Map<Id, Project_Update_Request__c> mapProjectToPUR = new Map<Id, Project_Update_Request__c>();

    public BuilderProjectListExt(ApexPages.StandardController stdController) {
        // get any cookies representing prior filters applied so we can set the filter values appropriately
        Cookie fBuilder = ApexPages.currentPage().getCookies().get('fBuilder');
        Cookie fProject = ApexPages.currentPage().getCookies().get('fProject');
        Cookie fCounty = ApexPages.currentPage().getCookies().get('fCounty');
        Cookie fState = ApexPages.currentPage().getCookies().get('fState');
        Cookie fMeyersDisp = ApexPages.currentPage().getCookies().get('fMeyersDisp');
        Cookie fFlag = ApexPages.currentPage().getCookies().get('fFlag');
        Cookie fProjectStatus = ApexPages.currentPage().getCookies().get('fProjectStatus');
        Cookie fUpdateCycle = ApexPages.currentPage().getCookies().get('fUpdateCycle');
        // do the actual setting of the selected values to any prior filters applied
        if (null != fBuilder && '' != fBuilder.getValue()) {
            selectedBuilder = (Id)fBuilder.getValue();
            Builder__c b = [SELECT Id, Name FROM Builder__c WHERE Id = :selectedBuilder];
            searchTerm = b.Name;
        }
        if (null != fProject && '' != fProject.getValue()) {projectSearchTerm = fProject.getValue();}
        if (null != fCounty) countyFilter = fCounty.getValue();
        if (null != fState) stateFilter = fState.getValue();
        if (null != fMeyersDisp) meyersDispFilter = fMeyersDisp.getValue();
        if (null != fFlag) flagFilter = fFlag.getValue();
        if (null != fProjectStatus) projectStatusFilter = fProjectStatus.getValue();
        if (null != fUpdateCycle) updateCycleFilter = fUpdateCycle.getValue();

        // figure out which type of user this is (dataUser vs. user[salesforce user] vs. projectContact) and the name we should display on the site
        // TODO: deprecate - this is only used by dataUsers now
        if (null != ApexPages.currentPage().getParameters().get('userId')) {
            userId = ApexPages.currentPage().getParameters().get('userId');
            userType = BuilderProjectMgmtCmn.getUserType(userId);
            userName = BuilderProjectMgmtCmn.getUserName(userId);
        }
        // page used to support a pageMode when it was intended to be used by more than just ZICs... pageMode = 'dataUser' means ZIC mode:
        pageMode = 'dataUser';
        // set up the list of projects to be reviewed by the ZIC:
        filterProjects();
    }

    public void clearFilter() {
        selectedBuilder = null;
        selectedProject = null;
        countyFilter = null;
        stateFilter = null;
        meyersDispFilter = null;
        flagFilter = null;
        projectStatusFilter = null;
        updateCycleFilter = null;
        filterProjects();
    }

    public void filterProjects() {
        // this method is intended to completely set up the list of projects to show on the page

        // first set any cookies so we can re-filter on the selections later as needed....
        // Cookie(cookieName, cookieValue, path, maxAge in seconds [negative = session cookie], isSecure);
        List<Cookie> filterCookies = new List<Cookie>();
        filterCookies.add(new Cookie('fBuilder',selectedBuilder,null,-1,false));
        filterCookies.add(new Cookie('fProject',selectedProject,null,-1,false));
        filterCookies.add(new Cookie('fCounty',countyFilter,null,-1,false));
        filterCookies.add(new Cookie('fState',stateFilter,null,-1,false));
        filterCookies.add(new Cookie('fMeyersDisp',meyersDispFilter,null,-1,false));
        filterCookies.add(new Cookie('fFlag',flagFilter,null,-1,false));
        filterCookies.add(new Cookie('fProjectStatus',projectStatusFilter,null,-1,false));
        filterCookies.add(new Cookie('fUpdateCycle',updateCycleFilter,null,-1,false));
        // Set the new cookies for the page
        ApexPages.currentPage().setCookies(filterCookies);

        String soqlFilter = '';
        if (null != selectedBuilder && String.valueOf(selectedBuilder) != '') {
            soqlFilter += ' AND Builder__c = \''+String.valueOf(selectedBuilder)+'\'';
        }
        if (null != selectedProject && String.valueOf(selectedProject) != '') {
            soqlFilter += ' AND Name = \''+String.valueOf(selectedProject)+'\'';
        }
        if (null != countyFilter && '' != countyFilter) {
            soqlFilter += ' AND County_Calc__c LIKE \'%'+countyFilter+'%\'';
        }
        if (null != stateFilter && '' != stateFilter) {
            soqlFilter += ' AND State_Calc__c LIKE \'%'+stateFilter+'%\'';
        }
        if (null != meyersDispFilter && '' != meyersDispFilter) {
            soqlFilter += ' AND Meyers_Disposition_calc__c LIKE \'%'+meyersDispFilter+'%\'';
        }
        if (null != flagFilter && '' != flagFilter) {
            if ('60+ Days' == flagFilter) {
                Date sixtyDaysAgo = Date.today().addDays(-60);
                soqlFilter += ' AND Last_Updated_Date_Sales__c <= :sixtyDaysAgo';
                //soqlFilter += ' AND Id NOT IN (SELECT Project__c FROM Project_Update_Request__c WHERE Data_User__c = :userId)' AND Update_Request_Status__c IN (\'Review\',\'In Progress\'))';
            } else if ('90+ Days' == flagFilter) {
                Date nintyDaysAgo = Date.today().addDays(-90);
                soqlFilter += ' AND Last_Updated_Date_Sales__c <= :nintyDaysAgo';
            } else if ('120+ Days' == flagFilter) {
                Date onetwentyDaysAgo = Date.today().addDays(-120);
                soqlFilter += ' AND Last_Updated_Date_Sales__c <= :onetwentyDaysAgo';
            } else if ('150+ Days' == flagFilter) {
                Date onefiftyDaysAgo = Date.today().addDays(-150);
                soqlFilter += ' AND Last_Updated_Date_Sales__c <= :onefiftyDaysAgo';
            } else if ('In Review' == flagFilter) {
                soqlFilter += ' AND Id IN (SELECT Project__c FROM Project_Update_Request__c WHERE Data_User__c = :userId AND Update_Request_Status__c = \'Review\')';
            } else if ('In Progress' == flagFilter) {
                soqlFilter += ' AND Id IN (SELECT Project__c FROM Project_Update_Request__c WHERE Data_User__c = :userId AND Update_Request_Status__c = \'In Progress\')';
            }
        }
        if (null != projectStatusFilter && '' != projectStatusFilter) {
            soqlFilter += ' AND Status__c LIKE \'%'+projectStatusFilter+'%\'';
        } else {
            soqlFilter += ' AND Status__c IN (\'Active\', \'Upcoming\')';
        }
        if (null != updateCycleFilter && '' != updateCycleFilter) {
            soqlFilter += ' AND Update_Cycle__c LIKE \'%'+updateCycleFilter+'%\'';
        }
        // To remove the Pending projects from List
        soqlFilter += ' AND Id NOT IN (SELECT Project__c FROM Project_Update_Request__c WHERE Data_User__c = :userId AND Update_Request_Status__c IN (\'Pending\'))';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     

        // get all Project records for the data user
        String qry = 'SELECT Id, Builder__c, Builder__r.Name, Update_Cycle__c, Update_Cycle_Days__c, Name, Status__c,';
                qry += ' Last_Updated_Date_Price__c, Sales_Rate__c, Product_Type__c, Open_Date__c, Sold_Out_Date__c, Typical_Lot_Size__c,';
                qry += ' Total_Units_Planned__c, Total_Units_Sold__c, Total_Remaining__c, Total_Remaining_calc__c, Phone_Number__c, Sales_Person_Name__c,Num_of_Days_Since_Last_Update__c,';
                qry += ' Last_Updated_Date_Sales__c,MeyersNotesCounter__c,Alternate_Phone_Number__c,Email_Special__c, Last_Price_Update_display__c, ZIC_Date__c,';
                qry += ' Units_under_construction__c,Unsold_units_under_construction__c';
                qry += ' FROM Project__c';
                qry += ' WHERE Data_User__c = :userId '+soqlFilter;
                qry += ' ORDER BY Phone_Number__c,Num_of_Days_Since_Last_Update__c desc';
        
        theProjects = Database.query(qry);
        system.debug('theProjects: '+theProjects);
        
        Map<Id, Project__c> mapIdToProject = new Map<Id, Project__c>(theProjects);
        system.debug('mapIdToProject.keyset(): '+mapIdToProject.keyset());

        // remove any Project records that have had PURs Completed (not in progress or review) in the past Update Cycle Days
        completedPURsForTheProjects = [SELECT Id, Project__c FROM Project_Update_Request__c WHERE Project__c IN :mapIdToProject.keyset() AND Update_Request_Status__c NOT IN ('In Progress', 'Review') AND Inside_Update_Cycle__c = TRUE];
        system.debug('completedPURsForTheProjects: '+completedPURsForTheProjects);
        for (Project_Update_Request__c pur : completedPURsForTheProjects) {
            if (mapIdToProject.containsKey(pur.Project__c)) {
                mapIdToProject.remove(pur.Project__c);
            }
        }

        // get all In Progress or Review PURs for these Projects
        system.debug('mapIdToProject.keyset()InProcess and Review: '+mapIdToProject.keyset());
        openPURsForTheProjects = [SELECT Id, Project__c, Name, Status__c, MeyersNotesCounter__c, Alternate_Phone_Number__c, Email_Special__c, Last_Updated_Date_Price__c, Builder__r.Name, Phone_Number__c, Sales_Rate__c, Product_Type__c, Open_Date__c, Sold_Out_Date__c, Typical_Lot_Size__c, Total_Units_Planned__c, Total_Units_Sold__c, Total_Remaining__c, Total_Remaining_calc__c, Sales_Person_Name__c, Last_Updated_Date_Sales__c, Update_Request_Status__c, Units_under_construction__c, Unsold_units_under_construction__c FROM Project_Update_Request__c WHERE Project__c IN :mapIdToProject.keyset() AND Update_Request_Status__c IN ('In Progress', 'Review')];
        system.debug('openPURsForTheProjects: '+openPURsForTheProjects);
        /*
        // if we have some "In Progress" or "Review" PURs, we map them to their Project records [only one of them will be mapped]
        // this is used by the getProjectsWithStatusSet method to create an object with both of them...
        */
        if (null != openPURsForTheProjects && !openPURsForTheProjects.isEmpty()) {
            for (Project_Update_Request__c pur : openPURsForTheProjects) {
                mapProjectToPUR.put(pur.Project__c, pur);
            }
        }

        List<Project__c> theProjectsFinal = new List<Project__c>();
        for (Project__c p : mapIdToProject.values()) {
            Integer updateCycleDays = p.Update_Cycle_Days__c == null || p.Update_Cycle_Days__c == 0 ? 30 : Integer.valueOf(p.Update_Cycle_Days__c);
            //System.debug('Zic Date is:'+ p.ZIC_Date__c);
            //if (!(p.Last_Price_Update_display__c >= System.today().addDays(-updateCycleDays) && p.Last_Updated_Date_Sales__c >= System.Today().addDays(-updateCycleDays))) {
            //Date ZICdate = p.ZIC_Date__c;
            if (p.ZIC_Date__c == null || !(p.ZIC_Date__c > System.today())) {
                theProjectsFinal.add(p);
            }
        }


        projectSetController = new ApexPages.StandardSetController(theProjectsFinal);
        projectSetController.setPageSize(50);
        projectSet = projectSetController.getRecords();
    }

    public List <ProjectWithStatus> getProjectsWithStatusSet() {
        List <ProjectWithStatus> objList = new List <ProjectWithStatus>();
        for (Project__c p : (List <Project__c>)projectSetController.getRecords()) {
            if (null != openPURsForTheProjects && null != mapProjectToPUR.get(p.Id)) { // this project is in progress because there's an open PUR for it
                ProjectWithStatus pws = new ProjectWithStatus(p, true, mapProjectToPUR.get(p.Id));
                objList.add(pws);
            } else {
                ProjectWithStatus pws = new ProjectWithStatus(p, false, null);
                objList.add(pws);
            }
        }
        return objList;
    }

    // JS Remoting action called from the builder filter box
    @RemoteAction
    public static List<Builder__c> searchBuilders(String searchTerm, String userId) {
        List<Builder__c> builders = Database.query('Select Id, Name from Builder__c where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' AND Id IN (SELECT Builder__c FROM Project__c WHERE Data_User__c = \''+userId+'\')');
        return builders;
    }

    // JS Remoting action called from the project filter box
    @RemoteAction
    public static Set<String> searchProjects(String projectSearchTerm, String userId) {
        List<Project__c> projects = Database.query('Select Id, Name from Project__c where name like \'%' + String.escapeSingleQuotes(projectSearchTerm) + '%\' AND Data_User__c = \''+userId+'\'');
        Set<String> distinctProjectNames = new Set<String>();
        for (Project__c p : projects){
            distinctProjectNames.add(p.Name);
        }
        return distinctProjectNames;
    }

    public void next() {
        projectSetController.next();
        projectSet = projectSetController.getRecords();
    }

    public void previous() {
        projectSetController.previous();
        projectSet = projectSetController.getRecords();
    }

    public void first() {
        projectSetController.first();
        projectSet = projectSetController.getRecords();
    }

    public void last() {
        projectSetController.last();
        projectSet = projectSetController.getRecords();
    }

    public Integer getCurrentSetStart() {
        return (projectSetController.getPageSize() * (projectSetController.getPageNumber() - 1)) + 1;
    }

    public Integer getCurrentSetEnd() {
        Integer currentSetEnd = (projectSetController.getPageSize() * projectSetController.getPageNumber());
        if (projectSetController.getResultSize() < currentSetEnd) {
            currentSetEnd = projectSetController.getResultSize();
        }
        return currentSetEnd;
    }

    public List<SelectOption> getStatusOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Status'));
        List<String> optionStrings = getPicklistValues('Project__c', 'Status__c');
        for (String option : optionStrings) {
            if (option == 'Active' || option == 'Upcoming') {
                SelectOption so = new SelectOption(option, option);
                options.add(so);    
            }
        }

        return options;
    }

    public List<SelectOption> getUpdateCycleOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Update Cycle'));
        List<String> optionStrings = getPicklistValues('Project__c', 'Update_Cycle__c');
        for (String option : optionStrings) {
            SelectOption so = new SelectOption(option, option);
            options.add(so);
        }

        return options;
    }

    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 

        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }

        return lstPickvals;
    }

    // inner class to drive display based on whether or not a user has already started working on a project update
    public class ProjectWithStatus {
        public Project__c theProject {get; set;}
        public Boolean isInProgress {get; set;}
        public Boolean isOld {get; set;}
        public Project_Update_Request__c theProjectUpdateRequest {get; set;}
        public integer noOfDays {get; set;}
        public ProjectWithStatus(Project__c p, Boolean inProgress, Project_Update_Request__c pur) {
            this.theProject = p;
            this.isInProgress = inProgress;
            this.isOld = null == p.Last_Updated_Date_Sales__c ? FALSE : p.Last_Updated_Date_Sales__c <= system.today().addDays(-60);
            if(null != p.Last_Updated_Date_Sales__c )
            this.noOfDays = p.Last_Updated_Date_Sales__c.daysBetween(system.today());
            else
            this.noOfDays = 0;
            this.theProjectUpdateRequest = pur;
        }
    }
}