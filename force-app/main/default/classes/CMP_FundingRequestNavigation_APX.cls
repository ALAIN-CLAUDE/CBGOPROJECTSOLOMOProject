public class CMP_FundingRequestNavigation_APX {
  
    @AuraEnabled
    public static List<Funding_Opportunity__c> getFundingOpportunities(){
        List<Funding_Opportunity__c> listFundingOpps = new List<Funding_Opportunity__c>();
        listFundingOpps = [Select Id,Name,(Select Stage__c FROM Funding_Responses__r LIMIT 1)
                           FROM Funding_Opportunity__c
                           WHERE Id IN (Select Funding_Opportunity__c
                                        FROM Funding_Request__c
                                        WHERE Owner.Id=:UserInfo.getUserId()
                                        and Stage__c IN ('Invited', 'In Process')
                                       )
                           Order By Proposal_Deadline__c DESC
                          ];
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