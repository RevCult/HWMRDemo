/*****************************************************************************
 *
 * @description LeadTrigger - Simple trigger which calls main handler
 * @createdby   10KView
 * @date        25th September 2017
 *
 ****************************************************************************/

trigger LeadTrigger on Lead (after insert) {

    new LeadTriggerHandler().Run(); 
}