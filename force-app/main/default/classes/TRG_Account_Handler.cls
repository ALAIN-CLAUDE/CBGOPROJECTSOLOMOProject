public class TRG_Account_Handler {
    public static void createAccountSPAJoiner(List<Account> listAccount){
        Set<String> zipCodeSet = new Set<String>();
        List<Zip_Code__c> listZipCode = new List<Zip_Code__c>();
        Map<String,SPA_Assign__c> mapUpsertSPAAssignments = new Map<String,SPA_Assign__c>();
        Map<String,Schema.SObjectField> mapAccFields = Schema.SObjectType.Account.fields.getMap();
        if(listAccount!=NULL && !listAccount.isEmpty()){
            for(Account accRec : listAccount){
                if(accRec.BillingPostalCode!=NULL && accRec.BillingPostalCode!=''){
                    zipCodeSet.add(accRec.BillingPostalCode);
                }
            }
        }
        if(zipCodeSet!=NULL && !zipCodeSet.isEmpty()){
            listZipCode = [Select Id,Name,SPA__c,SPA__r.Name,External_ID__c 
                           FROM Zip_Code__c
                           WHERE External_Id__c IN:zipCodeSet
                           LIMIT 2000
                          ];
        }
        system.debug('listZipCode--'+listZipCode);
        if(listZipCode!=NULL && !listZipCode.isEmpty()){
            for(Account accRec : listAccount){
                for(Zip_Code__c zpCodeRec : listZipCode){
                    if(accRec.BillingPostalCode!=NULL && accRec.BillingPostalCode == zpCodeRec.External_ID__c){
                        SPA_Assign__c spaAssignRec = new SPA_Assign__c();
                        spaAssignRec.Account__c = accRec.Id;
                        spaAssignRec.SPA__c = zpCodeRec.SPA__c;
                        spaAssignRec.Home_SPA__c = TRUE;
                        if(mapAccFields!=NULL && !mapAccFields.isEmpty()){
                            for(String field : mapAccFields.keySet()){
                                Schema.SObjectField sobjField = mapAccFields.get(field);
                                if(sobjField!=NULL){
                                    Schema.DescribeFieldResult schemaFieldRes = sobjField.getDescribe();
                                    if(schemaFieldRes!=NULL){
                                        if(Schema.DisplayType.BOOLEAN == schemaFieldRes.getType()){
                                            if(schemaFieldRes.getLabel() == zpCodeRec.SPA__r.Name){
                                                if(accRec.get(schemaFieldRes.getName()) == FALSE){
                                                    accRec.put(schemaFieldRes.getName(),TRUE);
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        spaAssignRec.External_ID__c = (string)accRec.Id + ' - ' + (string)zpCodeRec.SPA__c;
                        mapUpsertSPAAssignments.put(spaAssignRec.External_ID__c, spaAssignRec);
                    }
                }
            }
        }
        
        if(mapUpsertSPAAssignments!=NULL && !mapUpsertSPAAssignments.isEmpty()){
            upsert mapUpsertSPAAssignments.values() External_ID__c;
        }
    }
    
    public static void assignHomeSPA(List<Account> listAccount){
        Set<String> zipCodeSet = new Set<String>();
        List<Zip_Code__c> listZipCode = new List<Zip_Code__c>();
        if(listAccount!=NULL && !listAccount.isEmpty()){
            for(Account accRec : listAccount){
                if(accRec.BillingPostalCode!=NULL && accRec.BillingPostalCode!='' && accRec.Override__c == False){
                    zipCodeSet.add(accRec.BillingPostalCode);
                }
            }
        }
        
        List<SPA__c> listOutOfAreaSPA = [Select Id 
                                         FROM SPA__c 
                                         WHERE SPA_Number__c=:'Out of Area' 
                                         LIMIT 1
                                        ];
        if(zipCodeSet!=NULL && !zipCodeSet.isEmpty()){
            listZipCode = [Select Id,Name,SPA__c,SPA__r.Name,External_ID__c 
                           FROM Zip_Code__c
                           WHERE External_Id__c IN:zipCodeSet
                           LIMIT 2000
                          ];
        }
        
        if(listOutOfAreaSPA!=NULL && !listOutOfAreaSPA.isEmpty()){
            for(Account accRec : listAccount){
                accRec.Home_SPA__c = NULL;
                if(listOutOfAreaSPA!=NULL && !listOutOfAreaSPA.isEmpty()){
                    accRec.Home_SPA__c = listOutOfAreaSPA[0].Id;
                }
                if(listZipCode!=NULL && !listZipCode.isEmpty()){
                    for(Zip_Code__c zpCodeRec : listZipCode){
                        if(accRec.BillingPostalCode!=NULL && accRec.BillingPostalCode == zpCodeRec.External_ID__c){
                            accRec.Home_SPA__c = zpCodeRec.SPA__c;
                        }
                    }
                }
            }
        }
    }
}