public with sharing class MaintProjectFields {
    public static List<Project__c> updateThreeMonthSalesRate(List<Project__c> scope) {
        List<Project_Snapshot__c> allSnapsForScope = [SELECT Id, Total_Units_Sold__c, Last_Updated_Date_Sales__c, Project__c, CreatedDate FROM Project_Snapshot__c WHERE Project__c IN :scope];
        //system.debug('allSnapsForScope.size(): ' + allSnapsForScope.size());
        List<Project__c> projectsToUpdate = new List<Project__c>();
		system.debug(' ***scope**'+scope);
        if (!allSnapsForScope.isEmpty()) {
            Map<Id, List<Project_Snapshot__c>> mapProjectToSnaps = new Map<Id, List<Project_Snapshot__c>>();
            for (Project_Snapshot__c snap : allSnapsForScope) {
                if (null != snap.Total_Units_Sold__c) {
                    if (!mapProjectToSnaps.containsKey(snap.Project__c)) {
                        mapProjectToSnaps.put(snap.Project__c, new List<Project_Snapshot__c>());
                        mapProjectToSnaps.get(snap.Project__c).add(snap);
                    } else {
                        mapProjectToSnaps.get(snap.Project__c).add(snap);
                    }   
                }
            }
            system.debug('mapProjectToSnaps: '+mapProjectToSnaps);
            for (Project__c p : scope) {
              //    if (p.Id == null){
                    /*  if(p.Update_Cycle__c != null && p.id!=null){
                   			 list<Project_Update_Request__c> po = [Select Update_Request_Status__c, Project__c, Project_Name__c, Name, LastModifiedDate, Id From Project_Update_Request__c where Project__c=:p.id and Update_Request_Status__c='approved' order by LastModifiedDate desc ];
                        if(po.size()>0){
                        	p.ZIC_Date__c = date.valueOf(po[0].LastModifiedDate).addDays(integer.valueOf(p.Update_Cycle__c));
              			}else{
              			
              				p.ZIC_Date__c = date.valueOf(p.lastModifiedDate.addDays(integer.valueOf(p.Update_Cycle__c)));
              			}
                   }*/
            //}
            system.debug('here ');
                if (null != p.Total_Units_Sold__c) {
                    Date comparisonDate = null;
                    Date targetDate = null;
                    // determine whether to use Last_Updated_Date_Sales__c or Sold_Out_Date__c for comparison logic [use Sold_Out_Date__c if it's populated]
                    if (p.Sold_Out_Date__c != null) {
                        comparisonDate = p.Sold_Out_Date__c;
                        targetDate = p.Sold_Out_Date__c.addDays(-90);
                    } else if (p.Last_Updated_Date_Sales__c != null) {
                        comparisonDate = p.Last_Updated_Date_Sales__c;
                        targetDate = p.Last_Updated_Date_Sales__c.addDays(-90);
                    } else {
                        continue;
                    }
                    system.debug('comparisonDate: ' + comparisonDate);
                    system.debug('targetDate: ' + targetDate);
                    // go get all the Project_Snapshot__c records for the Project
                    List<Project_Snapshot__c> snapsForProject = new List<Project_Snapshot__c>();
                    snapsForProject = mapProjectToSnaps.get(p.Id);
                    if (snapsForProject != null && !snapsForProject.isEmpty()) {
                        Date oldestDate = null;
                        Project_Snapshot__c oldestSnap = new Project_Snapshot__c();
                        // determine the snapshot that is closest to 90 days old...
                        for (Project_Snapshot__c snap : snapsForProject) {
                            // don't calculate based on snapshots with obviously bad data
                            if (snap.Total_Units_Sold__c <= p.Total_Units_Sold__c && snap.Total_Units_Sold__c <= p.Total_Units_Planned__c && snap.Last_Updated_Date_Sales__c >= p.Open_Date__c) {
                                system.debug('Math.abs(snap.Last_Updated_Date_Sales__c.daysBetween(targetDate)): '+Math.abs(snap.Last_Updated_Date_Sales__c.daysBetween(targetDate)));
                                // only use snapshots that are between 2 and 4 months old
                                if (Math.abs(snap.Last_Updated_Date_Sales__c.daysBetween(targetDate)) <= 30) {
                                    if (null == oldestDate) {
                                        oldestDate = snap.Last_Updated_Date_Sales__c;
                                        oldestSnap = snap;
                                    } else if (Math.abs(snap.Last_Updated_Date_Sales__c.daysBetween(targetDate)) < Math.abs(snap.Last_Updated_Date_Sales__c.daysBetween(oldestDate))) {
                                        oldestDate = snap.Last_Updated_Date_Sales__c;
                                        oldestSnap = snap;
                                    }
                                }
                                //system.debug('rangeToReview: '+rangeToReview);
                            }
                        }

                        system.debug('oldestDate: '+oldestDate);
                        system.debug('oldestSnap: '+oldestSnap);
                        // calculation should be:
                        // units sold in time period / (num of days in time period / (7 * 4.3)))
                        if (oldestDate != null) {
                            Decimal daysInTimePeriod = (Math.abs(comparisonDate.daysBetween(oldestSnap.Last_Updated_Date_Sales__c))); //(comparisonDate.getTime() - oldestSnap.Last_Updated_Date_Sales__c.getTime())/(1000*60*60*24))+1;
                            system.debug('daysInTimePeriod: '+daysInTimePeriod);
                            Decimal monthsInTimePeriod = daysInTimePeriod / (7*4.3);
                            system.debug('monthsInTimePeriod: '+monthsInTimePeriod);
                            Integer unitsSoldInTimePeriod = (Integer)(p.Total_Units_Sold__c - oldestSnap.Total_Units_Sold__c);
                            system.debug('unitsSoldInTimePeriod: '+unitsSoldInTimePeriod);
                            p.Sales_Rate_Last_3_Months_calc__c = unitsSoldInTimePeriod/monthsInTimePeriod;
                            projectsToUpdate.add(p);
                        } else {
                            p.Sales_Rate_Last_3_Months_calc__c = null;
                            projectsToUpdate.add(p);
                        }
                    } else { // the project has no snapshots - so we can't calculate a rate
                        system.debug('the project has no snapshots - so we can\'t calculate a rate');
                        p.Sales_Rate_Last_3_Months_calc__c = null;
                        projectsToUpdate.add(p);
                    }
                } else { // the project has a null value for Total Units Sold - so we can't calculate a rate
                    p.Sales_Rate_Last_3_Months_calc__c = null;
                    projectsToUpdate.add(p);
                }
            }
            
            
        } else { // the project has no snapshots - so we can't calculate a rate
            for (Project__c p : scope) {
                p.Sales_Rate_Last_3_Months_calc__c = null;
                   
                   if(p.Update_Cycle__c != null && p.id==null){
                   		p.ZIC_Date__c = System.today().addDays(Integer.valueOf(p.Update_Cycle__c));
                   }
                   system.debug('*****99');
                  
         
                projectsToUpdate.add(p);    
            }
        }
        if (!projectsToUpdate.isEmpty()) {
            return projectsToUpdate;    
            //system.debug('projectsToUpdate: ' + projectsToUpdate);
        } else {
            return null;
        }
    }
}

/**
    --  HERE LIES OLD LOGIC - RIP 04.09.2015
*/

   //       if (!allSnapsForScope.isEmpty()) {
   //           Map<Id, List<Project_Snapshot__c>> mapProjectToSnaps = new Map<Id, List<Project_Snapshot__c>>();
   //           for (Project_Snapshot__c snap : allSnapsForScope) {
   //               if (null != snap.Total_Units_Sold__c) {
   //                   if (!mapProjectToSnaps.containsKey(snap.Project__c)) {
      //                    mapProjectToSnaps.put(snap.Project__c, new List<Project_Snapshot__c>());
      //                    mapProjectToSnaps.get(snap.Project__c).add(snap);
      //                } else {
      //                    mapProjectToSnaps.get(snap.Project__c).add(snap);
      //                }   
   //               }
   //           }
   //           system.debug('mapProjectToSnaps: '+mapProjectToSnaps);
   //           for (Project__c p : scope) {
   //               if (null != p.Total_Units_Sold__c) {
   //                   Datetime comparisonDate = null;
            //      // determine whether to use Last_Updated_Date_Sales__c or Sold_Out_Date__c for comparison logic [use Sold_Out_Date__c if it's populated]
            //      if (p.Sold_Out_Date__c != null) {
            //          comparisonDate = p.Sold_Out_Date__c;
            //      } else if (p.Last_Updated_Date_Sales__c != null) {
            //          comparisonDate = p.Last_Updated_Date_Sales__c;
            //      } else {
            //          continue;
            //      }
            //      //system.debug('comparisonDate: ' + comparisonDate);
            //      // go get all the Project_Snapshot__c records for the Project
            //      List<Project_Snapshot__c> snapsForProject = new List<Project_Snapshot__c>();
            //      snapsForProject = mapProjectToSnaps.get(p.Id);
            //      if (snapsForProject != null && !snapsForProject.isEmpty()) {
            //          Datetime oldestDate = null;
            //          String rangeToReview = '';
            //          Project_Snapshot__c oldestSnap = new Project_Snapshot__c();
            //          // determine the snapshot that is closest to 90 days old...
            //          for (Project_Snapshot__c snap : snapsForProject) {
            //              // don't calculate based on snapshots with obviously bad data
            //              if (snap.Total_Units_Sold__c <= p.Total_Units_Sold__c && snap.Total_Units_Sold__c <= p.Total_Units_Planned__c && snap.CreatedDate >= p.Open_Date__c) {
            //                  // only use snapshots that are between 2 and 4 months old
            //                  // if there are snapshots newer than 120 days before the comparison date and older than 90 days before the comparison date, get the newest snapshot in that window
            //                  // else if there are snapshots newer than 90 days before the comparison date and older than 60 days before the comparison date, get the oldest snapshot in that window
            //                  if (snap.CreatedDate > comparisonDate.addDays(-120) && snap.CreatedDate < comparisonDate.addDays(-60)) { // this one's worth looking at at all
            //                      if (snap.CreatedDate < comparisonDate.addDays(-90)) {
            //                          rangeToReview = '90to120';
            //                          break;
            //                      } else {
            //                          rangeToReview = '60to90';
            //                      }
            //                  }
            //                  //system.debug('rangeToReview: '+rangeToReview);
            //              }
            //          }

            //          for (Project_Snapshot__c snap : snapsForProject) {
            //              if (rangeToReview == '60to90') {
            //                  if (snap.CreatedDate > comparisonDate.addDays(-90) && snap.CreatedDate < comparisonDate.addDays(-60)) {
            //                      if (oldestDate == null || snap.CreatedDate < oldestDate) {
            //                          oldestDate = snap.CreatedDate;
            //                          oldestSnap = snap;
            //                      }
            //                  }
            //              } else if (rangeToReview == '90to120') {
            //                  if (snap.CreatedDate > comparisonDate.addDays(-120) && snap.CreatedDate < comparisonDate.addDays(-90)) {
            //                      if (oldestDate == null || snap.CreatedDate > oldestDate) {
            //                          oldestDate = snap.CreatedDate;
            //                          oldestSnap = snap;
            //                      }
            //                  }
            //              }
            //          }
            //          system.debug('rangeToReview after loop is done: '+rangeToReview);
            //          system.debug('oldestDate: '+oldestDate);
            //          system.debug('oldestSnap: '+oldestSnap);
            //          // calculation should be:
            //          // units sold in time period / (num of days in time period / (7 * 4.3)))
            //          if (oldestDate != null) {
            //              Decimal daysInTimePeriod = ((comparisonDate.getTime() - oldestSnap.CreatedDate.getTime())/(1000*60*60*24))+1;
            //              system.debug('daysInTimePeriod: '+daysInTimePeriod);
            //              Decimal monthsInTimePeriod = daysInTimePeriod / (7*4.3);
            //              system.debug('monthsInTimePeriod: '+monthsInTimePeriod);
            //              Integer unitsSoldInTimePeriod = (Integer)(p.Total_Units_Sold__c - oldestSnap.Total_Units_Sold__c);
            //              system.debug('unitsSoldInTimePeriod: '+unitsSoldInTimePeriod);
            //              p.Sales_Rate_Last_3_Months_calc__c = unitsSoldInTimePeriod/monthsInTimePeriod;
            //              projectsToUpdate.add(p);
            //          } else {
            //              p.Sales_Rate_Last_3_Months_calc__c = null;
            //              projectsToUpdate.add(p);
            //          }
            //      } else { // the project has no snapshots - so we can't calculate a rate
            //          system.debug('the project has no snapshots - so we can\'t calculate a rate');
            //          p.Sales_Rate_Last_3_Months_calc__c = null;
            //          projectsToUpdate.add(p);
            //      }
            //  } else { // the project has a null value for Total Units Sold - so we can't calculate a rate
            //      p.Sales_Rate_Last_3_Months_calc__c = null;
            //      projectsToUpdate.add(p);
            //  }
            //}
   //       } else { // the project has no snapshots - so we can't calculate a rate
   //           for (Project__c p : scope) {
   //               p.Sales_Rate_Last_3_Months_calc__c = null;
            //  projectsToUpdate.add(p);    
   //           }
   //       }