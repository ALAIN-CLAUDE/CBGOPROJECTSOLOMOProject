({
    fetchSPAColumns : function(component,event,helper) {
        var listSPAColumns = [];
        listSPAColumns.push({label:'Name',fieldName:'SPA_Number_Name__c',type:'text'});
        component.set('v.listSPAColumns',listSPAColumns);
    },
    
    fetchPortfolioColumns : function(component,event,helper) {
        var listPortfolioColumns = [];
        listPortfolioColumns.push({label:'Name',fieldName:'value',type:'text'}
                               );
        component.set('v.listPortfolioColumns',listPortfolioColumns);
    },
    
    fetchOrgTypeColumns : function(component,event,helper) {
        var listOrgTypeColumns = [];
        listOrgTypeColumns.push({label:'Name',fieldName:'value',type:'text'}
                               );
        component.set('v.listOrgTypeColumns',listOrgTypeColumns);
    },
    
    fetchAccountColumns : function(component,event,helper) {
        var listAccountColumns = [];
        listAccountColumns.push({label:'Name',fieldName:'Name',type:'text'},
                                {label:'Portfolio',fieldName:'Portfolio__c',type:'text'},
                                {label:'Organization Type',fieldName:'Organization_Type__c',type:'text'}
                               );
        component.set('v.listAccountColumns',listAccountColumns);
    },
    
    
    
	fetchSPAs : function(component,event,helper) {
        helper.clearValues(component,event,helper);
		var action = component.get('c.getSPAs');
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var returnVal = response.getReturnValue();
                console.log('returnVal---'+JSON.stringify(returnVal));
                component.set('v.listSPAs',returnVal);
                component.set('v.displaySPAList',true);
            }
        });
        $A.enqueueAction(action);
	},
    
    fetchPortfolios : function(component,event,helper) {
        var listPortFolios = [];
        var action = component.get('c.getPicklistValues');
        action.setParams({objectApiName:'Account',
                          fieldApiName:'Portfolio__c'
                         });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var returnValue = response.getReturnValue();
                if(returnValue!=null && Array.isArray(returnValue) && returnValue.length>0){
                    for(var paramVal of returnValue){
                        listPortFolios.push({label:paramVal,value:paramVal});
                    }
                    component.set('v.listPortFolios',listPortFolios);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchOrgTypes : function(component,event,helper) {
        var listOrgTypes = [];
        var action = component.get('c.getPicklistValues');
        action.setParams({objectApiName:'Account',
                          fieldApiName:'Organization_Type__c'
                         });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var returnValue = response.getReturnValue();
                if(returnValue!=null && Array.isArray(returnValue) && returnValue.length>0){
                    for(var paramVal of returnValue){
                        listOrgTypes.push({label:paramVal,value:paramVal});
                    }
                    component.set('v.listOrgTypes',listOrgTypes);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    spaSelected : function(component,event,helper) {
        var listSelectedSPAs = event.getParam('selectedRows');
        console.log('listSelectedSPAs--'+JSON.stringify(listSelectedSPAs));
        component.set('v.listSelectedSPAs',listSelectedSPAs);
        helper.displayAccounts(component,event,helper);
    },
    
    portfolioSelected : function(component,event,helper) {
        var listSelectedPortfolios = event.getParam('selectedRows');
        console.log('listSelectedPortfolios--'+JSON.stringify(listSelectedPortfolios));
        component.set('v.listSelectedPortfolios',listSelectedPortfolios);
        helper.displayAccounts(component,event,helper);
    },
    
    orgTypeSelected : function(component,event,helper) {
        var listSelectedOrgTypes = event.getParam('selectedRows');
        console.log('listSelectedOrgTypes--'+JSON.stringify(listSelectedOrgTypes));
        component.set('v.listSelectedOrgTypes',listSelectedOrgTypes);
        helper.displayAccounts(component,event,helper);
    },
    
    displayAccounts : function(component,event,helper) {
        component.set('v.displayAccounts',false);
        var listSelectedSPAs = component.get('v.listSelectedSPAs');
        var listSelectedPortfolios = component.get('v.listSelectedPortfolios');
        var listSelectedOrgTypes = component.get('v.listSelectedOrgTypes');
        var listPortFolios = [];
        var listOrgTypes = [];
        var spaListStr = '';
        if(listSelectedSPAs!=null && Array.isArray(listSelectedSPAs) && listSelectedSPAs.length>0){
            spaListStr = JSON.stringify(listSelectedSPAs);
        }
        if(listSelectedPortfolios!=null && Array.isArray(listSelectedPortfolios) && listSelectedPortfolios.length>0){
            for(var portFolio of listSelectedPortfolios){
                listPortFolios.push(portFolio.value);
            }
        }
        if(listSelectedOrgTypes!=null && Array.isArray(listSelectedOrgTypes) && listSelectedOrgTypes.length>0){
            for(var orgType of listSelectedOrgTypes){
                listOrgTypes.push(orgType.value);
            }
        }
         
       /* var selectedPortfolio = component.find('selectedPortfolio').get('v.value');
        var selectedOrgType = component.find('selectedOrgType').get('v.value');
        console.log('listSelectedSPAs--'+JSON.stringify(listSelectedSPAs));
        console.log('selectedPortfolio--'+JSON.stringify(selectedPortfolio));
        console.log('selectedOrgType--'+JSON.stringify(selectedOrgType));*/
        
        var action = component.get('c.getAccounts');
        action.setParams({spaListStr:spaListStr,
                          listPortFolios:listPortFolios,
                          listOrgTypes:listOrgTypes
                         });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var returnValue = response.getReturnValue();
                console.log('returnValue---'+JSON.stringify(returnValue));
                if(returnValue!=null && Array.isArray(returnValue) && returnValue.length>0){
                    component.set('v.listAccounts',returnValue);
                    component.set('v.displayAccounts',true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    accountSelected : function(component,event,helper) {
        var listSelectedAccounts = event.getParam('selectedRows');
        component.set('v.listSelectedAccounts',listSelectedAccounts);
    },
    
    createFundingRequests : function(component,event,helper) {
        var listSelectedAccounts = component.get('v.listSelectedAccounts');
        var accountListStr = '';
        if(listSelectedAccounts!=null && Array.isArray(listSelectedAccounts) && listSelectedAccounts.length>0){
            accountListStr = JSON.stringify(listSelectedAccounts);
        }
        var action = component.get('c.insertFundingRequests');
        action.setParams({accountListStr:accountListStr,
                          recordId:component.get('v.recordId')
                         });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var navService = component.find('navService');
                var pageReference = {
                    type:'standard__objectPage',
                    attributes:{
                        objectApiName:'Funding_Request__c',
                        actionName:'list'
                    },
                    state:{
                        filterName:'Created_Today'
                    }
                }
                component.set('v.pageReference',pageReference);
                navService.navigate(pageReference);
            }
        });
        $A.enqueueAction(action);
    },
    
    clearValues : function(component,event,helper){
        component.set('v.listSelectedSPAs',null);
        component.set('v.listSelectedAccounts',null);
        component.set('v.listAccounts',null);
        component.set('v.listSPAs',null);
    }
    
    
})