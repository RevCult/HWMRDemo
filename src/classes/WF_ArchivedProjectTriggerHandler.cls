/**
** Created Date : 27 June 2016
** Author : Mohit Gupta (Rainmaker)
*/
public class WF_ArchivedProjectTriggerHandler {
    
    public static void onAfterUpdate(list<WF_Archived_Project__c> newArchivedProjectList) {
        List<String> listProjectsIdsToDelete= new List<String>();
        for(WF_Archived_Project__c archivedProject : newArchivedProjectList) {
            if(archivedProject.Process_Done__c) {
                listProjectsIdsToDelete.add(archivedProject.Id);
            }
        }   
        deleteRecords(listProjectsIdsToDelete);
    }
    
    @future(callout=true)
    public static void deleteRecords(list<String> listProjectsIdsToDelete) {
        List<WF_Archived_Project__c> listProjectsToDelete= new List<WF_Archived_Project__c>();
        for(String archivedProject : listProjectsIdsToDelete) {
            listProjectsToDelete.add(new WF_Archived_Project__c(Id = archivedProject));
        }
        delete listProjectsToDelete;
    }
    
}