/**
 * Implements AdBook interface for code that gets call after an Opportunity is refreshed
 * from AdBook.
 * Allows for changes to the Billing Contact and Agency
 * Needs to be global to allow AdBook managed package to call it
 */
global class AdBookOpportunityRefreshedEvent implements AB2.AdBookEvents.OpportunityRefreshedEvent {
    /**
	 * The refresh of the Opportunity has completed
	 */
    global void refreshedOpportunity(Opportunity opp, boolean onlyRefreshDrops) {
        if(System.isFuture() || System.isBatch()) {
        	// Already in a future or batch method
        	AdBookIntegration.updateOpportunityDetailsSync(opp.Id);
        } else {
        	// Method is marked @future to get processing out of the current transaction
        	AdBookIntegration.updateOpportunityDetails(opp.Id);
        }
    }
    
}