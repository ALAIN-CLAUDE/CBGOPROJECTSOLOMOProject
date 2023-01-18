@isTEST
public class CMP_ReviewerHomePage_APX_TEST {
    private static User testReviewerUser;
    private static void init(){
        
        List<Profile> listPartnerCommunityProfile = [Select Id 
                                                     FROM Profile 
                                                     WHERE Name=:SYSTEM.LABEL.TestClassPartnerCommunityProfile_1
                                                    ];
        
        List<Profile> listReviewerCommunityProfile = [Select Id 
                                                     FROM Profile 
                                                     WHERE Name=:SYSTEM.LABEL.TestClassReviewerCommunityProfile_1
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
        
        Contact testConReviewerRec = new Contact();
        testConReviewerRec.FirstName = 'TEST REVIEWER FIRST NAME';
        testConReviewerRec.LastName = 'TEST REVIEWER LAST NAME';
        testConReviewerRec.Email = 'testreviewer@reviewer.com';
        testConReviewerRec.AccountId = testAcc.Id;
        testConReviewerRec.OwnerId = UserInfo.getUserId();
        insert testConReviewerRec;
        
        System.runAs(listUser[0]){ 
            User testPartnerUser = new User();
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
            
            testReviewerUser = new User();
            testReviewerUser.alias = 'testRev';
            testReviewerUser.email=  testConReviewerRec.Email;
            testReviewerUser.emailencodingkey='UTF-8';
            testReviewerUser.lastname= testConReviewerRec.LastName;
            testReviewerUser.languagelocalekey='en_US';
            testReviewerUser.localesidkey='en_US'; 
            testReviewerUser.profileid = listReviewerCommunityProfile[0].Id;
            testReviewerUser.IsActive =true;
            testReviewerUser.ContactId = testConReviewerRec.Id;
            testReviewerUser.communityNickname = 'reviewerCBGOTEST';
            testReviewerUser.timezonesidkey='America/Los_Angeles'; 
            testReviewerUser.username='testreviwer@reviewercbgo.com';
            insert testReviewerUser;
        }
        
        Funding_Opportunity__c testFndOpp = new Funding_Opportunity__c();
        testFndOpp.Account__c = testAcc.Id;
        testFndOpp.Proposal_Deadline__c = Date.today();
        insert testFndOpp;
        
        Funding_Request__c fndReq = new Funding_Request__c();
        fndReq.Funding_Opportunity__c = testFndOpp.Id;
        fndReq.Stage__c = 'Invited';
        fndReq.Respondent__c = testAcc.Id;
        insert fndReq;
        
        Review_Assignment__c testRevAssign = new Review_Assignment__c();
        testRevAssign.Funding_Request__c = fndReq.Id;
        testRevAssign.Stage__c = 'In Review';
        testRevAssign.Reviewer__c = testReviewerUser.ContactId;
        insert testRevAssign;
        
        Review_Assignment__Share testRevAssignShare1 = new Review_Assignment__Share();
        testRevAssignShare1.ParentId = testRevAssign.Id;
        testRevAssignShare1.UserOrGroupId = testReviewerUser.Id;
        testRevAssignShare1.RowCause = 'Manual';
        testRevAssignShare1.AccessLevel = 'Read';
        insert testRevAssignShare1;
        
        Review_Assignment__c testRevAssign2 = new Review_Assignment__c();
        testRevAssign2.Funding_Request__c = fndReq.Id;
        testRevAssign2.Reviewer__c = testReviewerUser.ContactId;
        testRevAssign2.Stage__c = 'Review Complete';
        insert testRevAssign2;
        
        Review_Assignment__Share testRevAssignShare2 = new Review_Assignment__Share();
        testRevAssignShare2.ParentId = testRevAssign2.Id;
        testRevAssignShare2.UserOrGroupId = testReviewerUser.Id;
        testRevAssignShare2.RowCause = 'Manual';
        testRevAssignShare2.AccessLevel = 'Read';
        insert testRevAssignShare2;
    }
    
    private static testmethod void testmethod1(){
        init();
        System.runAs(testReviewerUser){
            CMP_ReviewerHomePage_APX.getUser();
            CMP_ReviewerHomePage_APX.getSubmittedReviewAssignments();
            CMP_ReviewerHomePage_APX.getPendingReviewAssignments();
        }
    }
}