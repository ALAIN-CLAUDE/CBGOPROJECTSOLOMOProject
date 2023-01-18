({
    
    displayFiscalSponsor : function(component, event, helper) {
        helper.displayFiscalSponsor(component, event, helper);
    },
    
	onsuccess : function(component, event, helper) {
		location.reload();
        alert('Your request has been submitted');
	},
    
    handleError : function(component, event, helper) {
        helper.handleError(component, event, helper);
    }
    
    
})