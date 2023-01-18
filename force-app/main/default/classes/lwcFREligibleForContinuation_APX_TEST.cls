@isTest
public with sharing class lwcFREligibleForContinuation_APX_TEST {
    private static User testPartnerUser;
    private static Funding_Opportunity__c testFndOpp;
    private static Funding_Request__c testFndReq;
    private static void init(){
        List<Profile> listPartnerCommunityProfile = [Select Id 
                                                     FROM Profile 
                                                     WHERE Name=:SYSTEM.LABEL.TestClassPartnerCommunityProfile_1
                                                    ];
        
        List<User> listUser = [Select Id,UserRoleId,Name,UserName From User WHERE Id=:UserInfo.getUserId()];
       
        system.debug('listUser--'+listUser);
        
            Account testAcc = new Account();
            testAcc.Name = 'TEST ACCOUNT';
            testAcc.OwnerId = UserInfo.getUserId();
            insert testAcc;
            
            Contact testConRec = new Contact();
            testConRec.FirstName = 'TEST PARTNER FIRST NAME';
            testConRec.LastName = 'TEST PARTNER LAST NAME';
            testConRec.Email = 'testpartner@partner.com';
            testConRec.AccountId = testAcc.Id;
            testConRec.OwnerId = UserInfo.getUserId();
            insert testConRec;
            
        System.runAs(listUser[0]){ 
            testPartnerUser = new User();
            testPartnerUser.alias = 'test123';
            testPartnerUser.email=  testConRec.Email;
            testPartnerUser.emailencodingkey='UTF-8';
            testPartnerUser.lastname= testConRec.LastName;
            testPartnerUser.languagelocalekey='en_US';
            testPartnerUser.localesidkey='en_US'; 
            testPartnerUser.profileid = listPartnerCommunityProfile[0].Id;
            testPartnerUser.IsActive =true;
            testPartnerUser.ContactId = testConRec.Id;
            testPartnerUser.communityNickname = 'partnerCBGOTEST';
            testPartnerUser.timezonesidkey='America/Los_Angeles'; 
            testPartnerUser.username='testpartner@partnercbgo.com';
            insert testPartnerUser;
        }
        
        testFndOpp = new Funding_Opportunity__c();
        testFndOpp.Account__c = testAcc.Id;
        testFndOpp.Proposal_Deadline__c = Date.today();
        insert testFndOpp;
        
        testFndReq = new Funding_Request__c();
        testFndReq.Funding_Opportunity__c = testFndOpp.Id;
        testFndReq.Stage__c = 'Invited';
        testFndReq.Respondent__c = testAcc.Id;
        insert testFndReq;

        Objective__c testObjRec = new Objective__c();
        testObjRec.Funding_Request__c = testFndReq.Id;
        insert testObjRec;
    }

    private static testmethod void testmethod1(){
        init();
        lwcFREligibleForContinuation_APX.cloneFundingReq_APX(testFndOpp.Id, testFndReq.Id);
    }
}