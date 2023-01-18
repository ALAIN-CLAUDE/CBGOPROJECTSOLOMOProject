@isTest
public class CMP_PartnerHomePage_APX_TEST {
    @testSetup
    public static void PartnerHomePage(){
        List<Home_Page_Settings__c> listHomePageSettings = new List<Home_Page_Settings__c>();
        for(integer i=0; i<2; i++){
            listHomePageSettings.add(new Home_Page_Settings__c(Name='Test'+i, Active__c=TRUE));           
        }
        insert listHomePageSettings;
        
    }
    @isTest
    public static void method1(){
        Test.startTest();
        CMP_PartnerHomePage_APX.getHomePageSettings();
        Test.stopTest();
    }

}