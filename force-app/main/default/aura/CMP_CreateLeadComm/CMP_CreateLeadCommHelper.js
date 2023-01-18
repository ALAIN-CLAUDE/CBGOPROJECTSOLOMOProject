({
	displayFiscalSponsor : function(component, event, helper) {
		var X501Org = component.find('501Orgnaization').get('v.value');
        component.set('v.X501Org',X501Org);
	},
    
    handleError : function(component, event, helper) {
        console.log('eventParams ' + JSON.stringify(event.getParams()));
        console.log('message ' + JSON.stringify(event.getParam('message')));
        console.log('detail ' + JSON.stringify(event.getParam('detail')));
        console.log('error ' + JSON.stringify(event.getParam('error')));
    }
})