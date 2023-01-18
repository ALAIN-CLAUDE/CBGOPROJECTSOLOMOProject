public with sharing class lwcTagsAPX {
    @AuraEnabled
    public static List<TagCls> getParentTagsAPX(){
        List<TagCls> listParentTagClsRecs = new List<TagCls>();
        List<Code_and_Tag__c> listParentTags = [Select Id,Name,(Select Id,Name FROM Code_and_Tags__r LIMIT 200)
        FROM Code_and_Tag__c
        WHERE Code_and_Tag__c=null
        AND RecordType.DeveloperName=:'Tag'
        Order By Name Asc
        ];

        if(listParentTags!=null && !listParentTags.isEmpty()){
            for(Code_and_Tag__c tagRec : listParentTags){
                TagCls tagClsRec = new TagCls();
                tagClsRec.TagId = tagRec.Id;
                tagClsRec.TagName = tagRec.Name;
                tagClsRec.hasChildTagRecs = false;
                if(tagRec.Code_and_Tags__r!=null && !tagRec.Code_and_Tags__r.isEmpty()){
                    tagClsRec.hasChildTagRecs = true;
                }
                listParenttagClsRecs.add(tagClsRec);
            }
        }
        return listParentTagClsRecs;
    }

    @AuraEnabled
    public static List<TagCls> getChildTagsAPX(string parentTagId){
        List<TagCls> listChildTagClsRecs = new List<TagCls>();
        List<Code_and_Tag__c> listChildTags = [Select Id,Name,(Select Id,Name FROM Code_and_Tags__r LIMIT 200)
        FROM Code_and_Tag__c
        WHERE Code_and_Tag__c=:parentTagId
        AND RecordType.DeveloperName=:'Tag'
        Order By Name Asc
        ];

        if(listChildTags!=null && !listChildTags.isEmpty()){
            for(Code_and_Tag__c tagRec : listChildTags){
                TagCls tagClsRec = new TagCls();
                tagClsRec.tagId = tagRec.Id;
                tagClsRec.tagName = tagRec.Name;
                tagClsRec.hasChildTagRecs = false;
                if(tagRec.Code_and_Tags__r!=null && !tagRec.Code_and_Tags__r.isEmpty()){
                    tagClsRec.hasChildTagRecs = true;
                }
                listChildTagClsRecs.add(tagClsRec);
            }
        }
        return listChildTagClsRecs;
    }

    @AuraEnabled
    public static List<SaveResult_APX> createRelatedCodeAndTagRecsAPX(List<TagCls> listSelectedTagsRecs, String recordId){
        List<SaveResult_APX> listSaveResultsAPX =  new List<SaveResult_APX>();
        List<Related_Code_and_Tag__c> listInsertRelatedCodesAndTags = new List<Related_Code_and_Tag__c>();
        Schema.SObjectField relatedCodeAndTagRelationshipField;
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
        if(listSelectedTagsRecs!=null && !listSelectedTagsRecs.isEmpty()){
            system.debug('5.');
            for(TagCls tagClsRec : listSelectedTagsRecs){
                Related_Code_and_Tag__c relCodeAndTagRec = new Related_Code_and_Tag__c();
                relCodeAndTagRec.Code_and_Tag__c = tagClsRec.tagId;
                relCodeAndTagRec.put(relatedCodeAndTagRelationshipField, recordId);
                relCodeAndTagRec.External_ID__c = tagClsRec.tagId + '-' + recordId;
                listInsertRelatedCodesAndTags.add(relCodeAndTagRec);
            }
        }
        if(listInsertRelatedCodesAndTags!=null && !listInsertRelatedCodesAndTags.isEmpty()){
            system.debug('6.');
            // listSaveResultsAPX =  SaveResult_APX.saveResultInsert(listInsertRelatedCodesAndTags);
            listSaveResultsAPX =  SaveResult_APX.saveResultUpsert(listInsertRelatedCodesAndTags, 'Related_Code_and_Tag__c', 'External_ID__c');

        }

        return listSaveResultsAPX;

    }

    public class TagCls{
        @AuraEnabled
        public string tagId{get;set;}
        @AuraEnabled
        public string tagName{get;set;}
        @AuraEnabled
        public boolean hasChildTagRecs{get;set;}
    }
}