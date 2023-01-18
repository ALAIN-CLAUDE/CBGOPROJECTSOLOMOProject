trigger TRG_Apex_Integration on APEX_Integration_Trigger__c (after insert) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            if(System.label.TRG_APEX_Integration_runApxJob=='Run'){
                TRG_Apex_Integration_Handler.runApxJob(Trigger.new);
            }
        }
    }
}