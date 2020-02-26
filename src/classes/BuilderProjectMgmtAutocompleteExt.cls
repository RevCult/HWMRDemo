public with sharing class BuilderProjectMgmtAutocompleteExt {
	
	private final Builder__c theBuilder {get; set;}
	public String searchTerm {get; set;}

	public BuilderProjectMgmtAutocompleteExt(ApexPages.StandardController theController) {
		theBuilder = (Builder__c)theController.getRecord();
	}
	
	// JS Remoting action called when searching
    @RemoteAction
    public static List<Builder__c> searchBuilders(String searchTerm) {
        List<Builder__c> builders = Database.query('Select Id, Name from Builder__c where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return builders;
    }
}