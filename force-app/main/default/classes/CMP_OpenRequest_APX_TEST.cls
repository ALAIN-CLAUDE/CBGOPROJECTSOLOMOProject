@isTest
public class CMP_OpenRequest_APX_TEST {

    @testSetup
    public static void Setup(){
        User user;
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Director' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username,ContactId, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Community'  );
            insert account_1;
            
            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek');
            insert contact_1;
            
            user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
            
            Funding_Request__c freq = new Funding_Request__c();
            freq.name = 'New request Funding';
            freq.Stage__c = 'In Process';
            freq.Declination_Reason__c = 'Limited Resources';
            freq.Project_Title__c = 'New Title';
            //freq.Project_Goal__c = 'new Goal';
            //freq.Objectives__c = 'new Objectives';
            freq.Target_Communities__c = 'new community';
            //freq.Community_Involvement__c = 'involvement';
            freq.Grant_Request_Amount__c = 45;
            freq.Project_Start_Date__c = date.today();
            freq.Project_End_Date__c = date.today() + 1 ;
            insert freq;
            
            Review_Assignment__c assign = new Review_Assignment__c();
            assign.Funding_Request__c = freq.id;
            assign.Reviewer__c = admin.ContactId;
            insert assign;
            
        }
    }
    @isTest
    public static void method1(){
        Test.startTest();
        CMP_OpenRequest_APX.fetchUserId();
        CMP_OpenRequest_APX.getFundingRequests();
        Test.stopTest();
    } 
}