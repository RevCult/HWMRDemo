/*********************************************************************
 *
 * @description LeadTriggerHandler - extends Trigger framework
 * @createdby   10KView
 * @date        25th September 2017
 *
 *********************************************************************/

public class LeadTriggerHandler extends TriggerHandler {

  public override void afterInsert(){

      Set<Id> leadIds = new Set<Id>();
      for (Lead l: (List<Lead>) Trigger.new ){
            leadIds.add(l.Id);
      }

      if (!leadIds.isEmpty()){
          
          LeadAssignmentHandler.futureLeadReassign(leadIds);
      }
  }

}