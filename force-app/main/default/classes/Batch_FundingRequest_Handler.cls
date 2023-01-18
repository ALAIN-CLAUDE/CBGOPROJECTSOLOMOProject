public class Batch_FundingRequest_Handler {
    public static void setFundingRequestOwner(Id asyncApexJobId, List<Funding_Request__c> listFundingRequests){
        Set<Id> applicationContactIdSet = new Set<Id>();
        List<Funding_Request__c> listFilteredFundingRequests = new List<Funding_Request__c>();//To avoid writing these if conditions
        if(listFundingRequests!=NULL && !listFundingRequests.isEmpty()){
            Date todayDate = Date.today();
            for(Funding_Request__c fundReqRec : listFundingRequests){
                if(fundReqRec.Funding_Opportunity__c!=NULL &&  fundReqRec.Funding_Opportunity__r.Proposal_Release__c!=NULL && fundReqRec.Funding_Opportunity__r.Proposal_Release__c <= todayDate){
                    if(fundReqRec.Respondent__c!=NULL && fundReqRec.Respondent__r.Application_Contact__c!=NULL){
                        applicationContactIdSet.add(fundReqRec.Respondent__r.Application_Contact__c);
                        listFilteredFundingRequests.add(fundReqRec);
                    }
                }
            }
        }
        
        if(applicationContactIdSet!=NULL && !applicationContactIdSet.isEmpty()){
            List<User> listCommunityUsers = [Select Id,ContactId 
                                             FROM User
                                             WHERE ContactId IN:applicationContactIdSet
                                             AND ContactId!=NULL
                                            ];
            if(listFilteredFundingRequests!=NULL && !listFilteredFundingRequests.isEmpty()){
                for(Funding_Request__c fundReqRec : listFilteredFundingRequests){
                    if(listCommunityUsers!=NULL && !listCommunityUsers.isEmpty()){
                        for(User usrRec : listCommunityUsers){
                            if(fundReqRec.Respondent__r.Application_Contact__c == usrRec.ContactId){
                                fundReqRec.OwnerId = usrRec.Id;
                            }
                        }
                    }
                }
            }
        }
        if(listFilteredFundingRequests!=NULL && !listFilteredFundingRequests.isEmpty()){
            List<Database.SaveResult> listSaveResults = Database.update(listFilteredFundingRequests);
        }
    }
    
    public static void updateOwner(Id asyncApexJobId, List<Funding_Request__c> listFundingRequests){
        
        if(listFundingRequests!=NULL && !listFundingRequests.isEmpty()){
            Set<Id> contactIdSet = new Set<Id>();
            for(Funding_Request__c fundRequest : listFundingRequests){
                if(fundRequest.Request_Contact__c !=NULL){
                    contactIdSet.add(fundRequest.Request_Contact__c);
                }
            }
            if(contactIdSet!=NULL && !contactIdSet.isEmpty()){
                List<User> listUsers = [Select Id,ContactId From User 
                                        WHERE ContactId!=NULL 
                                        AND ContactId IN:contactIdSet
                                       ];
                if(listUsers!=NULL && !listUsers.isEmpty()){
                    for(Funding_Request__c fundRequest : listFundingRequests){
                        if(fundRequest.Request_Contact__c !=NULL){
                            for(User userRec : listUsers){
                                if(userRec.ContactId == fundRequest.Request_Contact__c){
                                    fundRequest.OwnerId = userRec.Id;
                                }
                            }
                        }
                    }
                }
            }
            List<Database.SaveResult> listSaveResults = Database.update(listFundingRequests);
        }
    }
    
    public static void sendEmailV2(Id asyncApexJobId, List<Funding_Request__c> listFundingRequests){
        if(listFundingRequests!=NULL && !listFundingRequests.isEmpty()){
            for(Funding_Request__c fundReqRec : listFundingRequests){
                    if(fundReqRec.Funding_Opportunity__r.Proposal_Release__c!=NULL && Date.today() <= fundReqRec.Funding_Opportunity__r.Proposal_Release__c){
                        if(fundReqRec.Stage__c=='Invited' && fundReqRec.Partner_Invitation_Sent__c == false){
                            fundReqRec.Partner_Invitation_Sent__c = TRUE;
                        }
                    }
            }
            
            List<Database.SaveResult> listSaveResults = Database.update(listFundingRequests);
        }
    }
    
    /*public static void sendEmail(Id asyncApexJobId, List<Funding_Request__c> listFundingRequests){
        Set<Id> accountIdSet = new Set<Id>();
        if(listFundingRequests!=NULL && !listFundingRequests.isEmpty()){
            for(Funding_Request__c fundReqRec : listFundingRequests){
                if(fundReqRec.Respondent__c!=NULL && fundReqRec.Respondent__r.Application_Contact__c!=NULL){
                    accountIdSet.add(fundReqRec.Respondent__c);
                }
            }
        }
        Map<Id,Account> mapAccounts = new Map<Id,Account>();
            if(accountIdSet!=NULL && !accountIdSet.isEmpty()){
                mapAccounts = new Map<Id,Account>([Select Id,Partner_Invitation_Sent__c,Application_Contact__c 
                                                   FROM Account
                                                   WHERE Id IN:accountIdSet
                                                  ]);                
            }
        
        
        
        Date todaysDate = System.today();
        
        
        if(listFundingRequests!=NULL && !listFundingRequests.isEmpty()){
            for(Funding_Request__c fundReqRec : listFundingRequests){
                if(fundReqRec.Project_Start_Date__c !=null && fundReqRec.Project_End_Date__c != null){
                    if(todaysDate >= fundReqRec.Project_Start_Date__c && todaysDate<= fundReqRec.Project_End_Date__c){
                        if(fundReqRec.Respondent__c!=NULL && fundReqRec.Respondent__r.Application_Contact__c!=NULL){
                            if(fundReqRec.Respondent__r.Partner_Invitation_Sent__c == false){
                                if(mapAccounts!=NULL && !mapAccounts.isEmpty() && mapAccounts.containsKey(fundReqRec.Respondent__c)){
                                    mapAccounts.get(fundReqRec.Respondent__c).Partner_Invitation_Sent__c = TRUE;
                                }
                                //You have to update account from account not from funding req (Lister Error)
                                //fundReqRec.Respondent__r.Partner_Invitation_Sent__c = true;
                            }
                        }
                    }
                }
            }
            //NO Point in updating funding reqs
            //List<Database.SaveResult> listSaveResults = Database.update(listFundingRequests);
        }
        
        if(mapAccounts!=NULL && !mapAccounts.isEmpty()){
            List<Database.SaveResult> listSaveResults = Database.update(mapAccounts.values());
        }
    }*/
}