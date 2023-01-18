global class Batch_FundingRequest implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query='';
        query  = query + ' ' + SYSTEM.LABEL.Batch_FundingRequest_Query1 ;
        query  = query + ' ' + SYSTEM.LABEL.Batch_FundingRequest_Query2;
        query  = query + ' ' + SYSTEM.LABEL.Batch_FundingRequest_Query3;
        query  = query + ' ' + SYSTEM.LABEL.Batch_FundingRequest_Query4;
        if(TEST.isRunningTest()){
            query = query + ' LIMIT 10';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Funding_Request__c> scope){
        if(System.Label.Batch_FundingRequest_setFundingRequestOwner == 'Run'){
            Batch_FundingRequest_Handler.setFundingRequestOwner(BC.getJobId(),scope);
            Batch_FundingRequest_Handler.updateOwner(BC.getJobId(),scope);
            //Batch_FundingRequest_Handler.sendEmail(BC.getJobId(),scope);
            Batch_FundingRequest_Handler.sendEmailV2(BC.getJobId(),scope);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}