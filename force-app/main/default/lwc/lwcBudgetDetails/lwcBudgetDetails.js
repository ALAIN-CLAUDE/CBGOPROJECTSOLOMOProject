/**
 * Created by denisletkovski on 2022-06-08.
 */

import {LightningElement, track, api} from 'lwc';

export default class LwcBudgetDetails extends LightningElement {

    @track selectedBudgets;
    @track selectedBudget;
    @track isModalOpened = false;

    @api recordId;


    connectedCallback() {
        this.loaded = false;
        this.selectedBudget = this.recordId;
    }

    handleBudgetChanged(event) {
        let listBudgets = event.detail;
        if(listBudgets && Array.isArray(listBudgets) && listBudgets.length>0){
            listBudgets.forEach(budgetRec=>{
                if(budgetRec.name == 'Total'){
                    budgetRec.format = 'slds-text-color_error';
                }
            });
        }
        // console.log(`listBudgets = ${JSON.stringify(listBudgets)}`);
        this.selectedBudgets = event.detail;

    }

    handleBudgetSelection(event) {
        console.log('THERE');
        this.selectedBudget = event.detail;
        let lwcBudgetRecDetail = this.template.querySelector('c-lwc-budget-record-detail');
        if(lwcBudgetRecDetail){
            lwcBudgetRecDetail.budget = this.selectedBudget;
            lwcBudgetRecDetail.handleBudgetSelected();
        }
    }

    openModal() {
        this.isModalOpened = true;
    }

    closeModal(event) {
        this.isModalOpened = false;
        console.log(event.detail);
    }

    handleRefreshRightPanel(){
        console.log('Refresh Right Panel Event Called');
        this.handelNewBudgetCreated();
    }

    handleRefreshLeftPanel(event){
        if(event){
            if(event.detail){
                this.selectedBudget = event.detail;
                let lwcBudgetRecDetail = this.template.querySelector('c-lwc-budget-record-detail');
                if(lwcBudgetRecDetail){
                    lwcBudgetRecDetail.budget = this.selectedBudget;
                    lwcBudgetRecDetail.handleBudgetSelected();
                }
            }
        }
    }

    handelNewBudgetCreated() {
        this.template.querySelector('c-lwc-budget-filters').getNewBudgetRecords();
    }
}