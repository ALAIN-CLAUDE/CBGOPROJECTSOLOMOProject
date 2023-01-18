global class Batch_ReviewAssignment_Scheduler implements Schedulable{
    global void execute(SchedulableContext SC){
        Batch_ReviewAssignment batchJob = new Batch_ReviewAssignment();
        Database.executeBatch(batchJob,50);
    }
}