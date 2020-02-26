/*********************************************************************
 *
 * @description LeadAssignmentHandler - Performs Lead Assignment
 * @createdby   10KView
 * @date        25th September 2017
 * @changelog   10K 28/11 Removed @future anontation
 *
 *********************************************************************/
public with sharing class LeadAssignmentHandler {

   
    public static void futureLeadReassign(Set<ID> lIdReassignSet) {

        List<Lead> lUpdList = [SELECT Id FROM Lead WHERE Id IN: lIdReassignSet];
        for (Lead l:lUpdList) {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;   // use leadAssignment rules when updating
            l.setOptions(dmo);
        }

        try {
            update(lUpdList);
            
        }
        catch (DmlException e) {/* do something here like send email to sysad with error */}
    }

}