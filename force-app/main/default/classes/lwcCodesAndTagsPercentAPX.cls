/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-18-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public  with sharing class lwcCodesAndTagsPercentAPX {

@AuraEnabled(cacheable=true)
public static List<Related_Code_and_Tag__c>  getRelatedCodesAndTags(ID recordId){

 
    

    String queryString = 'SELECT Id,name,Allocation_Amount__c,Allocation__c,Code_and_Tag__c,Code_and_Tag__r.name,Code_and_Tag__r.recordType.name,Code_and_Tag__r.Code_and_Tag__c,Code_and_Tag__r.Code_and_Tag__r.name FROM Related_Code_and_Tag__c where '+recordIdSObjectType1+'= :recordId';


    List<Related_Code_and_Tag__c> lstCodeTagsToCreate = Database.query(queryString);
    return lstCodeTagsToCreate;
}

@AuraEnabled
public static String createRelatedCodeTags(String recordId, List<RelatedCodeTags> lstCodeTags ){
    System.debug(lstCodeTags);
    List<SaveResult_APX> listSaveResultsAPX =  new List<SaveResult_APX>();
    List<Related_Code_and_Tag__c> listInsertRelatedCodesAndTags = new List<Related_Code_and_Tag__c>();
    Schema.SObjectField relatedCodeAndTagRelationshipField;

    system.debug('recordId=============> '+recordId);
    if(recordId!=null && recordId!=''){
        Schema.SObjectType recordIdSObjectType = Id.valueOf(recordId).getSObjectType();
        Schema.DescribeSObjectResult sobjectDescribeResult = Related_Code_and_Tag__c.SObjectType.getDescribe();
        Map<String,Schema.SObjectField> fieldResultMap = sobjectDescribeResult.fields.getMap();
        if(fieldResultMap!=null && !fieldResultMap.isEmpty()){
            for(string fieldStr : fieldResultMap.keySet()){
                Schema.SObjectField field = fieldResultMap.get(fieldStr);
                Schema.DescribeFieldResult fieldDescRes = field.getDescribe();
                List<Schema.SObjectType> listSObjectTypes = fieldDescRes.getReferenceTo();
                if(listSObjectTypes!=null && !listSObjectTypes.isEmpty()){
                    if(listSObjectTypes[0] == recordIdSObjectType){
                        relatedCodeAndTagRelationshipField = field;
                    }
                }
            }
        }   
    }
    if(lstCodeTags!=null && !lstCodeTags.isEmpty()){
        system.debug('5.');
        for(RelatedCodeTags codentagLst : lstCodeTags){
            Related_Code_and_Tag__c relCodeAndTagRec = new Related_Code_and_Tag__c();
            relCodeAndTagRec.Code_and_Tag__c = codentagLst.codeId;
            relCodeAndTagRec.Allocation__c = codentagLst.allocation;
            relCodeAndTagRec.put(relatedCodeAndTagRelationshipField, recordId);
            relCodeAndTagRec.External_ID__c = codentagLst.codeId + '-' + recordId;
            listInsertRelatedCodesAndTags.add(relCodeAndTagRec);
        }
    }
    try {
        if(listInsertRelatedCodesAndTags!=null && !listInsertRelatedCodesAndTags.isEmpty()){

            // listSaveResultsAPX =  SaveResult_APX.saveResultInsert(listInsertRelatedCodesAndTags);
            listSaveResultsAPX =  SaveResult_APX.saveResultUpsert(listInsertRelatedCodesAndTags, 'Related_Code_and_Tag__c', 'External_ID__c');
        }
        return 'success';

    }catch(Exception e){

    System.debug('Error from ApexController Method' + e.getMessage());
    return e.getMessage();

    }




    /*
    List<Related_Code_and_Tag__c> lstCodeTagsToCreate = new List<Related_Code_and_Tag__c>();
    String sObjName = recordId.getSObjectType().getDescribe().getName();
    for(RelatedCodeTags codeTag :lstCodeTags){
            Related_Code_and_Tag__c rec = new Related_Code_and_Tag__c();
            rec.Allocation__c= codeTag.allocation;
            rec.Code_and_Tag__c = codeTag.codeId;
            if (sObjName == 'Funding_Opportunity__c') {
                rec.Funding_Opportunity__c = recordId;
            }
            else if (sObjName == 'Funding_Request__c') {
                rec.Funding_Request__c = recordId;
            }
            else if (sObjName == 'Sponsorship_Request__c') {
                rec.Sponsorship_Request__c = recordId;
            }
            lstCodeTagsToCreate.add(rec);
        }
    insert lstCodeTagsToCreate;
    return 'sucess';
    */
    //  return 'sucess';
}

public class RelatedCodeTags{
    @AuraEnabled
    public string codeId{get;set;}
    @AuraEnabled
    public Decimal allocation{get;set;}   
} 


@AuraEnabled
public static String delSelectedCodeTags(ID recordId,string tagName){

    system.debug('tagName===============================> '+ tagName);
    system.debug('recordId================================> '+ recordId);

    Schema.SObjectType recordIdSObjectType1 = Id.valueOf(recordId).getSObjectType();


    String queryString = 'SELECT Id,name FROM Related_Code_and_Tag__c where Code_and_Tag__r.name =: tagName and '+recordIdSObjectType1+'= :recordId';
    
    List<Related_Code_and_Tag__c> lstCodeTagsToDelete = Database.query(queryString);

    system.debug('lstCodeTagsToDelete================================> '+lstCodeTagsToDelete);
    try {
        delete lstCodeTagsToDelete;
        return 'success';

    }catch(Exception e){

    System.debug('Error from ApexController Method' + e.getMessage());
    return e.getMessage();

    }

}

}