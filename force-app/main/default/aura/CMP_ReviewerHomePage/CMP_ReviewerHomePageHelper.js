({
    fetchPendingReviewAssignmentColumns : function(component, event, helper) {
        var listPendingReviewColumns = [];
        listPendingReviewColumns.push(
            {label:'Manage', type:'button', typeAttributes:{label:'Review', name:'submit_review',title:'Click To Submit Review',variant:'brand'}, hideDefaultActions:true},
            {label:'Grant Application', fieldName:'requestName', type:'text', wrapText:true, hideDefaultActions:true},
            {label:'Funding Opportunity', fieldName:'fundingOppName', type:'text', wrapText:true, hideDefaultActions:true},
            {label:'Requested Amount', fieldName:'grantReqAmt', type:'currency', wrapText:true, hideDefaultActions:true, cellAttributes:{alignment:'left'}},
            {label:'Stage', fieldName:'revAssignmentStageName', type:'text', wrapText:true, hideDefaultActions:true},
            {label:'Open', fieldName:'openDate', type:'date', cellAttributes:{iconName:'utility:event',iconAlternativeText:'openDate'}, hideDefaultActions:true},
            {label:'Last Updated', fieldName:'lastUpdatedStr', type:'dateTime', cellAttributes:{iconName:'utility:event',iconAlternativeText:'lastUpdatedStr'}, hideDefaultActions:true},
            {label:'Due Date', fieldName:'dueDate', type:'date', cellAttributes:{iconName:'utility:event',iconAlternativeText:'dueDate', class:{fieldName:'dueDateCSSClass'}}, hideDefaultActions:true}
        );
        component.set('v.listPendingReviewColumns',listPendingReviewColumns);
    },
    
    fetchCompletedReviewAssignmentColumns : function(component, event, helper) {
        var listCompletedReviewColumns = [];
        listCompletedReviewColumns.push(
            {label:'Manage', type:'button', typeAttributes:{label:'View Review', name:'view_review',title:'Click To View Review',variant:'brand'}, hideDefaultActions:true},
            {label:'Grant Application', fieldName:'requestName', type:'text', wrapText:true, hideDefaultActions:true},
            {label:'Funding Opportunity', fieldName:'fundingOppName', type:'text', wrapText:true, hideDefaultActions:true},
            {label:'Requested Amount', fieldName:'grantReqAmt', type:'currency', wrapText:true, hideDefaultActions:true, cellAttributes:{alignment:'left'}},
            {label:'Stage', fieldName:'revAssignmentStageName', type:'text', wrapText:true, hideDefaultActions:true},
            {label:'Open', fieldName:'openDate', type:'date', cellAttributes:{iconName:'utility:event',iconAlternativeText:'openDate'}, hideDefaultActions:true},
            {label:'Last Updated', fieldName:'lastUpdatedStr', type:'dateTime', cellAttributes:{iconName:'utility:event',iconAlternativeText:'lastUpdatedStr'}, hideDefaultActions:true},
            {label:'Due Date', fieldName:'dueDate', type:'date', cellAttributes:{iconName:'utility:event',iconAlternativeText:'dueDate'}, hideDefaultActions:true} //class:{fieldName:'dueDateCSSClass'}
        );
        component.set('v.listCompletedReviewColumns',listCompletedReviewColumns);
    },
    
    fetchUser : function(component, event, helper) {
		var action = component.get('c.getUser');
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var returnValue = response.getReturnValue();
                if(returnValue!=null && Array.isArray(returnValue) && returnValue.length>0){
                    component.set('v.userRec',returnValue[0]);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
   fetchSubmittedReviewAssignments : function(component, event, helper) {
		var action = component.get('c.getSubmittedReviewAssignments');
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var returnValue = response.getReturnValue();
                console.log('-listCompletedReviewAssignments-'+JSON.stringify(returnValue));
                if(returnValue!=null && Array.isArray(returnValue) && returnValue.length>0){
                    component.set('v.completedAssignmentsCount',returnValue.length);
                    component.set('v.listCompletedReviewAssignments',returnValue);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    fetchPendingReviewAssignments : function(component, event, helper) {
		var action = component.get('c.getPendingReviewAssignments');
        action.setCallback(this,function(response){
            console.log('PENDING--'+response.getState());
            if(response.getState()==='SUCCESS'){
                var returnValue = response.getReturnValue();
                console.log('-listPendingReviewAssignments-'+JSON.stringify(returnValue));
                if(returnValue!=null && Array.isArray(returnValue) && returnValue.length>0){
                    component.set('v.totalAssignmentsCount', (returnValue.length + component.get('v.completedAssignmentsCount')));
                    component.set('v.listPendingReviewAssignments',returnValue);
                }
            }
            if(response.getState()==='ERROR'){
                console.log(JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
	},
    
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch(action.name){
            case 'submit_review':
                this.submitReviewRowAction(component, event, helper, row);
                break;
            case 'view_review':
                this.viewReviewRowAction(component, event, helper, row);
        }
    },
    
    submitReviewRowAction : function(component, event, helper, row) {
        console.log('row--'+JSON.stringify(row));
        if('revAssId' in row){
            console.log('I AM HERE');
            var url = '/review?reviewId='+row['revAssId'];
            var navService = component.find('navService');
            var url
            var pageReference = {
                type:'standard__webPage',
                attributes:{
                    url:url
                }
            };
            navService.navigate(pageReference);
        }
    },
    
    viewReviewRowAction : function(component, event, helper, row) {
        if('revAssId' in row){
            var url = '/review?reviewId='+row['revAssId'];
            var navService = component.find('navService');
            var pageReference = {
                type:'standard__webPage',
                attributes:{
                    url:url
                }
            };
            navService.navigate(pageReference);
            
        }
    }
    
})