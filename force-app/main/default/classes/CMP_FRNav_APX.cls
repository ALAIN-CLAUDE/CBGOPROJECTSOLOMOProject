public class CMP_FRNav_APX {
  
    @AuraEnabled
    public static List<Funding_Opportunity__c> getFundingOpportunities(){
        
        List<User> listLoggedInUsers = [Select Id, ContactId 
                                        FROM User
                                        WHERE Id=:UserInfo.getUserId()
                                        AND Profile.UserLicense.Name=:SYSTEM.LABEL.PartnerCommunityUserLicenseName
                                        LIMIT 1
                                       ];
        
        List<Funding_Opportunity__c> listFundingOpps = new List<Funding_Opportunity__c>();
        if(listLoggedInUsers!=null && !listLoggedInUsers.isEmpty()){
            Map<Id,Funding_Request__c> mapFundingRequests = new Map<Id,Funding_Request__c>([Select Id,Funding_Opportunity__c
                                                                                            FROM Funding_Request__c
                                                                                            WHERE Respondent__c IN (Select AccountId 
                                                                                                                    FROM Contact 
                                                                                                                    WHERE Id=:listLoggedInUsers[0].ContactId
                                                                                                                   )
                                                                                            AND Stage__c IN ('Invited', 'In Process')
                                                                                           ]);
            
            
            
            if(mapFundingRequests!=null && !mapFundingRequests.isEmpty()){
                Set<Id> fndOppIdSet = new Set<Id>();
                for(Id fndReqId : mapFundingRequests.keySet()){
                    if(mapFundingRequests.get(fndReqId).Funding_Opportunity__c!=null){
                        fndOppIdSet.add(mapFundingRequests.get(fndReqId).Funding_Opportunity__c);
                    }
                }
                listFundingOpps = [Select Id,Name,(Select Stage__c FROM Funding_Responses__r WHERE Stage__c IN ('Invited', 'In Process') LIMIT 1)
                                   FROM Funding_Opportunity__c
                                   WHERE Id IN:fndOppIdSet
                                   Order By Proposal_Deadline__c DESC
                                  ];
            }
            
        }
        
        system.debug('listFundingOpps--'+listFundingOpps);
        return listFundingOpps;
    }
    
    /*@AuraEnabled
    public static List<Funding_Request__c> getFundingRequests(string selectedFundOppId){
        List<Funding_Request__c> listFundingReqs = new List<Funding_Request__c>();
        system.debug('selectedFundOppId---'+selectedFundOppId);
        if(selectedFundOppId!=NULL && selectedFundOppId!=''){
            listFundingReqs = [Select Id,Name
                               FROM Funding_Request__c
                               WHERE Stage__c=:'In Process'
                               AND OwnerId=:UserInfo.getUserId()
                               AND Funding_Opportunity__c=:selectedFundOppId
                              ];
            system.debug('listFundingReqs------'+listFundingReqs.size());
        }
        return listFundingReqs;
    }*/
    
    
}