public class CMP_FRDecisionMaker_APX {

    /*
    @AuraEnabled
    public static string getLoggedInUserAccountId_APX(){
        string accountId = '';
        try {
            List<User> listLoggedInUsers = [Select Id, ContactId, Contact.AccountId 
            FROM User
            WHERE Id=:UserInfo.getUserId()
            AND Profile.UserLicense.Name=:SYSTEM.LABEL.PartnerCommunityUserLicenseName
            AND ContactId!=null
            AND Contact.AccountId!=null
            LIMIT 1
            ];

            if(listLoggedInUsers!=null && !listLoggedInUsers.isEmpty()){
                accountId = listLoggedInUsers[0].Contact.AccountId;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return accountId;
    }
    */

    @AuraEnabled
    public static List<Funding_Request__c> getFundingRequests_APX(){
        //string action = 'new';
        List<Funding_Request__c> listFundingRequests = new List<Funding_Request__c>();
        try {

            List<User> listLoggedInUsers = [Select Id, ContactId 
            FROM User
            WHERE Id=:UserInfo.getUserId()
            AND Profile.UserLicense.Name=:SYSTEM.LABEL.PartnerCommunityUserLicenseName
            LIMIT 1
            ];
            
            if(listLoggedInUsers!=null && !listLoggedInUsers.isEmpty()){
                listFundingRequests = [Select Id,Funding_Opportunity__c,Continued__c
                FROM Funding_Request__c
                WHERE Respondent__c IN (Select AccountId 
                FROM Contact 
                WHERE Id=:listLoggedInUsers[0].ContactId
                )
                AND Stage__c IN ('Invited', 'In Process')
                Order By CreatedDate ASC
                LIMIT 1
                ];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return listFundingRequests;
    }
}