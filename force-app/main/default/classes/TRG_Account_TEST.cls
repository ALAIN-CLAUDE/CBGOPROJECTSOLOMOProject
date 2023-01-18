@isTest
public class TRG_Account_TEST {
	@testSetup
    public static void Setup(){
        Account acc = new Account();
        acc.Name = 'New Account';
        acc.BillingPostalCode = '201930';
        insert acc;
        
        SPA__c spaOutOfArea = new SPA__c();
        spaOutOfArea.Name = 'Out Of Area';
        spaOutOfArea.SPA_Number__c = 'spa1000';
        insert spaOutOfArea;
        
        SPA__c spa = new SPA__c();
        spa.Name = 'Test Spa';
        spa.SPA_Number__c = 'spa1020';
        insert spa;
        
        Zip_Code__c zip = new Zip_Code__c();
        zip.Name = 'Test Zip';
        zip.SPA__c = spa.id;
        zip.External_ID__c = '201930';
        insert zip;
        
        List<Zip_Code__c> listZipCode = new List<Zip_Code__c>();
        listZipCode = [Select Id,Name,SPA__c,SPA__r.Name,External_ID__c 
                           FROM Zip_Code__c ];
        system.debug('listZipCode--'+listZipCode);
            
        SPA_Assign__c spaAssignRec = new SPA_Assign__c();
        spaAssignRec.Account__c = acc.Id;
        spaAssignRec.SPA__c = zip.SPA__c;
        spaAssignRec.Home_SPA__c = TRUE;
        insert spaAssignRec;
    }
    
    @isTest static void  testmethod1(){
        TEST.startTest();
        Account acc = [select id,name from Account limit 1];
        acc.name = 'New Acc';
        update acc;
        TEST.stopTest();
    }
}