global class Batch_FundingRequest_SCHEDULER implements Schedulable{
    global void execute(SchedulableContext SC){
        Batch_FundingRequest batchFundingReq = new Batch_FundingRequest();
        Database.executeBatch(batchFundingReq,200);
    }
}