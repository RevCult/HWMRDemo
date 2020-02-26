trigger trgProjects on Project__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

//Disable logic is added to allow for bulk imports as needed.    
hw_settings__c settings = hw_settings__c.getInstance();
Boolean isOff = settings.Bypass_Research_Triggers__c;

if(! isOff)
{
    String triggerContext = '';


    if (Trigger.isBefore) {
        triggerContext = 'before';
    } else {
        triggerContext = 'after';
    }

    if (Trigger.isInsert) {
        triggerContext += 'insert';
    } else if (Trigger.isUpdate) {
        triggerContext += 'update';
    } else if (Trigger.isDelete) {
        triggerContext += 'delete';
    } else {
        triggerContext += 'undelete';
    }

    if (!System.isBatch() && !System.isFuture()) {
        
     // Before Insert
        if ('beforeinsert' == triggerContext) {
            system.debug('BeforeInsert action');
            trgProjectsHandler.SetAccountFromBuilder(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            MaintProjectFields.updateThreeMonthSalesRate(Trigger.new);
            

    // Before Update            
        } else if ('beforeupdate' == triggerContext) {
            system.debug('BeforeUpdate action');
            for(Project__c newProject : trigger.new){
                Project__c oldProject = Trigger.oldMap.get(newProject.Id);
                if (oldProject.Builder__c != newProject.Builder__c){
                    system.debug('BeforeUpdate - Set Account from Builder');
                    trgProjectsHandler.SetAccountFromBuilder(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                }
            }
            //trgProjectsHandler.SetAccountFromBuilder(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            MaintProjectFields.updateThreeMonthSalesRate(Trigger.new);
            

     // After Insert
        } else if ('afterinsert' == triggerContext) {
            //trgProjectsHandler.UpdateDataFromGoogle(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            system.debug('AfterInsert action');
            for(Project__c newProject : trigger.new){
                    //system.debug('Project New Location Lat: ' + newProject.Location__Latitude__s);
                    //system.debug('Project New Location Long: ' + newProject.Location__Longitude__s);
                    //system.debug('Project New Website: ' + newProject.Website__c);
            
                if (newProject.Location__Latitude__s != NULL || newProject.Location__Longitude__s != NULL || newProject.Website__c != NULL ){
                    system.debug('After Insert Action: Location or Website change - hit google');
                    trgProjectsHandler.UpdateDataFromGoogle(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                }
                
                    //system.debug('Project New Master Plan: ' + newProject.Master_Plan_Community__c);
                    //system.debug('Project New Neighborhood: ' + newProject.Neighborhood_Community__c);
                    //system.debug('Project New Village: ' + newProject.Village_Community__c);
                    
                    //system.debug('Project New TUP: ' + newProject.Total_Units_Planned__c);
                    //system.debug('Project New TUS: ' + newProject.Total_Units_Sold__c);
                if ( newProject.Master_Plan_Community__c != NULL 
                    || newProject.Neighborhood_Community__c != NULL
                    || newProject.Village_Community__c != NULL ){
                        system.debug('Community change - hit Rollup Trigger - Insert');
                        ProjectRollUpHandler.updateCommunityFieldsonInsert(Trigger.new);
                        system.debug('RollUpHandler - Insert');
                }
            }
    // After Update:
        } else if ('afterupdate' == triggerContext) { 
            system.debug('AfterUpdate action');
            trgProjectsHandler.CreateProjectSnapshots(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            trgProjectsHandler.UpdateDataUsers(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            trgProjectsHandler.UpdateAllActivePURsWhenProjectIsUpdated(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

            for(Project__c newProject : trigger.new){
                    //system.debug('Project New Location Lat: ' + newProject.Location__Latitude__s);
                    //system.debug('Project New Location Long: ' + newProject.Location__Longitude__s);
                    //system.debug('Project New Website: ' + newProject.Website__c);
                    
                    //system.debug('Project New Master Plan: ' + newProject.Master_Plan_Community__c);
                    //system.debug('Project New Neighborhood: ' + newProject.Neighborhood_Community__c);
                    //system.debug('Project New Village: ' + newProject.Village_Community__c);
                    
                    //system.debug('Project New TUP: ' + newProject.Total_Units_Planned__c);
                    //system.debug('Project New TUS: ' + newProject.Total_Units_Sold__c);
        
                Project__c oldProject = Trigger.oldMap.get(newProject.Id);  //Old Map does not exist for Insert 
                    //system.debug('Project Old Location Lat: ' + oldProject.Location__Latitude__s);
                    //system.debug('Project Old Location Long: ' + oldProject.Location__Longitude__s);
                    //system.debug('Project Old Website: ' + oldProject.Website__c);
                    
                    //system.debug('Project Old Master Plan: ' + oldProject.Master_Plan_Community__c);
                    //system.debug('Project Old Neighborhood: ' + oldProject.Neighborhood_Community__c);
                    //system.debug('Project Old Village: ' + oldProject.Village_Community__c);
                    
                    //system.debug('Project Old TUP: ' + oldProject.Total_Units_Planned__c);
                    //system.debug('Project Old TUS: ' + oldProject.Total_Units_Sold__c);

                if (oldProject.Location__Latitude__s != newProject.Location__Latitude__s || oldProject.Location__Longitude__s != newProject.Location__Longitude__s || oldProject.Website__c != newProject.Website__c ){
                    system.debug('After Update Action: Location or website change - hit google');
                    trgProjectsHandler.UpdateDataFromGoogle(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                }
                
                if ( oldProject.Master_Plan_Community__c != newProject.Master_Plan_Community__c 
                    || oldProject.Neighborhood_Community__c != newProject.Neighborhood_Community__c 
                    || oldProject.Village_Community__c != newProject.Village_Community__c 
                    || oldProject.Total_Units_Planned__c != newProject.Total_Units_Planned__c
                    || oldProject.Total_Units_Sold__c != newProject.Total_Units_Sold__c ){
                        system.debug('After Update Action: Community change - hit Rollup Trigger - Update');
                        ProjectRollUpHandler.updateCommunityFieldsonUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                        system.debug('RollUpHandler - Update');             
                }
            }
                
    // After Delete            
        } else if(triggerContext == 'afterdelete'){
            system.debug('AfterDelete Action');
            for(Project__c oldProject : trigger.old){ 
                //system.debug('Project Old Master Plan: ' + oldProject.Master_Plan_Community__c);
                //system.debug('Project Old Neighborhood: ' + oldProject.Neighborhood_Community__c);
                //system.debug('Project Old Village: ' + oldProject.Village_Community__c);

                if (oldProject.Master_Plan_Community__c != NULL || oldProject.Neighborhood_Community__c != NULL || oldProject.Village_Community__c != NULL ){
                    ProjectRollUpHandler.updateCommunityFieldsonDelete(Trigger.old);
                    system.debug('ProjectRollUpHandler - Delete');
                }
            }
        } 
    }
}
}