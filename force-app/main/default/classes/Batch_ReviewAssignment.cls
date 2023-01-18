global class Batch_ReviewAssignment implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = '';
        query  = query + ' ' + SYSTEM.LABEL.Batch_ReviewAssignment_Query1;
        query  = query + ' ' + SYSTEM.LABEL.Batch_ReviewAssignment_Query2;
        query  = query + ' ' + SYSTEM.LABEL.Batch_ReviewAssignment_Query3;
        query  = query + ' ' + SYSTEM.LABEL.Batch_ReviewAssignment_Query4;
        if(Test.isRunningTest()){
            query  = SYSTEM.LABEL.Batch_ReviewAssignment_TEST;
        }
        
        
        system.debug('query --'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Review_Assignment__c> listReviewAssignments){
        //system.debug('listReviewAssignments--'+listReviewAssignments);
        if(SYSTEM.LABEL.Batch_ReviewAssignment_createShareRecords == 'Run'){
            Batch_ReviewAssignment_Handler.changeOwnerForRevAssignAndFundingReq(BC.getJobId(), listReviewAssignments);
            Batch_ReviewAssignment_Handler.createFundingRequestShareRecords(BC.getJobId(), listReviewAssignments);
            Batch_ReviewAssignment_Handler.createReviewAssignmentShareRecords(BC.getJobId(), listReviewAssignments);
            //Batch_ReviewAssignment_Handler.updateOwner(BC.getJobId(), listReviewAssignments);
            //Jennifer submitted a change request to remove automation that sends email.
            //Batch_ReviewAssignment_Handler.sendEmails(BC.getJobId(), listReviewAssignments);
        }
    }
    global void finish(Database.BatchableContext BC){
    }
}