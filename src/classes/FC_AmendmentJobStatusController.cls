public without sharing class FC_AmendmentJobStatusController {

    public Id amendmentJobId { get; set; }

    public AsyncApexJob job {

        get {
            if (job == null && amendmentJobId != null) {
                for (AsyncApexJob asyncApexJobRecord : [
                        select Id, Status, ExtendedStatus
                        from AsyncApexJob
                        where Id = :amendmentJobId
                        limit 1
                ]) {
                    job = asyncApexJobRecord;
                }
            }
            return job;
        }

        private set;

    }

    public String jobStatus {

        get {
            return job != null ? (String.isBlank(jobExtendedStatus) ? job.Status : 'Error') : '';
        }

        private set;

    }

    public String jobExtendedStatus {

        get {
            jobExtendedStatus = '';
            if (job != null) {
                jobExtendedStatus = job.ExtendedStatus;
                if (String.isBlank(jobExtendedStatus)) {
                    for (fcf__Exception_Log__c exceptionLogRecord : [
                            select Id, fcf__Type__c, fcf__Message__c
                            from fcf__Exception_Log__c
                            where fcf__Related_To_ID__c = :job.Id
                            limit 1
                    ]) {
                        jobExtendedStatus = String.format('{0}: {1}', new String[]{
                                exceptionLogRecord.fcf__Type__c,
                                exceptionLogRecord.fcf__Message__c
                        });
                    }
                }
            }
            return jobExtendedStatus;
        }

        private set;

    }

    public Boolean isJobRunning {

        get {
            return job != null && (new Set<String>{
                    'Queued', 'Processing', 'Preparing', 'Holding'
            }).contains(job.Status);
        }

        private set;

    }

    public FC_AmendmentJobStatusController() {
    }

    public void refresh() {
        this.job = null;
    }

}