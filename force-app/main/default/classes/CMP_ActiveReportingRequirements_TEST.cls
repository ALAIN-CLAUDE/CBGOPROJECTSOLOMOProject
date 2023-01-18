@isTest
public class CMP_ActiveReportingRequirements_TEST {
    private static User testPartnerUser;
    public static void init(){
        
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
        
        Funding_Opportunity__c testFndOpp = new Funding_Opportunity__c();
        testFndOpp.Account__c = testAcc.Id;
        testFndOpp.Proposal_Deadline__c = Date.today();
        insert testFndOpp;
        
        Funding_Request__c fndReq = new Funding_Request__c();
        fndReq.Funding_Opportunity__c = testFndOpp.Id;
        fndReq.Respondent__c = testAcc.Id;
        fndReq.Stage__c = 'Invited';
        insert fndReq;
        
        //LISTER CODE COMMENTED OUT BY AD AUG 26 2021
        /*Funding_Request__c FundingReq = new Funding_Request__c(Name='Test');
        insert FundingReq;*/
        disco__Form_Template__c formtemp = new disco__Form_Template__c(Name='Data Collection Form', disco__Status__c = 'In Use');
        insert formtemp;
        //LISTER CODE COMMENTED OUT BY AD AUG 26 2021
        /*disco__Form__c form = new disco__Form__c(disco__Form_Template__c = formtemp.Id, Funding_Request__c = FundingReq.Id);
        insert form;*/
        
        disco__Form__c form = new disco__Form__c(disco__Form_Template__c = formtemp.Id, Funding_Request__c = fndReq.Id);
        insert form;
    }
    @isTest
    public static void method1(){
        init();
        Test.startTest();
        System.runAs(testPartnerUser){
            CMP_ActiveReportingRequirements_APX.getActiveReportingRequirements();
        }
        Test.stopTest();
    }
}