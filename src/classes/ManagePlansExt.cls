public class ManagePlansExt {
    public String projectId {get; set;}
    public String projectName {get; set;}
    public List<SelectablePlan> planList {get; set;}
    List<Plan__c> selectedPlans = new List<Plan__c>();
    
    // constructor
    public ManagePlansExt(ApexPages.StandardSetController stdController) {
        // instantiation nation
        projectId = '';
        projectName = '';
        planList = new List<SelectablePlan>();

        // make sure we have an "id" in the querystring parameters, then use it to get all the plans for the project
        if (null != ApexPages.currentPage().getParameters().get('id') && '' != ApexPages.currentPage().getParameters().get('id')) {
            projectId = ApexPages.currentPage().getParameters().get('id');
            List<Plan__c> allPlansForProject = new List<Plan__c>();
            allPlansForProject = [SELECT Id
                                    ,    Name
                                    ,    Project__c
                                    ,    Project__r.Name
                                    ,    Display_in_Zonda__c
                                    ,    Hidden_from_ZIC_site__c 
                                    ,    Off_Market__c
                                    ,    Square_Footage__c
                                    ,    Price__c
                                    ,    LastModifiedDate
                                    ,    CreatedDate
                                    ,    Plan_Notes__c
                                    ,    Last_Updated_Date_Price__c
                                    ,    Last_Update_User_Price__c
                                    ,    CreatedBy.Name

                                  FROM Plan__c 
                                  WHERE Project__c = :projectId 
                                  ORDER BY Name];

            if (!allPlansForProject.isEmpty()) {
                projectName = allPlansForProject[0].Project__r.Name;
                for (Plan__c p : allPlansForProject) {
                    planList.add(new SelectablePlan(p));
                }
            }
        }
    }

    // called by commandbutton on page to update ALL the plans to the current set values
    public PageReference updateValues() {
        List<Plan__c> allPlans = getAllPlans();
        update allPlans;
        return new ApexPages.PageReference('/'+projectId);
    }

    // called by commandbutton on page to delete the plans with the checkbox selected
    public PageReference deleteSelectedPlans() {
        delete selectedPlans;
        return new ApexPages.PageReference('/'+projectId);
    }

    // used to get a list of all the plans so we can update them
    private List<Plan__c> getAllPlans() {
        List<Plan__c> plansToReturn = new List<Plan__c>();
        for (SelectablePlan p : planList) {
            plansToReturn.add(p.thePlan);
        }
        return plansToReturn;
    }

    // used by the page to make sure the selected plans list is up to date when the delete checkboxes are checked/unchecked
    public PageReference getSelected() {
        selectedPlans.clear();
        for (SelectablePlan planWrapper : planList) {
            if (planWrapper.isSelected) {
                selectedPlans.add(planWrapper.thePlan);
            }
        }
        return null;
    }

    // inner wrapper class so we can present the user with checkboxes to select the plans for deletion on the page
    public class SelectablePlan {
        public Boolean isSelected {get; set;}
        public Plan__c thePlan {get; set;}

        public SelectablePlan(Plan__c p) {
            thePlan = p;
            isSelected = false;
        }
    }
}