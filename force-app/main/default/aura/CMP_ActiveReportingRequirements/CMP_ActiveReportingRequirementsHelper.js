({
	
    constructActiveReportingReqsColumns: function(component, event, helper) {
        var listActiveReportingReqColumns = [];
        listActiveReportingReqColumns.push(
            {label:'Manage',type:'button',typeAttributes:{label:'View',name:'view_active_report_req',title:'View Active Reporting Requriement', variant:'brand'},hideDefaultActions:true},
            {label:'Grant Application', fieldName:'reqName', type:'text', wrapText:true, hideDefaultActions:true}
        );
        component.set('v.listActiveReportingReqColumns',listActiveReportingReqColumns);
    },
    
    fetchActiveReportingReqs : function(component, event, helper) {
        var action = component.get('c.getActiveReportingRequirements');
        action.setCallback(this,function(response){
            console.log('state--'+JSON.stringify(response.getState()));
            console.log('getReturnValue--'+JSON.stringify(response.getReturnValue()));
            if(response.getState()==='SUCCESS'){
                var returnValue = response.getReturnValue();
                if(returnValue!=null && Array.isArray(returnValue) && returnValue.length>0){
                    //console.log('returnValue--'+JSON.stringify(returnValue));
                    component.set('v.listActiveReportingReqs',returnValue);
                    component.set('v.loaded',true);
                    
                }
            }
            if(response.getState()==='ERROR'){
                var errors = response.getError();
                console.log('errors --' +JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
	},
    
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch(action.name){
            case 'view_active_report_req':
                this.navigateToYourekaForm(component, event, helper, row);
                break;
        }
    },
    
    navigateToYourekaForm : function(component, event, helper, row) {
        if(row!=null){
            if('reportingUrl' in row){
                /*console.log(row['reportingUrl']);
                var navService = component.find('navService');
                var pageReference = {
                    type: 'standard__webPage',
                    attributes:{
                        url:row['reportingUrl']
                    }
                };
                navService.navigate(pageReference); //It is encoding the url which is causing the page to error out
                */
                console.log('REPORTING URL' + row['reportingUrl']);
                window.open(row['reportingUrl'],'_blank');
            }
        }
    }
})