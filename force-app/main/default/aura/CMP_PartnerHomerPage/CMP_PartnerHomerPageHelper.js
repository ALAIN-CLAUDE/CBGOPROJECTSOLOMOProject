({
	fetchHomePageSettings : function(component,event,helper) {
		var action = component.get('c.getHomePageSettings');
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var returnValue=response.getReturnValue();
                if(returnValue!=null && Array.isArray(returnValue) && returnValue.length>0){
                    component.set('v.listHomePageSettings',returnValue);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    checkoutButtonClicked : function(component,event,helper) {
        var eventParam = event.getSource().get('v.value');
        console.log('EVENT PARAMS' + JSON.stringify(eventParam));
        var navService = component.find('navService');
        var pageReference = {
            type:'standard__webPage',
            attributes:{
                url:eventParam['URL_to_redirect__c']
            }
        }
        navService.navigate(pageReference);
    }
})