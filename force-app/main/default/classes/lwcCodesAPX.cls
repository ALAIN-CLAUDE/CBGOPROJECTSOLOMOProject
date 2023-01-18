public with sharing class lwcCodesAPX {
   
     @AuraEnabled
    public static void createCodeAndTags(List<Related_Code_and_Tag__c> records ){
        System.debug(records);
        insert records;
    }

    @AuraEnabled
    public static List<Id> getPreSelectedCodesAPX(string recordId){
        List<Id> listPreSelectedCodeIds = new List<Id>();
        Map<Id,Related_Code_and_Tag__c> mapCodeAndTags = new Map<Id,Related_Code_and_Tag__c>([Select Id,Code_and_Tag__c, Code_and_Tag__r.Name
        FROM Related_Code_and_Tag__c
        WHERE Funding_Opportunity__c=:recordId OR Funding_Request__c=:recordId OR Sponsorship_Request__c=:recordId]);

        if(mapCodeAndTags!=null && !mapCodeAndTags.isEmpty()){
            for(Id relatedCodeId : mapCodeAndTags.keySet()){
                listPreSelectedCodeIds.add(mapCodeAndTags.get(relatedCodeId).Code_and_Tag__c);
            }
        }

        return listPreSelectedCodeIds;
    }

 @AuraEnabled
    public static List<CodeCls> getParentCodesAPX(){
        List<CodeCls> listParentCodeClsRecs = new List<CodeCls>();
        List<Code_and_Tag__c> listParentCodes = [Select Id,Name,(Select Id,Name FROM Code_and_Tags__r LIMIT 200)
        FROM Code_and_Tag__c
        WHERE Code_and_Tag__c=null
        AND RecordType.DeveloperName=:'Code'
        Order By Name Asc
        ];

        if(listParentCodes!=null && !listParentCodes.isEmpty()){
            for(Code_and_Tag__c codeRec : listParentCodes){
                CodeCls codeClsRec = new CodeCls();
                codeClsRec.codeId = codeRec.Id;
                codeClsRec.codeName = codeRec.Name;
                codeClsRec.hasChildCodeRecs = false;
                codeClsRec.amount =0;
                if(codeRec.Code_and_Tags__r!=null && !codeRec.Code_and_Tags__r.isEmpty()){
                    codeClsRec.hasChildCodeRecs = true;
                }
                listParentCodeClsRecs.add(codeClsRec);
            }
        }
        return listParentCodeClsRecs;
    }

    @AuraEnabled
    public static List<CodeCls> getChildCodesAPX(string parentCodeId){
        List<CodeCls> listChildCodeClsRecs = new List<CodeCls>();
        List<Code_and_Tag__c> listChildCodes = [Select Id,Name,(Select Id,Name FROM Code_and_Tags__r LIMIT 200)
        FROM Code_and_Tag__c
        WHERE Code_and_Tag__c=:parentCodeId
        AND RecordType.DeveloperName=:'Code'
        Order By Name Asc
        ];

        if(listChildCodes!=null && !listChildCodes.isEmpty()){
            for(Code_and_Tag__c codeRec : listChildCodes){
                CodeCls codeClsRec = new CodeCls();
                codeClsRec.codeId = codeRec.Id;
                codeClsRec.codeName = codeRec.Name;
                codeClsRec.hasChildCodeRecs = false;
                codeClsRec.parentCodeId = parentCodeId;
                codeClsRec.amount =0;
                if(codeRec.Code_and_Tags__r!=null && !codeRec.Code_and_Tags__r.isEmpty()){
                    codeClsRec.hasChildCodeRecs = true;
                }
                listChildCodeClsRecs.add(codeClsRec);
            }
        }
        return listChildCodeClsRecs;
    }


    public class CodeCls{
        @AuraEnabled
        public string codeId{get;set;}
        @AuraEnabled
        public string codeName{get;set;}
        @AuraEnabled
        public boolean hasChildCodeRecs{get;set;}
        @AuraEnabled
        public string parentCodeId{get;set;}
        @AuraEnabled
        public decimal amount{get;set;}
        
    }
}