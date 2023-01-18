/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_ObjectiveLD_trigger on Objective__c (after update){
    disco.Util.updateAnswersInLinkedSections(trigger.new,'Objective__c');
}