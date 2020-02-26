public class ProjectRollUpHandler {
    
    public static void updateCommunityFieldsonInsert(List<Project__c> triggerNew){
        Set<Id> mascommIds = new Set<Id>();
        Set<Id> neighcommIds = new Set<Id>();
        Set<Id> VillcommIds = new Set<Id>();
        for (Project__c project : triggerNew) {
            //   #1 and #5
            if (project.Master_Plan_Community__c != null && project.Neighborhood_Community__c == null && project.Village_Community__c == null ){
                mascommIds.add(project.Master_Plan_Community__c);
            }   
            //   #2
            if (project.Neighborhood_Community__c != null && project.Village_Community__c == null && project.Master_Plan_Community__c == null){
                neighcommIds.add(project.Neighborhood_Community__c);
            } 
            //   #3 and #4
            if ( project.Village_Community__c != null && project.Master_Plan_Community__c == null && project.Neighborhood_Community__c == null ){
                VillcommIds.add(project.Village_Community__c);
            } 
        }
        
        if(!mascommIds.isEmpty()){
            updateOnInsert(triggerNew,mascommIds,'master');
        }
        if(!neighcommIds.isEmpty()){
            updateOnInsert(triggerNew,neighcommIds,'neighbor');
        }
        if(!VillcommIds.isEmpty()){
            updateOnInsert( triggerNew,VillcommIds,'village');
        }
    }
    public static void updateOnInsert(List<Project__c> triggerNew,Set<Id> commIds,string commName){
        List<Community__c> commList = new List<Community__c>();
        List<Community__c> commListtoUpdate = new List<Community__c>();
        if(commName=='master'){
            commList = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c From Community__c Where id IN:commIds];
            if(commList.isEmpty()){
                return;
            }
            for (Project__c prj : triggerNew) {   
                for(Community__c comm : commList){
                    if(prj.Master_Plan_Community__c == comm.id){
                        // For Open Date
                        if(comm.Open_Date__c == null && prj.Open_Date__c != null){
                            comm.Open_Date__c = prj.Open_Date__c;
                        }     
                        else if(comm.Open_Date__c != null && prj.Open_Date__c != null){
                            if(comm.Open_Date__c > prj.Open_Date__c){
                                comm.Open_Date__c = prj.Open_Date__c;
                            }                                
                        }
                        // For Total_Units_Planned
                        if(comm.Project_TUP_calc__c == null)
                            comm.Project_TUP_calc__c =0;
                        if(prj.Total_Units_Planned__c!=null && prj.Total_Units_Planned__c!=0)
                            comm.Project_TUP_calc__c += prj.Total_Units_Planned__c;
                        
                        // For Total_Units_Sold 
                        if(comm.Project_TUS_calc__c == null)
                            comm.Project_TUS_calc__c  =0;
                        if(prj.Total_Units_Sold__c!=null && prj.Total_Units_Sold__c!=0)
                            comm.Project_TUS_calc__c += prj.Total_Units_Sold__c;
                        
                        commListtoUpdate.Add(comm);
                    }
                }
            }
            if(!commListtoUpdate.isempty())           
                Update commListtoUpdate;      
        }
        
        if(commName=='neighbor'){
            commList = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c From Community__c Where id IN:commIds];
            if(commList.isEmpty()){
                return;
            }
            for (Project__c prj : triggerNew) {   
                for(Community__c comm : commList){
                    if(prj.Neighborhood_Community__c == comm.id){
                        // For Open Date
                        if(comm.Open_Date__c == null && prj.Open_Date__c != null){
                            comm.Open_Date__c = prj.Open_Date__c;
                        }     
                        else if(comm.Open_Date__c != null && prj.Open_Date__c != null){
                            if(comm.Open_Date__c > prj.Open_Date__c){
                                comm.Open_Date__c = prj.Open_Date__c;
                            }                                
                        }
                        // For Total_Units_Planned
                        if(comm.Project_TUP_calc__c == null)
                            comm.Project_TUP_calc__c =0;
                        if(prj.Total_Units_Planned__c!=null && prj.Total_Units_Planned__c!=0)
                            comm.Project_TUP_calc__c += prj.Total_Units_Planned__c;
                        
                        // For Total_Units_Sold 
                        if(comm.Project_TUS_calc__c == null)
                            comm.Project_TUS_calc__c  =0;
                        if(prj.Total_Units_Sold__c!=null && prj.Total_Units_Sold__c!=0)
                            comm.Project_TUS_calc__c += prj.Total_Units_Sold__c;
                        
                        commListtoUpdate.Add(comm);
                    }
                }
            }
            if(!commListtoUpdate.isempty())           
                Update commListtoUpdate;      
        }
        if(commName=='village'){
            commList = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c From Community__c Where id IN:commIds];
            if(commList.isEmpty()){
                return;
            }
            for (Project__c prj : triggerNew) {   
                for(Community__c comm : commList){
                    if(prj.Village_Community__c == comm.id){
                        // For Open Date
                        if(comm.Open_Date__c == null && prj.Open_Date__c != null){
                            comm.Open_Date__c = prj.Open_Date__c;
                        }     
                        else if(comm.Open_Date__c != null && prj.Open_Date__c != null){
                            if(comm.Open_Date__c > prj.Open_Date__c){
                                comm.Open_Date__c = prj.Open_Date__c;
                            }                                
                        }
                        // For Total_Units_Planned
                        if(comm.Project_TUP_calc__c == null)
                            comm.Project_TUP_calc__c =0;
                        if(prj.Total_Units_Planned__c!=null && prj.Total_Units_Planned__c!=0)
                            comm.Project_TUP_calc__c += prj.Total_Units_Planned__c;
                        
                        // For Total_Units_Sold 
                        if(comm.Project_TUS_calc__c == null)
                            comm.Project_TUS_calc__c  =0;
                        if(prj.Total_Units_Sold__c!=null && prj.Total_Units_Sold__c!=0)
                            comm.Project_TUS_calc__c += prj.Total_Units_Sold__c;
                        
                        commListtoUpdate.Add(comm);
                    }
                }
            }
            if(!commListtoUpdate.isempty())           
                Update commListtoUpdate;      
        }
    }
    
    public static void updateCommunityFieldsonUpdate(List<Project__c> triggerNew, Map<Id, Project__c> triggerNewMap, List<Project__c> triggerOld, Map<Id, Project__c> triggerOldMap){
        Set<Id> mascommIds = new Set<Id>();
        Set<Id> neighcommIds = new Set<Id>();
        Set<Id> VillcommIds = new Set<Id>();
        Set<Id> masVillcommIds1 = new Set<Id>();
        Set<Id> masVillcommIds2 = new Set<Id>();
        for (Project__c project : triggerNew) {
            //   #6 and #10
            if (project.Master_Plan_Community__c != null && project.Neighborhood_Community__c == null && project.Village_Community__c == null ){
                mascommIds.add(project.Master_Plan_Community__c);
            } 
            if (project.Master_Plan_Community__c == null &&  triggerOldMap.get(project.id).Master_Plan_Community__c!=null){
                mascommIds.add(triggerOldMap.get(project.id).Master_Plan_Community__c);
            }
            //   #7 and #11
            if (project.Neighborhood_Community__c != null && project.Village_Community__c == null && project.Master_Plan_Community__c == null){
                neighcommIds.add(project.Neighborhood_Community__c);
            } 
            
            if (project.Neighborhood_Community__c == null &&  triggerOldMap.get(project.id).Neighborhood_Community__c!=null){
                neighcommIds.add(triggerOldMap.get(project.id).Neighborhood_Community__c);
            }
            //   #8 and #12
            if ( project.Village_Community__c != null && project.Master_Plan_Community__c == null && project.Neighborhood_Community__c == null ){
                VillcommIds.add(project.Village_Community__c);
            } 
            if (project.Village_Community__c == null &&  triggerOldMap.get(project.id).Village_Community__c!=null){
                VillcommIds.add(triggerOldMap.get(project.id).Village_Community__c);
            }
            //   #9 and #13
            if ( project.Village_Community__c != null && project.Master_Plan_Community__c != null && project.Neighborhood_Community__c == null ){
                masVillcommIds1.add(project.Village_Community__c);
                masVillcommIds2.add(project.Master_Plan_Community__c);
            } 
            
        }
        
        if(!mascommIds.isEmpty()){
            updateOnUpdate(triggerNew,mascommIds,'master');
        }
        if(!neighcommIds.isEmpty()){
            updateOnUpdate(triggerNew,neighcommIds,'neighbor');
        }
        if(!VillcommIds.isEmpty()){
            updateOnUpdate(triggerNew,VillcommIds,'village');
        }
        if(!masVillcommIds1.isEmpty()){
            updateOnUpdate(triggerNew,masVillcommIds1,'masvillage1');
        }
        if(!masVillcommIds2.isEmpty()){
            updateOnUpdate(triggerNew,masVillcommIds2,'masvillage2');
        }
    }
    public static void updateOnUpdate(List<Project__c> triggerNew,Set<Id> commIds,string commName){
        List<Community__c> commList = new List<Community__c>();
        List<Community__c> commListtoUpdate = new List<Community__c>();
        List<Community__c> masVillcommList = new List<Community__c>();
        List<Community__c> mascommListtoUpdate = new List<Community__c>();
        if(commName=='master'){
            commList = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c,(select id,Open_Date__c,Total_Units_Sold__c,Total_Units_Planned__c from Projects_Master_Plan__r) From Community__c Where id IN:commIds];
            if(commList.isEmpty()){
                return;
            }
            system.debug('commList=='+commList);
            for(Community__c comm : commList){
                if(comm.Open_date__c != null){
                    if(comm.Projects_Master_Plan__r.size() != 0){
                        for (Project__c prj : comm.Projects_Master_Plan__r) {
                            if (comm.Open_date__c > prj.Open_date__c){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                        }
                    }
                }
                else{
                    if(comm.Projects_Master_Plan__r.size() != 0){
                        // For Open Date
                        comm.Open_date__c = comm.Projects_Master_Plan__r[0].Open_date__c;
                        for (Project__c prj : comm.Projects_Master_Plan__r) {
                            if (comm.Open_date__c > prj.Open_date__c){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                            if(comm.Open_date__c == null){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                        }
                    }
                }
                comm.Project_TUS_calc__c = 0;
                comm.Project_TUP_calc__c = 0;
                if(comm.Projects_Master_Plan__r.size() != 0){
                    // For Open Date
                 //  comm.Open_date__c = comm.Projects_Master_Plan__r[0].Open_date__c;
                    for (Project__c prj : comm.Projects_Master_Plan__r) {
                  //     if (comm.Open_date__c > prj.Open_date__c){
                  //          comm.Open_date__c = prj.Open_date__c;
                  //      }
                  //      if(comm.Open_date__c == null){
                  //          comm.Open_date__c = prj.Open_date__c;
                  //      }
                        // For Total_Units_Planned
                        if(comm.Project_TUP_calc__c == null)
                            comm.Project_TUP_calc__c =0;
                        if(prj.Total_Units_Planned__c!=null && prj.Total_Units_Planned__c!=0)
                            comm.Project_TUP_calc__c += prj.Total_Units_Planned__c;
                        
                        // For Total_Units_Sold 
                        if(comm.Project_TUS_calc__c == null)
                            comm.Project_TUS_calc__c  =0;
                        if(prj.Total_Units_Sold__c!=null && prj.Total_Units_Sold__c!=0)
                            comm.Project_TUS_calc__c += prj.Total_Units_Sold__c;
                        
                    }
                }
                commListtoUpdate.Add(comm);
            }
            if(!commListtoUpdate.isempty())           
                Update commListtoUpdate;
        }
        
        if(commName=='village'){
            commList = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c,(select id,Open_Date__c,Total_Units_Sold__c,Total_Units_Planned__c from Projects_Village__r) From Community__c Where id IN:commIds];
            if(commList.isEmpty()){
                return;
            }
            system.debug('commList=='+commList);
            for(Community__c comm : commList){
               // comm.Open_date__c = null;
               if(comm.Open_date__c != null){
                    if(comm.Projects_Village__r.size() != 0){
                        for (Project__c prj : comm.Projects_Village__r) {
                            if (comm.Open_date__c > prj.Open_date__c){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                        }
                    }
                }
                else{
                    if(comm.Projects_Village__r.size() != 0){
                        // For Open Date
                        comm.Open_date__c = comm.Projects_Village__r[0].Open_date__c;
                        for (Project__c prj : comm.Projects_Village__r) {
                            if (comm.Open_date__c > prj.Open_date__c){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                            if(comm.Open_date__c == null){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                        }
                    }
                }
                comm.Project_TUS_calc__c = 0;
                comm.Project_TUP_calc__c = 0;
                if(comm.Projects_Village__r.size() != 0){
                    // For Open Date
                 //   comm.Open_date__c = comm.Projects_Village__r[0].Open_date__c;
                    for (Project__c prj : comm.Projects_Village__r) {
                   //      if (comm.Open_date__c > prj.Open_date__c){
                   //         comm.Open_date__c = prj.Open_date__c;
                   //     }
                   //     if(comm.Open_date__c == null){
                   //         comm.Open_date__c = prj.Open_date__c;
                   //     }
                        // For Total_Units_Planned
                        if(comm.Project_TUP_calc__c == null)
                            comm.Project_TUP_calc__c =0;
                        if(prj.Total_Units_Planned__c!=null && prj.Total_Units_Planned__c!=0)
                            comm.Project_TUP_calc__c += prj.Total_Units_Planned__c;
                        
                        // For Total_Units_Sold 
                        if(comm.Project_TUS_calc__c == null)
                            comm.Project_TUS_calc__c  =0;
                        if(prj.Total_Units_Sold__c!=null && prj.Total_Units_Sold__c!=0)
                            comm.Project_TUS_calc__c += prj.Total_Units_Sold__c;
                        
                    }
                }
                commListtoUpdate.Add(comm);
            }
            if(!commListtoUpdate.isempty())           
                Update commListtoUpdate;
        }
        
        if(commName=='neighbor'){
            commList = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c,(select id,Open_Date__c,Total_Units_Sold__c,Total_Units_Planned__c from Projects_Neighborhood__r) From Community__c Where id IN:commIds];
            if(commList.isEmpty()){
                return;
            }
            system.debug('commList=='+commList);
            for(Community__c comm : commList){
              //  comm.Open_date__c = null;
                if(comm.Open_date__c != null){
                    if(comm.Projects_Neighborhood__r.size() != 0){
                        for (Project__c prj : comm.Projects_Neighborhood__r) {
                            if (comm.Open_date__c > prj.Open_date__c){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                        }
                    }
                }
                else{
                    if(comm.Projects_Neighborhood__r.size() != 0){
                        // For Open Date
                        comm.Open_date__c = comm.Projects_Neighborhood__r[0].Open_date__c;
                        for (Project__c prj : comm.Projects_Neighborhood__r) {
                            if (comm.Open_date__c > prj.Open_date__c){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                            if(comm.Open_date__c == null){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                        }
                    }
                }
                comm.Project_TUS_calc__c = 0;
                comm.Project_TUP_calc__c = 0;
                if(comm.Projects_Neighborhood__r.size() != 0){
                    // For Open Date
                 //   comm.Open_date__c = comm.Projects_Neighborhood__r[0].Open_date__c;
                    for (Project__c prj : comm.Projects_Neighborhood__r) {
                 //       if (comm.Open_date__c > prj.Open_date__c){
                 //           comm.Open_date__c = prj.Open_date__c;
                 //       }
                //        if(comm.Open_date__c == null){
                //            comm.Open_date__c = prj.Open_date__c;
                //        }
                        // For Total_Units_Planned
                        if(comm.Project_TUP_calc__c == null)
                            comm.Project_TUP_calc__c =0;
                        if(prj.Total_Units_Planned__c!=null && prj.Total_Units_Planned__c!=0)
                            comm.Project_TUP_calc__c += prj.Total_Units_Planned__c;
                        
                        // For Total_Units_Sold 
                        if(comm.Project_TUS_calc__c == null)
                            comm.Project_TUS_calc__c  =0;
                        if(prj.Total_Units_Sold__c!=null && prj.Total_Units_Sold__c!=0)
                            comm.Project_TUS_calc__c += prj.Total_Units_Sold__c;
                        
                    }
                }
                commListtoUpdate.Add(comm);
            }
            if(!commListtoUpdate.isempty())           
                Update commListtoUpdate;
        }
        //
        if(commName=='masvillage2'){
            commList = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c,(select id,Open_Date__c,Total_Units_Sold__c,Total_Units_Planned__c from Projects_Master_Plan__r) From Community__c Where id IN:commIds];
            if(commList.isEmpty()){
                return;
            }
            system.debug('commList=='+commList);
            for(Community__c comm : commList){
              //  comm.Open_date__c = null;
               if(comm.Open_date__c != null){
                    if(comm.Projects_Master_Plan__r.size() != 0){
                        for (Project__c prj : comm.Projects_Master_Plan__r) {
                            if (comm.Open_date__c > prj.Open_date__c){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                        }
                    }
                }
                else{
                    if(comm.Projects_Master_Plan__r.size() != 0){
                        // For Open Date
                        comm.Open_date__c = comm.Projects_Master_Plan__r[0].Open_date__c;
                        for (Project__c prj : comm.Projects_Master_Plan__r) {
                            if (comm.Open_date__c > prj.Open_date__c){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                            if(comm.Open_date__c == null){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                        }
                    }
                }
                comm.Project_TUS_calc__c = 0;
                comm.Project_TUP_calc__c = 0;
                if(comm.Projects_Master_Plan__r.size() != 0){
                    // For Open Date
                   // comm.Open_date__c = comm.Projects_Master_Plan__r[0].Open_date__c;
                    for (Project__c prj : comm.Projects_Master_Plan__r) {
                    //    if (comm.Open_date__c > prj.Open_date__c){
                    //        comm.Open_date__c = prj.Open_date__c;
                    //    }
                    //    if(comm.Open_date__c == null){
                    //        comm.Open_date__c = prj.Open_date__c;
                    //    }
                        // For Total_Units_Planned
                        if(comm.Project_TUP_calc__c == null)
                            comm.Project_TUP_calc__c =0;
                        if(prj.Total_Units_Planned__c!=null && prj.Total_Units_Planned__c!=0)
                            comm.Project_TUP_calc__c += prj.Total_Units_Planned__c;
                        
                        // For Total_Units_Sold 
                        if(comm.Project_TUS_calc__c == null)
                            comm.Project_TUS_calc__c  =0;
                        if(prj.Total_Units_Sold__c!=null && prj.Total_Units_Sold__c!=0)
                            comm.Project_TUS_calc__c += prj.Total_Units_Sold__c;
                        
                    }
                }
                commListtoUpdate.Add(comm);
            }
            if(!commListtoUpdate.isempty())           
                Update commListtoUpdate;
        }
        if(commName=='masvillage1'){
            masVillcommList = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c,(select id,Open_Date__c,Total_Units_Sold__c,Total_Units_Planned__c from Projects_Village__r) From Community__c Where id IN:commIds];
            if(masVillcommList.isEmpty()){
                return;
            }
            system.debug('masVillcommList=='+masVillcommList);
            for(Community__c comm : masVillcommList){
               // comm.Open_date__c = null;
               // if(comm.Open_date__c != null){
                    if(comm.Projects_Village__r.size() != 0){
                        for (Project__c prj : comm.Projects_Village__r) {
                            if (comm.Open_date__c > prj.Open_date__c){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                        }
                    }
                else{
                    if(comm.Projects_Village__r.size() != 0){
                        // For Open Date
                        comm.Open_date__c = comm.Projects_Village__r[0].Open_date__c;
                        for (Project__c prj : comm.Projects_Village__r) {
                            if (comm.Open_date__c > prj.Open_date__c){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                            if(comm.Open_date__c == null){
                                comm.Open_date__c = prj.Open_date__c;
                            }
                        }
                    }
                }
            
                comm.Project_TUS_calc__c = 0;
                comm.Project_TUP_calc__c = 0;
                if(comm.Projects_Village__r.size() != 0){
                    // For Open Date
                  //  comm.Open_date__c = comm.Projects_Village__r[0].Open_date__c;
                    for (Project__c prj : comm.Projects_Village__r) {
                  //      if (comm.Open_date__c > prj.Open_date__c){
                  //          comm.Open_date__c = prj.Open_date__c;
                  //      }
                  //      if(comm.Open_date__c == null){
                  //          comm.Open_date__c = prj.Open_date__c;
                  //      }
                        // For Total_Units_Planned
                        if(comm.Project_TUP_calc__c == null)
                            comm.Project_TUP_calc__c =0;
                        if(prj.Total_Units_Planned__c!=null && prj.Total_Units_Planned__c!=0)
                            comm.Project_TUP_calc__c += prj.Total_Units_Planned__c;
                        
                        // For Total_Units_Sold 
                        if(comm.Project_TUS_calc__c == null)
                            comm.Project_TUS_calc__c  =0;
                        if(prj.Total_Units_Sold__c!=null && prj.Total_Units_Sold__c!=0)
                            comm.Project_TUS_calc__c += prj.Total_Units_Sold__c;
                        
                    }
                }
                mascommListtoUpdate.Add(comm);
            }
            if(!mascommListtoUpdate.isempty())           
                Update mascommListtoUpdate;
        }
    }
    public static void updateCommunityFieldsonDelete(List<Project__c> triggerOld){
        Set<Id> mascommIds = new Set<Id>();
        Set<Id> neighcommIds = new Set<Id>();
        Set<Id> VillcommIds = new Set<Id>();
        Set<Id> masVillcommIds1 = new Set<Id>();
        Set<Id> masVillcommIds2 = new Set<Id>();
        for (Project__c project : triggerOld) {
            //   #1 and #5
            if (project.Master_Plan_Community__c != null && project.Neighborhood_Community__c == null && project.Village_Community__c == null ){
                mascommIds.add(project.Master_Plan_Community__c);
            }   
            //   #2
            if (project.Neighborhood_Community__c != null && project.Village_Community__c == null && project.Master_Plan_Community__c == null){
                neighcommIds.add(project.Neighborhood_Community__c);
            } 
            //   #3 and #4
            if ( project.Village_Community__c != null && project.Master_Plan_Community__c == null && project.Neighborhood_Community__c == null ){
                VillcommIds.add(project.Village_Community__c);
            } 
            
            if ( project.Village_Community__c != null && project.Master_Plan_Community__c != null && project.Neighborhood_Community__c == null ){
                masVillcommIds1.add(project.Village_Community__c);
                masVillcommIds2.add(project.Master_Plan_Community__c);
            } 
        }
        
        if(!mascommIds.isEmpty()){
            updateOnDelete(triggerOld,mascommIds,'master');
        }
        if(!neighcommIds.isEmpty()){
            updateOnDelete(triggerOld,neighcommIds,'neighbor');
        }
        if(!VillcommIds.isEmpty()){
            updateOnDelete( triggerOld,VillcommIds,'village');
        } 
        if(!masVillcommIds1.isEmpty()){
            updateOnDelete(triggerOld,masVillcommIds1,'masvillage1');
        }
        if(!masVillcommIds2.isEmpty()){
            updateOnDelete(triggerOld,masVillcommIds2,'masvillage2');
        }
    }
    public static void updateOnDelete(List<Project__c> triggerOld,Set<Id> commIds,string commName){
        List<Community__c> commList = new List<Community__c>();
        List<Community__c> commListtoUpdate = new List<Community__c>();
        List<Community__c> masVillcommList = new List<Community__c>();
        List<Community__c> mascommListtoUpdate = new List<Community__c>();
        if(commName=='master'){
            commList = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c,(select id,Open_Date__c,Total_Units_Sold__c,Total_Units_Planned__c from Projects_Master_Plan__r) From Community__c Where id IN:commIds];
            if(commList.isEmpty()){
                return;
            }
            for (Project__c prj : triggerOld) {   
                for(Community__c comm : commList){
                    if(prj.Master_Plan_Community__c == comm.id){
                        // For Open Date
                        if(comm.Projects_Master_Plan__r.size() == 0){
                            comm.Open_date__c = null;
                        }
                        else{
                            comm.Open_date__c = comm.Projects_Master_Plan__r[0].Open_date__c;
                            for (Project__c pr : comm.Projects_Master_Plan__r) {
                                if (comm.Open_date__c > pr.Open_date__c){
                                    comm.Open_date__c = pr.Open_date__c;
                                }
                            }
                        }
                        // For Total_Units_Planned
                        if(comm.Project_TUP_calc__c == null)
                            comm.Project_TUP_calc__c =0;
                        if(prj.Total_Units_Planned__c!=null && prj.Total_Units_Planned__c!=0)
                            comm.Project_TUP_calc__c -= prj.Total_Units_Planned__c;
                        
                        // For Total_Units_Sold 
                        if(comm.Project_TUS_calc__c == null)
                            comm.Project_TUS_calc__c  =0;
                        if(prj.Total_Units_Sold__c!=null && prj.Total_Units_Sold__c!=0)
                            comm.Project_TUS_calc__c -= prj.Total_Units_Sold__c;
                        
                        commListtoUpdate.Add(comm);
                    }
                }
            }
            if(!commListtoUpdate.isempty())           
                Update commListtoUpdate;      
        }
        
        if(commName=='neighbor'){
            commList = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c,(select id,Open_Date__c,Total_Units_Sold__c,Total_Units_Planned__c from Projects_Neighborhood__r) From Community__c Where id IN:commIds];
            if(commList.isEmpty()){
                return;
            }
            for (Project__c prj : triggerOld) {   
                for(Community__c comm : commList){
                    if(prj.Neighborhood_Community__c == comm.id){
                        // For Open Date
                        if(comm.Projects_Neighborhood__r.size() == 0){
                            comm.Open_date__c = null;
                        }
                        else{
                            comm.Open_date__c = comm.Projects_Neighborhood__r[0].Open_date__c;
                            for (Project__c pr : comm.Projects_Neighborhood__r) {
                                if (comm.Open_date__c > pr.Open_date__c){
                                    comm.Open_date__c = pr.Open_date__c;
                                }
                            }
                        }
                        // For Total_Units_Planned
                        if(comm.Project_TUP_calc__c == null)
                            comm.Project_TUP_calc__c =0;
                        if(prj.Total_Units_Planned__c!=null && prj.Total_Units_Planned__c!=0)
                            comm.Project_TUP_calc__c -= prj.Total_Units_Planned__c;
                        
                        // For Total_Units_Sold 
                        if(comm.Project_TUS_calc__c == null)
                            comm.Project_TUS_calc__c  =0;
                        if(prj.Total_Units_Sold__c!=null && prj.Total_Units_Sold__c!=0)
                            comm.Project_TUS_calc__c -= prj.Total_Units_Sold__c;
                        
                        commListtoUpdate.Add(comm);
                    }
                }
            }
            if(!commListtoUpdate.isempty())           
                Update commListtoUpdate;      
        }
        if(commName=='village'){
            commList = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c,(select id,Open_Date__c,Total_Units_Sold__c,Total_Units_Planned__c from Projects_Village__r) From Community__c Where id IN:commIds];
            if(commList.isEmpty()){
                return;
            }
            for (Project__c prj : triggerOld) {   
                for(Community__c comm : commList){
                    if(prj.Village_Community__c == comm.id){
                        // For Open Date
                        if(comm.Projects_Village__r.size() == 0){
                            comm.Open_date__c = null;
                        }
                        else{
                            comm.Open_date__c = comm.Projects_Village__r[0].Open_date__c;
                            for (Project__c pr : comm.Projects_Village__r) {
                                if (comm.Open_date__c > pr.Open_date__c){
                                    comm.Open_date__c = pr.Open_date__c;
                                }
                            }
                        }
                        // For Total_Units_Planned
                        if(comm.Project_TUP_calc__c == null)
                            comm.Project_TUP_calc__c =0;
                        if(prj.Total_Units_Planned__c!=null && prj.Total_Units_Planned__c!=0)
                            comm.Project_TUP_calc__c -= prj.Total_Units_Planned__c;
                        
                        // For Total_Units_Sold 
                        if(comm.Project_TUS_calc__c == null)
                            comm.Project_TUS_calc__c  =0;
                        if(prj.Total_Units_Sold__c!=null && prj.Total_Units_Sold__c!=0)
                            comm.Project_TUS_calc__c -= prj.Total_Units_Sold__c;
                        
                        commListtoUpdate.Add(comm);
                    }
                }
            }
            if(!commListtoUpdate.isempty())           
                Update commListtoUpdate;      
        }
        //
        if(commName=='masvillage2'){            
            commList = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c,(select id,Open_Date__c,Total_Units_Sold__c,Total_Units_Planned__c from Projects_Master_Plan__r) From Community__c Where id IN:commIds];
            if(commList.isEmpty()){
                return;
            }
            for (Project__c prj : triggerOld) {   
                for(Community__c comm : commList){
                    if(prj.Master_Plan_Community__c == comm.id){
                        // For Open Date
                        if(comm.Projects_Master_Plan__r.size() == 0){
                            comm.Open_date__c = null;
                        }
                        else{
                            comm.Open_date__c = comm.Projects_Master_Plan__r[0].Open_date__c;
                            for (Project__c pr : comm.Projects_Master_Plan__r) {
                                if (comm.Open_date__c > pr.Open_date__c){
                                    comm.Open_date__c = pr.Open_date__c;
                                }
                            }
                        }
                        // For Total_Units_Planned
                        if(comm.Project_TUP_calc__c == null)
                            comm.Project_TUP_calc__c =0;
                        if(prj.Total_Units_Planned__c!=null && prj.Total_Units_Planned__c!=0)
                            comm.Project_TUP_calc__c -= prj.Total_Units_Planned__c;
                        
                        // For Total_Units_Sold 
                        if(comm.Project_TUS_calc__c == null)
                            comm.Project_TUS_calc__c  =0;
                        if(prj.Total_Units_Sold__c!=null && prj.Total_Units_Sold__c!=0)
                            comm.Project_TUS_calc__c -= prj.Total_Units_Sold__c;
                        
                        commListtoUpdate.Add(comm);
                    }
                }
            }
            if(!commListtoUpdate.isempty())           
                Update commListtoUpdate;  
        }
        if(commName=='masvillage1'){
            masVillcommList = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c,(select id,Open_Date__c,Total_Units_Sold__c,Total_Units_Planned__c from Projects_Village__r) From Community__c Where id IN:commIds];
            if(masVillcommList.isEmpty()){
                return;
            }
            for (Project__c prj : triggerOld) {   
                for(Community__c comm : masVillcommList){
                    if(prj.Village_Community__c == comm.id){
                        // For Open Date
                        if(comm.Projects_Village__r.size() == 0){
                            comm.Open_date__c = null;
                        }
                        else{
                            comm.Open_date__c = comm.Projects_Village__r[0].Open_date__c;
                            for (Project__c pr : comm.Projects_Village__r) {
                                if (comm.Open_date__c > pr.Open_date__c){
                                    comm.Open_date__c = pr.Open_date__c;
                                }
                            }
                        }
                        // For Total_Units_Planned
                        if(comm.Project_TUP_calc__c == null)
                            comm.Project_TUP_calc__c =0;
                        if(prj.Total_Units_Planned__c!=null && prj.Total_Units_Planned__c!=0)
                            comm.Project_TUP_calc__c -= prj.Total_Units_Planned__c;
                        
                        // For Total_Units_Sold 
                        if(comm.Project_TUS_calc__c == null)
                            comm.Project_TUS_calc__c  =0;
                        if(prj.Total_Units_Sold__c!=null && prj.Total_Units_Sold__c!=0)
                            comm.Project_TUS_calc__c -= prj.Total_Units_Sold__c;
                        
                        mascommListtoUpdate.Add(comm);
                    }
                }
            }
            if(!mascommListtoUpdate.isempty())           
                Update mascommListtoUpdate;   
        }
    }
}