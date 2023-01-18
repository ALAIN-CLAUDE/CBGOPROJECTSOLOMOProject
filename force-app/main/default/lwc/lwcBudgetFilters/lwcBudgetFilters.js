/**
 * Created by denisletkovski on 2022-06-08.
 */

import {LightningElement, track, wire, api} from 'lwc';
import getPortfolioName from '@salesforce/apex/lwcBudgetController.getPortfolioNameById';
import getBudgetsByFilter from '@salesforce/apex/lwcBudgetController.getBudgetListsByFilter';


export default class LwcBudgetFilters extends LightningElement {

    @track fiscalYears
    portfolioIds = [];
    yearsSelected = [];
    @track compoundFilterList = [];
    currentPortfolioName;
    selectedPortfolioId;

    portfolioMap = {};


    connectedCallback() {
        this.handleInitialLoad();
        this.getBudgetRecords();
    }

    async handleInitialLoad(){
        this.selectedPortfolioId = '';
    }

    getBudgetRecords() {
        getBudgetsByFilter({
            selectedYears: this.yearsSelected,
            selectedPortfolioIds: this.portfolioIds
        })
            .then((result) => {
                console.log(`budget records = ${JSON.stringify(result)}`);
                let finalList;
                if (JSON.stringify(result).includes('children')) {
                    let tempjson = JSON.parse(JSON.stringify(result).split('children').join('_children'));
                    finalList = tempjson;
                } else {
                    finalList = result
                }
                const budgetListChanged = new CustomEvent('budget', {
                    detail: finalList
                });
                this.dispatchEvent(budgetListChanged);
            })
            .catch((error) => {
                console.log('error ' + JSON.stringify(error));
            });
    }

    @api
    getNewBudgetRecords() {
        this.getBudgetRecords();
    }



    handleYearSelection(event) {
        if(event){
            if(event && event.detail && event.detail.value && event.detail.value!=''){
                this.yearsSelected.push(event.detail.value);
                this.compoundFilterList.push({
                    Name: event.detail.value,
                    Id: event.detail.value,
                });
                this.getBudgetRecords();
            }
        }
       
    }

    handlePortfolioSelected(event) {
        //we get event.detail.value as object from a lookup field. So changing it to string
        if(event && event.detail && event.detail.value){
            if(event.detail.value.toString()!=''){
                this.selectedPortfolioId = event.detail.value.toString();
                this.portfolioIds.push(event.detail.value.toString());
                this.filterBudgetsByPortfolio();
            }
        }
    }

    async filterBudgetsByPortfolio(){
        await this.getSelectedPortfolioName();
        await this.updateCompoundFilterList();
        this.getBudgetRecords();
    }

    async getSelectedPortfolioName() {
        await getPortfolioName({portfolioRecId:this.selectedPortfolioId}).then(portfolioName => {
                this.currentPortfolioName = portfolioName;
                this.portfolioMap[this.selectedPortfolioId] = portfolioName;
            })
            .catch((error) => {
                console.log('error ' + JSON.stringify(error));
            });
    }

    async updateCompoundFilterList(){
        let listSelectedFiscalYears = [];
        let listSelectedPortfolioIds = [];
        this.compoundFilterList = [];
        if(this.yearsSelected && Array.isArray(this.yearsSelected) && this.yearsSelected.length>0){
            listSelectedFiscalYears = [...new Set(this.yearsSelected)];
        }
        if(this.portfolioIds && Array.isArray(this.portfolioIds) && this.portfolioIds.length>0){
            listSelectedPortfolioIds = [...new Set(this.portfolioIds)];
        }
        if(listSelectedFiscalYears && Array.isArray(listSelectedFiscalYears) && listSelectedFiscalYears.length>0){
            listSelectedFiscalYears.forEach(fscYear=>{
                this.compoundFilterList.push({
                    Name: fscYear,
                    Id: fscYear
                });
            });
        }
        this.yearsSelected = listSelectedFiscalYears;
        this.portfolioIds = listSelectedPortfolioIds;
        if(listSelectedPortfolioIds && Array.isArray(listSelectedPortfolioIds) && listSelectedPortfolioIds.length>0){
            listSelectedPortfolioIds.forEach(portfolioId=>{
                if(this.portfolioMap && portfolioId in this.portfolioMap)
                this.compoundFilterList.push({
                    Name: this.portfolioMap[portfolioId],
                    Id: portfolioId
                });
            });
        }
    }

    handleRemovePill(event){
        if(event && event.target && event.target.label && event.target.label!='' && event.target.name && event.target.name!=''){
            console.log(`event.target.name ${event.target.name}`);
            console.log(`event.target.value ${event.target.label}`);
            if(this.compoundFilterList && Array.isArray(this.compoundFilterList) && this.compoundFilterList.length>0){
                this.compoundFilterList.forEach((cmpFilterRec, index)=>{
                    if(cmpFilterRec['Id'] == event.target.name){
                        this.compoundFilterList.splice(index, 1);
                    }
                });
            }

            if(this.portfolioIds && Array.isArray(this.portfolioIds) && this.portfolioIds.length>0){
                let clearPortfoliofieldValue = false;
                this.portfolioIds.forEach((portfolioId, index)=>{
                    if(portfolioId == event.target.name){
                        this.portfolioIds.splice(index, 1);
                        clearPortfoliofieldValue = true;
                    }
                });
                if(clearPortfoliofieldValue){
                    let portfolioFieldElement = this.template.querySelector("lightning-input-field[data-field-name='portfolio']");
                    if(portfolioFieldElement){
                        portfolioFieldElement.value = null;
                    }
                }
                
            }

            if(this.yearsSelected && Array.isArray(this.yearsSelected) && this.yearsSelected.length>0){
                let clearFiscalYearValue = false;
                this.yearsSelected.forEach((selectedYear, index)=>{
                    if(selectedYear == event.target.name){
                        this.yearsSelected.splice(index, 1);
                        clearFiscalYearValue = true;
                    }
                });
                if(clearFiscalYearValue){
                    let fiscalYearFieldElement = this.template.querySelector("lightning-input-field[data-field-name='fiscalYear']");
                    if(fiscalYearFieldElement){
                        fiscalYearFieldElement.value = null;
                    }
                }
            }

            this.getBudgetRecords();
        }
    }
}