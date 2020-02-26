public with sharing class FC_RegionalDirectorListController {

    public String[] regionalDirectorNames {

        get {
            if (regionalDirectorNames == null) {
                regionalDirectorNames = new List<String>();
                for (AggregateResult ar : [
                        select User__r.Name employeeName
                        from MetrostudySalesRegionAssignment__c
                        where Role__c = 'RD'
                        group by User__r.Name
                        order by User__r.Name asc
                ]) {
                    String employeeName = (String) ar.get('employeeName');
                    if (String.isNotBlank(employeeName)) {
                        regionalDirectorNames.add(employeeName);
                    }
                }
                regionalDirectorNames.sort();
            }
            return regionalDirectorNames;
        }

        private set;

    }

    public FC_RegionalDirectorListController() {
    }

}