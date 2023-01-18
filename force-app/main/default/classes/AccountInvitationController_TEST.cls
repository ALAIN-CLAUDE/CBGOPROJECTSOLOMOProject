@isTEST
public class AccountInvitationController_TEST {
    public static List<Account> listAccounts{get;set;}
    public static void init(){
        listAccounts = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TEST Acc';
        listAccounts.add(acc);
        insert listAccounts;
    }
    
    public static testmethod void testmethod1(){
        init();
        TEST.startTest();
        ApexPages.StandardSetController stdSetCon = new ApexPages.StandardSetController(listAccounts);
        stdSetCon.setSelected(listAccounts);
        AccountInvitationController accInvCon = new AccountInvitationController(stdSetCon);
        accInvCon.AccountsLV();
        TEST.stopTest();
    }
}