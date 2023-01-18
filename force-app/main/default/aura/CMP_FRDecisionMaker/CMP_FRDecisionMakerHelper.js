({
    /*
    getLoggedInUserAccountId : function(component, event, helper) {
        let action = component.get('c.getLoggedInUserAccountId_APX');
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                let returnValue = response.getReturnValue();
                let flow = component.find("frDecisionNav");
                let inputVars = [{
                    name:'Account_id',
                    type:'String',
                    value:returnValue
                }];
                flow.startFlow($A.get('$Label.c.FRContinuationOrNewOne_Flow_Name'),inputVars);
            }
            if(response.getState()==='ERROR'){
                console.log('ERROR - checkIfEligibleToContinue ' + JSON.stringify(response.getError()));
            } 
        });
        $A.enqueueAction(action);
    },
    
    getFundingRequestsV2 : function(component, event, helper) {
        let action = component.get('c.getFundingRequests_APX');
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                let returnValue = response.getReturnValue();
                console.log('returnValue -- ' + returnValue);
                if(returnValue!=null && returnValue!=''){
                    if(returnValue=='continue'){
                        component.set('v.showContButton', true);
                    }
                    if(returnValue=='new'){
                        component.set('v.showNewButton', true);
                    }
                }
            }

            if(response.getState()==='ERROR'){
                console.log('ERROR - checkIfEligibleToContinue ' + JSON.stringify(response.getError()));
            }   
        });
        $A.enqueueAction(action);
    },

    */

    getFundingRequests : function(component, event, helper) {
        let action = component.get('c.getFundingRequests_APX');
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                let returnValue = response.getReturnValue();
                console.log('returnValue -- ' + JSON.stringify(returnValue));
                if(returnValue!=null && Array.isArray(returnValue) && returnValue.length>0){
                    let flow = component.find("frDecisionNav");
                    let inputVars = [
                        {
                            name:'Fo_id',
                            type:'String',
                            value:returnValue[0].Funding_Opportunity__c
                        },
                        {
                            name:'FR_id',
                            type:'String',
                            value:returnValue[0].Id
                        }
                ];
                    flow.startFlow($A.get('$Label.c.FRContinuationOrNewOne_Flow_Name'),inputVars);
                }
            }

            if(response.getState()==='ERROR'){
                console.log('ERROR - checkIfEligibleToContinue ' + JSON.stringify(response.getError()));
            }   
        });
        $A.enqueueAction(action);
    }
})