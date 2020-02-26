public without sharing class BuilderProjectMgmtExt {

	public Id selectedBuilder {get; set;}
    //public String searchTerm {get; set;}
    public String userId {get; set;}
    public String userType {get; set;}
    public String userName {get; set;}
	
	public BuilderProjectMgmtExt(ApexPages.StandardController stdController) {
        if (null != ApexPages.currentPage().getParameters().get('userId')) {
            userId = ApexPages.currentPage().getParameters().get('userId');
            userType = BuilderProjectMgmtCmn.getUserType(userId);
            userName = BuilderProjectMgmtCmn.getUserName(userId);
        }
    }

    public List<SelectOption> getBuilders() {
    	List<SelectOption> theBuilders = new List<SelectOption>();
    	List<Builder__c> builderList = [SELECT Id, Name FROM Builder__c];
    	for (Builder__c b : builderList) {
    		SelectOption theOption = new SelectOption(b.Id, b.Name);
    		theBuilders.add(theOption);
    	}
    	return theBuilders;
    }

    public PageReference goToProjectList() {
        if (null == selectedBuilder || '' == (string)selectedBuilder) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a builder to view Projects'));
            return null;
        } else {
            ApexPages.PageReference whereToGo = Page.BuilderProjectList;
            whereToGo.getParameters().put('id', selectedBuilder);
            if (null != userId && '' != userId) {
                whereToGo.getParameters().put('userId', userId);
            }
            return whereToGo;
        }
    }
}