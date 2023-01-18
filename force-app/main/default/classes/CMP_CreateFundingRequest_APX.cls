public class CMP_CreateFundingRequest_APX {
	@AuraEnabled
    public static List<SPA__c> getSPAs(string recordId){
        List<SPA__c> listSPAs = new List<SPA__c>();
        listSPAs = [Select Id,SPA_Number_Name__c
                    FROM SPA__c
                    ORDER BY SPA_Number_Name__c
                    LIMIT 2000
                   ];
        return listSPAs;
    }
    
    @AuraEnabled
    public static List<String> getPicklistValues(string objectApiName, string fieldApiName){
        List<String> listPicklistValues = new List<String>();
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(objectApiName);
        if(sobjType!=NULL){
            Map<String,Schema.SObjectField> mappedFields = sobjType.getDescribe().fields.getMap();
            Schema.DescribeFieldResult sobjFieldDescRes = sobjType.getDescribe().fields.getMap().get(fieldApiName).getDescribe();
            if(sobjFieldDescRes!=NULL){
                if(sobjFieldDescRes.getType() == Schema.DisplayType.PICKLIST){
                    List<Schema.PicklistEntry> listPicklistEntries = new List<Schema.PicklistEntry>();
                    listPicklistEntries = sobjFieldDescRes.getPicklistValues();
                    if(listPicklistEntries!=NULL && !listPicklistEntries.isEmpty()){
                        for(Schema.PicklistEntry picklistEntry : listPicklistEntries){
                            if(picklistEntry.isActive()){
                                listPicklistValues.add(picklistEntry.value);
                            }
                        }
                    }
                }
            }
        }
        return listPicklistValues;
    }
    
    public class PortFolioCls{
        @AuraEnabled
        public string name{get;set;}
        @AuraEnabled
        public string portFolioId{get;set;}
    }
    
    public class OrgTypeCls{
        @AuraEnabled
        public string name{get;set;}
        @AuraEnabled
        public string orgTypeId{get;set;}
    }
    
    @AuraEnabled
    public static List<Account> getAccounts(string spaListStr, List<String> listPortFolios, List<string> listOrgTypes){
        List<SPA__c> listSPAs = new List<SPA__c>();
        if(spaListStr!=NULL && spaListStr!=''){
            listSPAs = (List<SPA__c>)JSON.deserialize(spaListStr, List<SPA__c>.class);
        }
        List<Account> listAccounts = new List<Account>();
        Set<Id> spaIdSet = new Set<Id>();
        system.debug('listSPAs--'+listSPAs);
        if(listSPAs!=NULL && !listSPAs.isEmpty()){
            for(SPA__c spaRec : listSPAs){
                spaIdSet.add(spaRec.Id);
            }
        }
        system.debug('spaIdSet--'+spaIdSet);
        if(spaIdSet!=NULL && !spaIdSet.isEmpty()){
            listAccounts = [Select Id,Name,Organization_Type__c,Portfolio__c 
                            FROM Account
                            WHERE Id IN (Select Account__c 
                                         FROM SPA_Assign__c 
                                         WHERE SPA__c IN:spaIdSet
                                        )
                           ];
            
            if(listPortFolios!=NULL && !listPortFolios.isEmpty()){
                listAccounts = [Select Id,Name,Organization_Type__c,Portfolio__c 
                                FROM Account
                                WHERE Portfolio__c IN:listPortFolios
                                AND Id IN (Select Account__c 
                                           FROM SPA_Assign__c 
                                           WHERE SPA__c IN:spaIdSet
                                          )
                               ];
            }
            if(listOrgTypes!=NULL && !listOrgTypes.isEmpty()){
                listAccounts = [Select Id,Name,Organization_Type__c,Portfolio__c 
                                FROM Account
                                WHERE Organization_Type__c IN:listOrgTypes
                                AND Id IN (Select Account__c 
                                           FROM SPA_Assign__c 
                                           WHERE SPA__c IN:spaIdSet
                                          )
                               ];
            }
            if(listPortFolios!=NULL && !listPortFolios.isEmpty()&& listOrgTypes!=NULL && !listOrgTypes.isEmpty()){
                listAccounts = [Select Id,Name,Organization_Type__c,Portfolio__c 
                                FROM Account
                                WHERE Portfolio__c IN:listPortFolios
                                AND Organization_Type__c IN:listOrgTypes
                                AND Id IN (Select Account__c 
                                           FROM SPA_Assign__c 
                                           WHERE SPA__c IN:spaIdSet
                                          )
                               ];
            }
        }
        return listAccounts;
    }
    
    @AuraEnabled
    public static void insertFundingRequests(string accountListStr, string recordId){
        List<Account> listAccounts = new List<Account>();
        List<Funding_Request__c> listFundingRequests = new List<Funding_Request__c>();
        if(accountListStr!=NULL && accountListStr!=''){
            listAccounts = (List<Account>)JSON.deserialize(accountListStr, List<Account>.class);
        }
        if(listAccounts!=NULL && !listAccounts.isEmpty()){
            for(Account accRec : listAccounts){
                Funding_Request__c fundingReq = new Funding_Request__c();
                fundingReq.Respondent__c = accRec.Id;
                fundingReq.Name = accRec.Name;
                fundingReq.Funding_Opportunity__c = recordId;
                listFundingRequests.add(fundingReq);
            }
        }
        
        if(listFundingRequests!=NULL && !listFundingRequests.isEmpty()){
            List<Database.SaveResult> listSaveResults = Database.insert(listFundingRequests);
        }
    }
}