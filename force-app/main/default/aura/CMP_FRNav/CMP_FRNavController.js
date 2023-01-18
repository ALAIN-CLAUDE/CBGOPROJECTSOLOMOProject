({
    returnFundingOpps : function(component, event, helper) {
        helper.returnFundingOppsV2(component, event, helper);
        /*helper.setAdminId(component, event, helper).then($A.getCallback(function(result){
            console.log('result--'+result);
            
        }));*/
    },
    
    returnFundingRequests : function(component, event, helper) {
        helper.returnFundingRequests(component, event, helper);
    },
    
    handleVerticalNavigationSelect : function(component, event, helper) {
        helper.handleVerticalNavigationSelect(component, event, helper);
    },
    
    handleFlowStatusChange : function(component, event, helper) {
        console.log('event.getParam--' +event.getParam('status'));
    }
})