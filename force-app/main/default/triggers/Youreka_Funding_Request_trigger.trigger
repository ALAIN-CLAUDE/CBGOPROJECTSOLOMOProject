/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_Funding_Request_trigger on Funding_Request__c (after update){
    disco.Util.updateObjectsFieldLinkAnswers(trigger.new,'Funding_Request__c');
}