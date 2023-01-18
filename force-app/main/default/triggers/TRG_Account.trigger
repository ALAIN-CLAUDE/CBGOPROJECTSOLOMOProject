trigger TRG_Account on Account (before insert, after insert, before update, after update, before delete, after delete) {
    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            if(SYSTEM.LABEL.TRG_Account_createAccountSPAJoiner =='Run'){
                TRG_Account_Handler.createAccountSPAJoiner(Trigger.New);
            }
        }
    }
    
    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            if(SYSTEM.LABEL.TRG_Account_assignHomeSPA =='Run'){
                TRG_Account_Handler.assignHomeSPA(Trigger.New);
            }
        }
    }
}