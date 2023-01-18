/**
 * Created by denisletkovski on 2022-06-23.
 */

import {LightningElement, api, track} from 'lwc';
import getBudgetDetails from '@salesforce/apex/lwcBudgetDetailController.getTableDetail';
import getProjectedDetail from '@salesforce/apex/lwcPlanningBudgetController.getPlanningData';
import deletePlanningDollarsAPX from '@salesforce/apex/lwcPlanningBudgetController.deletePlanningDollarsAPX';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LwcBudgetRecordDetail extends LightningElement {

    @api budget
    currentBudgetId;
    @track budgetDetail;
    @track isRecordExists;
    @track tableData;
    @track projectedData

    
    isNewPlanningDollars;
    isEditPlanningDollars;
    isChildPlanningDollars;
    selectedPlanningDollarRec;
    parentPlanningDollarRecId;
    planningDollarRecId;
    openModalWindow;
    


    connectedCallback(){
        this.handleInitialLaod();
    }

    async handleInitialLaod(){
        console.log('in initial load');
        this.tableData = [];
        this.projectedData = [];
        this.isRecordExists = false;
        this.columns = [
            {type:'url',fieldName:'link',label:'Portfolio',typeAttributes:{label:{fieldName:'typePaid'},target:'_blank'}},
            // {label:'Portfolio', fieldName:'typePaid', type:'text', wrapText:true},
            {type:'number',fieldName:'amount',label:'Amount',initialWidth:125},
            {type:'text',fieldName:'projectTitle',label:'ProjectTitle'}
        ];
        this.planningColumns = [
            // {type:'url',fieldName:'projectLink',label:'Project',typeAttributes:{label:{fieldName:'projectName'},target:'_blank'}},
            {label:'Project', fieldName:'projectName', type:'text', wrapText:true},
            {type:'number',fieldName:'projectAmount',label:'Amount',initialWidth:125},
            {type:'text',fieldName:'projectNotes',label:'Notes'},
            {type:'action',typeAttributes:{rowActions:this.getRowActions}}
        ];    

        this.openModalWindow = false;
        this.isNewPlanningDollars = false;
        this.isEditPlanningDollars = false;
        this.isChildPlanningDollars = false;
        this.planningDollarRecId = '';
    }

    getRowActions(row, doneCallback) {
        const actions = [];
        if (row.isParent) {
            actions.push({
                'label': 'Child',
                'iconName': 'utility:add',
                'name': 'child',
                'class': 'opacity: 0'
            });
        }
        if (row.isAdmin) {
            actions.push({
                'label': 'Edit',
                'iconName': 'utility:edit',
                'name': 'edit',
                });
                actions.push({
                    'label': 'Delete',
                    'iconName': 'utility:delete',
                    'name': 'delete'
                });
            }
            // simulate a trip to the server
            setTimeout((() => {doneCallback(actions);}), 200);
    }

    @api async handleBudgetSelected(){
        console.log(`AD assigned ${this.budget}`);
        // if (this.budget && (this.currentBudgetId !== this.budget)) {
        //     await this.getBudgetDetails(this.budget);
        //     await this.getPlanningDetail(this.budget);
        // }
        await this.handleInitialLaod();
        await this.getBudgetDetails(this.budget);
        await this.getPlanningDetail(this.budget);
    }

    

    

    async getBudgetDetails(recordId) {
        await getBudgetDetails({
            budgetId: recordId,
        }).then((result) => {
            // let tableData = JSON.parse(JSON.stringify(result.calculationsDetails).split('childRecords').join('_children'));
            // console.log(`result = ${JSON.stringify(result)}`);
            if(result && 'calculationsDetails' in result){
                this.tableData = [];
                let listCalculationDetails = result['calculationsDetails'];
                if(listCalculationDetails && Array.isArray(listCalculationDetails) && listCalculationDetails.length>0){
                    listCalculationDetails.forEach(calcDetailRec=>{
                        let modifiedCalcDetailRec = {};
                        Object.keys(calcDetailRec).forEach(calcDetailRecKey=>{
                            if(Array.isArray(calcDetailRec[calcDetailRecKey]) && calcDetailRec[calcDetailRecKey].length>0){
                                modifiedCalcDetailRec['_children'] = calcDetailRec[calcDetailRecKey];
                            }
                            else{
                                modifiedCalcDetailRec[calcDetailRecKey] = calcDetailRec[calcDetailRecKey];
                            }
                        });
                        if(modifiedCalcDetailRec){
                            this.tableData = [...this.tableData, modifiedCalcDetailRec];
                        }
                    });
                }
            }
            this.currentBudgetId = recordId;
            this.budgetDetail = result;
            this.isRecordExists = true;
        }).catch((error) => {
                console.log('error ' + JSON.stringify(error));
        });
    }

    async getPlanningDetail(recordId) {
        await getProjectedDetail({
            budgetId: recordId,
        }).then((result) => {
            // this.projectedData = JSON.parse(JSON.stringify(result).split('child').join('_children'));
            console.log(`result = ${JSON.stringify(result)}`);
            let listProjectData = result;
            if(listProjectData && Array.isArray(listProjectData) && listProjectData.length>0){
                listProjectData.forEach(projDataRec => {
                    let modifiedProjDataRec = {};
                    Object.keys(projDataRec).forEach(projDataKey=>{
                        if(projDataRec[projDataKey]){
                            if(Array.isArray(projDataRec[projDataKey]) && projDataRec[projDataKey].length>0){
                                modifiedProjDataRec['_children'] = projDataRec[projDataKey];
                            }
                            else{
                                modifiedProjDataRec[projDataKey] = projDataRec[projDataKey];
                            }
                        }
                    });
                    if(modifiedProjDataRec){
                        this.projectedData = [...this.projectedData, modifiedProjDataRec];
                    }
                });
            }
            this.currentBudgetId = recordId;
            this.isRecordExists = true;
        }).catch((error) => {
            console.log('error ' + JSON.stringify(error));
        });
    }

    handleNewPlanningDollarsButtonClick(event){
        if(event){
            this.handleNewPlanningDollars();
        }
    }

    handleRowActions(event) {
        if(event){
            const action = event.detail.action;
            const row = event.detail.row;
            console.log(`selectedRow = ${JSON.stringify(row)}`);
            this.selectedPlanningDollarRec = row;
            switch (action.name){
                case 'child':
                    this.handleChildPlanningDollars();
                    break;
                case 'edit':
                    this.handleEditPlanningDollars();
                    break;
                case 'delete':
                    this.handleDeletePlanningDollars();
                    break;
            }
        }
    }


    async handleNewPlanningDollars(){
        this.isNewPlanningDollars = true;
        this.isEditPlanningDollars = false;
        this.isChildPlanningDollars = false;
        this.parentPlanningDollarRecId = '';
        this.planningDollarRecId = '';
        this.openModalWindow = true;
    }

    async handleEditPlanningDollars(){
        this.isNewPlanningDollars = false;
        this.isEditPlanningDollars = true;
        this.isChildPlanningDollars = false;
        this.parentPlanningDollarRecId = '';
        this.planningDollarRecId = this.selectedPlanningDollarRec.planningDollarRecId;
        this.openModalWindow = true;
    }


    async handleChildPlanningDollars(){
        this.isNewPlanningDollars = false;
        this.isEditPlanningDollars = false;
        this.isChildPlanningDollars = true;
        this.parentPlanningDollarRecId = this.selectedPlanningDollarRec.planningDollarRecId;
        this.planningDollarRecId = '';
        this.openModalWindow = true;
    }

    async handleDeletePlanningDollars(){
        this.planningDollarRecId = this.selectedPlanningDollarRec.planningDollarRecId;
        await this.deletePlanningDollars();
    }

    async deletePlanningDollars(){
        await deletePlanningDollarsAPX({planningDollarsRecId:this.planningDollarRecId}).then(strSaveResults=>{
            let listSaveResults = JSON.parse(strSaveResults);
            console.log(`listSaveResults = ${JSON.stringify(listSaveResults)}`);
            if(listSaveResults && Array.isArray(listSaveResults) && listSaveResults.length>0){
                listSaveResults.forEach(saveResRec=>{
                    if('success' in saveResRec && saveResRec['success']){
                        const deleteSuccessEvent = new ShowToastEvent({
                            title:'SUCCESS!!',
                            message:'Record Deleted',
                            variant:'success',
                            mode:'dismissible'
                        });
                        this.dispatchEvent(deleteSuccessEvent);

                    }
                });
            }
        }).catch(errorInDeletePlanningDollars=>{
            console.log(`errorInDeletePlanningDollars = ${JSON.stringify(errorInDeletePlanningDollars)}`);
        });
        await this.handleBudgetSelected();
    }

    async handleCloseModalWindow(event){
        this.openModalWindow = false;
    }

    async handleRecordFormSuccess(event){
        if(event){
            if(this.isEditPlanningDollars){
                let editSuccessEvent = new ShowToastEvent({
                    title:'SUCCESS!!',
                    message:'Record updated.',
                    variant:'success',
                    mode:'dismissible'
                });
                this.dispatchEvent(editSuccessEvent);
            }
            if(this.isNewPlanningDollars || this.isChildPlanningDollars){
                let newRecSuccessEvent = new ShowToastEvent({
                    title:'SUCCESS!!',
                    message:'Record created.',
                    variant:'success',
                    mode:'dismissible'
                });
                this.dispatchEvent(newRecSuccessEvent);
            }
            await this.handleBudgetSelected();
            await this.handleCloseModalWindow(null);
            await this.refreshRightPanel();
        }
    }

    async refreshRightPanel(){
        const refreshRightPanel = new CustomEvent('refreshrightpanel',{detail:''});
        this.dispatchEvent(refreshRightPanel);
    }
}