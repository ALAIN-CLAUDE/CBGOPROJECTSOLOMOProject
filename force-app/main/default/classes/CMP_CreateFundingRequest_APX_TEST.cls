@isTest
public class CMP_CreateFundingRequest_APX_TEST {
    public static Account acc;
    public static Funding_Opportunity__c opp;
 
    public static void init(){
        
        acc = new Account();
        acc.Name = 'New Account';
        acc.BillingPostalCode = '201930';
        acc.Portfolio__c = 'Access To Care';
        acc.Organization_Type__c = 'Behavioral Health Organization';
        insert acc;
        
        SPA__c spa = new SPA__c();
        spa.Name = 'Test Spa';
        spa.SPA_Number__c = 'spa1020';
        insert spa;
        
        SPA_Assign__c spaAssign = new SPA_Assign__c();
        spaAssign.Account__c = acc.Id;
        spaAssign.SPA__c = spa.Id;
        insert spaAssign;
        
        opp = new Funding_Opportunity__c();
        opp.Account__c = acc.id;
        opp.Name = 'New Opp';
        insert opp;
        
        Funding_Request__c freq = new Funding_Request__c();
        freq.name = 'New request Funding';
        freq.Stage__c = 'In Process';
        freq.Declination_Reason__c = 'Limited Resources';
        freq.Funding_Opportunity__c = opp.id;
        freq.Project_Title__c = 'New Title';
        insert freq;
        
    }
    
    @isTEST
    public static void testmethod1(){
        init();
        TEST.startTest();
        List<SPA__c> listSPas = CMP_CreateFundingRequest_APX.getSPAs((string)acc.Id);
        string spaListStr = JSON.serialize(listSPas);
        List<String> listPortfolios = CMP_CreateFundingRequest_APX.getPicklistValues('Account','Portfolio__c');
        List<String> listOrgTypes = CMP_CreateFundingRequest_APX.getPicklistValues('Account','Organization_Type__c');
        List<Account> listAcc = CMP_CreateFundingRequest_APX.getAccounts(spaListStr, listPortFolios, listOrgTypes);
        string accountListStr = JSON.serialize(listAcc);
        CMP_CreateFundingRequest_APX.insertFundingRequests(accountListStr, opp.Id);
        
    }
    /*@isTest
    public static void method1(){
        Account accList = [Select id,name from account limit 1];
        system.debug('accList--'+accList);
        String accountListStr = JSON.serialize(accList);
        system.debug('accountListStr-'+accountListStr);
        Funding_Opportunity__c oppList = [Select id,name from Funding_Opportunity__c limit 1]; 
        system.debug('oppList--'+oppList);
        String recordId = JSON.serialize(oppList);
        system.debug('recordId-'+recordId);
        String body = JSON.serialize( [Select Id from Account limit 1] );
        String body1 = JSON.serialize( [Select id from Funding_Opportunity__c limit 1] );
        Test.startTest();
         CMP_CreateFundingRequest_APX.insertFundingRequests(body, body1);
        Test.stopTest();
    }*/
}