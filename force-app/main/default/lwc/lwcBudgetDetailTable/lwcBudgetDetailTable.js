/**
 * Created by denisletkovski on 2022-06-08.
 */

import {LightningElement, api, track} from 'lwc';

export default class LwcBudgetDetailTable extends LightningElement {
    @api budgets;
    @api total;
    isModalOpened = false;
    @track amountForClone = '';
    @track portfolioForClone = '';
    @track yearForClone = '';
    @track isClone = false;
    @track nameForClone = '';
    @track parentBudgetId = '';
    @track isDeleteModalOpened = false;
    @track isHasChild;
    @track recordIdForDelete;
    @track recordId;
    @track isEdit;
    @track currentExpanded = [];

    columns;
    hasRendered = true;

   
    
    


    

    async connectedCallback(){
        // loadStyle(this, cssResource);
        await this.handleInitialLoad();
    }

    

    async handleInitialLoad(){
        // ,cellAttributes: {class: {fieldName: 'format'}}
        const columns = [
            {type: 'text',fieldName: 'name',label: 'Portfolio',initialWidth: 200},
            {type: 'number',fieldName: 'budget',label: 'Budget'},
            {type: 'number',fieldName: 'paid',label: 'Paid'},
            {type: 'number',fieldName: 'approved',label: 'Approved'},
            {type: 'number',fieldName: 'invited', label: 'Invited/In Process'},
            {type: 'number',fieldName: 'planning',label: 'Planning'},
            {type: 'number',fieldName: 'remaining', label: 'Remaining'},
            { type: 'action', typeAttributes: { rowActions: this.getRowActions }}
        ];
        this.columns = columns;
        // console.log(`left panel columns = ${JSON.stringify(this.columns)}`);
    }

    getRowActions(row, doneCallback) {
        if (row.name !== 'Total') {
            const actions = [];
            if (row.isParent) {
                actions.push({
                    'label': 'Clone',
                    'iconName': 'utility:add',
                    'name': 'clone',
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
            actions.push({
                'label': 'View Details',
                'iconName': 'utility:preview',
                'name': 'detail'
            });

            // simulate a trip to the server
            setTimeout((() => {doneCallback(actions);}), 200);
        } else {
            row.cssClass = 'slds-hidden';
        }
    }

    handleAction(event) {
        let rowDetail = event.detail.row;
        let rowAction = event.detail.action.name;
        switch (rowAction) {
            case 'clone':
                this.cloneBudget(rowDetail);
                break;
            case 'edit':
                this.editBudget(rowDetail);
                break;
            case 'delete':
                this.deleteSelected(rowDetail);
                break;
            case 'detail' :
                this.rowSelected(rowDetail);
                break;
        }
    }

    cloneBudget(row) {
        this.amountForClone = row.budget;
        this.portfolioForClone = row.portfolioId;
        this.yearForClone = row.fy;
        this.parentBudgetId = row.parentBudgetId;
        this.nameForClone = row.name;
        this.isEdit = false;
        this.openModal();
        this.isClone = true;
    }

    editBudget(row) {
        this.amountForClone = row.budget;
        this.portfolioForClone = row.portfolioId;
        this.yearForClone = row.fy;
        this.parentBudgetId = row.currentParentBudgetId;
        this.nameForClone = row.name;
        this.recordId = row.parentBudgetId;
        this.isEdit = true;
        this.isClone = false;
        this.openModal();
    }

    deleteSelected(row) {
        this.recordIdForDelete = row.parentBudgetId;
        this.isHasChild = row.numberOfChildes > 0;
        this.isDeleteModalOpened = true;
    }

    handleCloseDelete(event) {
        if (event.detail) {
            this.getNewBudgetList();
            
        }
        this.isDeleteModalOpened = false;
        this.refreshAfterDelete();
    }

    refreshAfterDelete(){
        const refreshBudget = new CustomEvent('selected', {
            detail: null
        });
        this.dispatchEvent(refreshBudget);
    }

     rowSelected(row) {
        const budgetSelected = new CustomEvent('selected', {
            detail: row.parentBudgetId
        });
        this.dispatchEvent(budgetSelected);
     }

    openModal(event) {
        this.isClone = false;
        this.isModalOpened = true;
    }

    closeModal() {
        this.nameForClone = '';
        this.amountForClone = '';
        this.portfolioForClone = '';
        this.yearForClone = '';
        this.parentBudgetId = '';
        this.recordId = '';
        this.isModalOpened = false;
    }

    getNewBudgetList() {
        const create = new CustomEvent('create', {});
        this.dispatchEvent(create);
    }

    handleLeftPanelRefresh(event){
        console.log(`left panel refresh in lwcBudgetDetailTable = ${event.detail}`);
        if(event && event.detail && event.detail!=''){
            const leftPanelRefresh = new CustomEvent('leftpanelrefresh', {detail:event.detail});
            this.dispatchEvent(leftPanelRefresh);
        }
        
    }
}