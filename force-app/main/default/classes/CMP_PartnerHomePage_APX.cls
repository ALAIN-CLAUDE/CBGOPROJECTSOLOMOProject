public class CMP_PartnerHomePage_APX {
    @AuraEnabled
    public static List<Home_Page_Settings__c> getHomePageSettings(){
        List<Home_Page_Settings__c> listHomePageSettings = new List<Home_Page_Settings__c>();
        listHomePageSettings = [Select Id,Image_Name__c,Banner_Text__c,URL_to_redirect__c,Banner_Help_Text__c
                                FROM Home_Page_Settings__c
                                WHERE Active__c=:TRUE
                                Order By Sort_Order__c Asc
                                LIMIT 2000
                               ];
        
        return listHomePageSettings;
    }
}