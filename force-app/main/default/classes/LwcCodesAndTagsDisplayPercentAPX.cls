/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-04-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class LwcCodesAndTagsDisplayPercentAPX {

    @AuraEnabled(cacheable=true)
    public static  list<Code_and_Tag__c> getLwcCodesAndTags() {
     
		   set<string> childName = new set<string>();
			 set<string> parentId = new set<string>();
 


        list<Related_Code_and_Tag__c> relCodnTagList = [SELECT Id,Code_and_Tag__r.name,Code_and_Tag__c,Code_and_Tag__r.Code_and_Tag__r.name  FROM Related_Code_and_Tag__c where Funding_Opportunity__c = 'a0k5e000006sFFiAAM'];

        system.debug('relCodnTagList====> '+relCodnTagList);
        
        for(Related_Code_and_Tag__c rct:relCodnTagList){
         
            parentId.add(rct.Code_and_Tag__r.Code_and_Tag__r.id);
            childName.add(rct.Code_and_Tag__r.name);
            
        
         system.debug(' parent====> '+   rct.Code_and_Tag__r.Code_and_Tag__r.name + ' Child Code name====> '+rct.Code_and_Tag__r.name);
        }  



         List<Code_and_Tag__c> listChildTags = [Select Id,name,Code_and_Tag__r.name,(Select Id,Name FROM Code_and_Tags__r where name in :childName)
                FROM Code_and_Tag__c
                WHERE id in : parentId];

        system.debug('listChildTags====> '+listChildTags);

        return listChildTags;
    }
}