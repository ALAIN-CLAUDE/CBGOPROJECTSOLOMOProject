/**
 * Created by denisletkovski on 2022-07-07.
 */

import {LightningElement, api, track} from 'lwc';
// import createBudget from '@salesforce/apex/lwcBudgetController.createBudget';
import getPortfolioName from '@salesforce/apex/lwcBudgetController.getPortfolioNameById';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class LwcNewBudgetModal extends LightningElement {
    @api portfolio;
    @api fiscalYear;
    @api amount;
    @api isClone;
    @api parentId;
    @api name;
    @api recordId;
    @api isEdit;
    @track buttonLabel;


    budgetId;
    portfolioName = '';

    closeModal() {
        this.clearValues();
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }

    connectedCallback() {
        if(this.recordId && this.recordId!=''){
            this.budgetId = this.recordId;
        }
        if (this.isEdit) {
            this.buttonLabel = 'Edit'
        } else if (this.isClone) {
            this.buttonLabel = 'Clone'
            this.recordId = '';
        } else {
            this.buttonLabel = 'Create'
            this.recordId = '';
        }
    }

    // createBudget() {
    //     createBudget({
    //             fiscalYear: this.fiscalYear,
    //             amount: this.amount,
    //             portfolioId: this.portfolio,
    //             parentId: this.parentId,
    //             name: this.name,
    //             recordId: this.recordId
    //         }).then((result) => {
    //                 this.showToast();
    //                 this.clearValues();
    //                 this.refreshData();
    //                 this.closeModal();
    //                 this.getNewBudgetList();
    //             })
    //             .catch((error) => {
    //                 console.log('error ' + JSON.stringify(error));
    //             });
    // }

    async showToast() {
        let message = 'Budget Successfully ';
        if (this.isEdit) {
            message += 'Edited';
        } else if (this.isClone) {
            message += 'Cloned'
        } else {
            message += 'Created';
        }
        const event = new ShowToastEvent({
            title: 'Success!',
            message: message,
            variant: 'success'
        });
        this.dispatchEvent(event);
    }

     async clearValues() {
        this.portfolio = '';
        this.amount = '';
        this.fiscalYear = '';
        this.parentId = '';
        this.recordId = '';
        this.isClone = false;
        this.isEdit = '';
     }

     refreshData() {
         const refreshEvent = new CustomEvent('refresh', {});
         this.dispatchEvent(refreshEvent);
     }

     handleAmountChange(event) {
         this.amount = event.target.value;
     }

     handleFyChange(event) {
        this.fiscalYear = event.target.value;
        this.updateBudgetName();
     }

     handlePortfolioChange(event) {
        if(event && event.target && event.target.value){
            if(event.target.value.toString()!=''){
                this.portfolio = event.target.value.toString();
                this.updateBudgetName();
            }
        }
     }

     async getSelectedPortfolioName() {
        console.log(`this.portfolio = ${this.portfolio}`);
        await getPortfolioName({portfolioRecId:this.portfolio}).then(portfolioName => {
            this.portfolioName = portfolioName;
            })
            .catch((error) => {
                console.log('error ' + JSON.stringify(error));
            });
    }

     async updateBudgetName(){
        let name= '';
        if(this.fiscalYear!=null && this.fiscalYear!=''){
            name = this.fiscalYear;
        }
        if(this.portfolio!=null && this.portfolio!=''){
            await this.getSelectedPortfolioName();
            console.log(`this.portfolioName = ${this.portfolioName}`);
            name += ' ' + this.portfolioName;
        }
        this.name = name;
     }

     handleNameChange(event) {
        this.name = event.target.value;
     }

     async handleBudgetScenarioCreateSuccess(event){
        if(event){
            await this.showToast();
            await this.clearValues();
            this.refreshData();
            this.closeModal();
            await this.handleLeftPanelRefresh();
        }
     }

    async handleLeftPanelRefresh(){
        const leftPanelRefreshEvent = new CustomEvent('leftpanelrefresh', {detail:this.budgetId});
        this.dispatchEvent(leftPanelRefreshEvent);
     }
}