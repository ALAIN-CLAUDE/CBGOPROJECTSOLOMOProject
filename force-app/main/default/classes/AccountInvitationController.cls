public with sharing class AccountInvitationController {

    /**This is the list which will be passed to Visualforce Page and in turn passed to Flow from Visualforce**/
    public string lstAcountsSelectedIds{get;set;}
    public List < Account > SeletedAccounts {
        get;
        set;
    }
    
    public AccountInvitationController(ApexPages.StandardSetController listcontroller) {
      
        Set < Id > acountsSelectedIds = new set < Id > ();
        SeletedAccounts = new List < Account >();
            
        for (Account c: (Account[]) listcontroller.getSelected()) {
            acountsSelectedIds.add(c.id);
        }
        
        /**Querying on the Selected records and fetching fields which are required in Flow **/
        SeletedAccounts = [select Id from Account where id in: acountsSelectedIds];
        System.Debug(SeletedAccounts);
        lstAcountsSelectedIds = JSON.serialize(acountsSelectedIds);

        system.debug('listFunOppsStr--'+lstAcountsSelectedIds);
    }
    public String AccountsLV() {
        return '/lightning/o/Account/list?filterName=Recent';
    }
}