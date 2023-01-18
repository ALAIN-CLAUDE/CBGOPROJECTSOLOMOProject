({
	
    testUserId : function(component, event, helper) {
        console.log('I AM HERE PART 1');
        var action = component.get('c.fetchUserId');
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchFundingRequest : function(component, event, helper) {
		var action = component.get('c.getFundingRequests');
        
        action.setCallback(this,function(response){
            console.log('response--'+response.getState());
            console.log('response--'+JSON.stringify(response.getError()));
            if(response.getState()==='SUCCESS'){
                var returnValue = response.getReturnValue();
               	console.log('returnValue--'+JSON.stringify(returnValue));
                if(returnValue!=null && Array.isArray(returnValue) && returnValue.length>0){
                    component.set('v.fundingReqExists',true);
                    component.set('v.listFundingRequests',returnValue);
                    /*component.find('projectTitleId').set('v.disabled',true);
                    component.find('goalId').set('v.disabled',true);
                    component.find('objectivesId').set('v.disabled',true);
                    component.find('targetCommId').set('v.disabled',true);
                    
                    component.find('commInvolvementId').set('v.disabled',true);
                    component.find('grantReqAmountId').set('v.disabled',true);
                    component.find('startDateId').set('v.disabled',true);
                    component.find('endDateId').set('v.disabled',true);

                    for(var fundReq of returnValue){
                        if(fundReq.Project_Title__c!=null && fundReq.Project_Title__c!=''){
                            component.find('projectTitleId').set('v.checked',true);
                        }
                        if(fundReq.Project_Goal__c!=null && fundReq.Project_Goal__c!=''){
                            component.find('goalId').set('v.checked',true);
                        }
                        if(fundReq.Objectives__c!=null && fundReq.Objectives__c!=''){
                            component.find('objectivesId').set('v.checked',true);
                        }
                        if(fundReq.Target_Communities__c!=null && fundReq.Target_Communities__c!=''){
                            component.find('targetCommId').set('v.checked',true);
                        }
                        if(fundReq.Community_Involvement__c!=null && fundReq.Community_Involvement__c!=''){
                            component.find('commInvolvementId').set('v.checked',true);
                        }
                        if(fundReq.Grant_Request_Amount__c!=null && fundReq.Grant_Request_Amount__c>0){
                            component.find('grantReqAmountId').set('v.checked',true);
                        }
                        if(fundReq.Project_Start_Date__c!=null){
                            component.find('startDateId').set('v.checked',true);
                        }
                        if(fundReq.Project_End_Date__c!=null){
                            component.find('endDateId').set('v.checked',true);
                        }
                    }*/
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    openFundingRequest : function(component, event, helper) {
        var hrefCompId = event.currentTarget.id;
        console.log('hrefCompId--'+hrefCompId)
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParam("recordId", hrefCompId);
        navEvt.fire();
        //component.set('v.fundingReqRecId',hrefCompId);
        //component.set('v.showRecordForm',true);
    },
    
    closeModal : function(component, event, helper) {
        component.set('v.fundingReqRecId',null);
        component.set('v.showRecordForm',false);
    }
})