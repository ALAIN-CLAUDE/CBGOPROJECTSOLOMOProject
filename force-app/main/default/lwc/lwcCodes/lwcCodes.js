import { LightningElement, api } from 'lwc';
import getParentCodesAPX from '@salesforce/apex/lwcCodesAPX.getParentCodesAPX';
import getChildCodesAPX from '@salesforce/apex/lwcCodesAPX.getChildCodesAPX';
import getPreSelectedCodesAPX from '@salesforce/apex/lwcCodesAPX.getPreSelectedCodesAPX';
export default class LwcCodes extends LightningElement {
    listCodesColumns;
    listCodesRecs;
    listSelectedCodes;

    listPreSelectedCodeIds;

    listAllCodeRecs;

    listSuperParentsWithSelectedCodes;

    @api recordId;
    

    connectedCallback(){
        this.handleInitialLoad();
    }

    async handleInitialLoad(){
        this.listCodesRecs = [];
        this.listCodesColumns = [];
        this.listSelectedCodes = [];
        this.listPreSelectedCodeIds = [];
        this.listAllCodeRecs = [];
        this.listSuperParentsWithSelectedCodes = [];
        
        await this.getPreSelectedCodes();
        await this.setCodesColumns();
        await this.getParentCodes();
        // setTimeout(this.setSelectedRows(), 1500);
        await this.setSelectedRows();
        
    }

    async getPreSelectedCodes(){
        
        await getPreSelectedCodesAPX({recordId:this.recordId}).then(async listPreSelectedCodeIds=>{
            if(listPreSelectedCodeIds && Array.isArray(listPreSelectedCodeIds) && listPreSelectedCodeIds.length>0){
                console.log(`listPreSelectedCodeIds = ${JSON.stringify(listPreSelectedCodeIds)}`);
                this.listPreSelectedCodeIds = listPreSelectedCodeIds;
                // listPreSelectedCodeIds.forEach(codeId=>{
                //     this.listPreSelectedCodeIds = [...this.listPreSelectedCodeIds, codeId];
                // })
            }
        }).catch(errorInGetPreSelectedCodes=>{
            console.log(`errorInGetPreSelectedCodes = ${JSON.stringify(errorInGetPreSelectedCodes)}`);
        });
    }

    async setCodesColumns(){
        this.listCodesColumns = [
            {label:'Code',fieldName:'codeName',type:'text', wrapText:true},
            // {label:'Code Id',fieldName:'codeId',type:'text', wrapText:true}
        ];
    }

    async getParentCodes(){
        await getParentCodesAPX().then(listParentCodes=>{
            if(listParentCodes && Array.isArray(listParentCodes) && listParentCodes.length>0){
                listParentCodes.forEach(async parentCodeRec=>{
                    this.listAllCodeRecs = [...this.listAllCodeRecs, parentCodeRec];
                    if('hasChildCodeRecs' in parentCodeRec && parentCodeRec['hasChildCodeRecs']){
                        parentCodeRec['_children'] = [];
                    }
                    this.listCodesRecs = [...this.listCodesRecs, parentCodeRec];
                });
            }
        });

        // setTimeout(this.setSelectedRows(), 5000);
        await this.setSelectedRows();
    }

    async getManuallySelectedRows(){
        let treeGridCmp = this.template.querySelector('lightning-tree-grid');
        if(treeGridCmp){
            let listManuallySelctedRows = treeGridCmp.getSelectedRows();
            if(listManuallySelctedRows && Array.isArray(listManuallySelctedRows) && listManuallySelctedRows.length>0){
                listManuallySelctedRows.forEach(async manualSelectedRow=>{
                    if('codeId' in manualSelectedRow){
                        if(this.listPreSelectedCodeIds && Array.isArray(this.listPreSelectedCodeIds) && this.listPreSelectedCodeIds.length>0){
                            if(!this.listPreSelectedCodeIds.includes(manualSelectedRow['codeId'])){
                                this.listPreSelectedCodeIds = [...this.listPreSelectedCodeIds, manualSelectedRow['codeId']];
                            }
                        }
                        else{
                            this.listPreSelectedCodeIds = [];
                            this.listPreSelectedCodeIds = [...this.listPreSelectedCodeIds, manualSelectedRow['codeId']];
                        }
                    }
                });
            }
        }
    }

    async setSelectedRows(){
        
        let treeGridCmp = this.template.querySelector('lightning-tree-grid');
        if(treeGridCmp){
            console.log(`this.listPreSelectedCodeIds in selected rows =  ${JSON.stringify(this.listPreSelectedCodeIds)}` );
            treeGridCmp.selectedRows = this.listPreSelectedCodeIds;
            // console.log(`treeGridCmp.expandedrows = ${JSON.stringify(treeGridCmp.getCurrentExpandedRows())}`);
            console.log(`treeGridCmp.selectedRows = ${JSON.stringify(treeGridCmp.getSelectedRows())}`);
        }
        
    }

    handleRowToggle(event){
        if(event){
            const toggledCodeId = event.detail.name;
            console.log(`toggledCodeId = ${toggledCodeId}`);
            const hasChildContent = event.detail.hasChildrenContent;
            console.log(`hasChildContent = ${hasChildContent}`);
            if(!hasChildContent){
                this.handleGetChildCodeRecs(toggledCodeId);
            }
        }
    }

    async handleGetChildCodeRecs(toggledCodeId){
        await this.getManuallySelectedRows();
        let listChildCodeRecs = await this.getChildCodes(toggledCodeId);
        console.log(`listChildCodeRecs = ${JSON.stringify(listChildCodeRecs)}`);
        console.log(`child records retrieved`);
        this.listCodesRecs = await this.resetParentCodeWithChildCodes(toggledCodeId, this.listCodesRecs, listChildCodeRecs);
        await this.setSelectedRows();
    }

    async getChildCodes(toggledCodeId){
        let listChildCodeRecs = [];
        await getChildCodesAPX({parentCodeId:toggledCodeId}).then(async listChildCodes=>{
            console.log(`listChildCodes = ${JSON.stringify(listChildCodes)}`);
            this.listAllCodeRecs = [...this.listAllCodeRecs, ...listChildCodes];
            if(listChildCodes && Array.isArray(listChildCodes) && listChildCodes.length>0){
                listChildCodes.forEach(childCodeRec=>{
                    if('hasChildCodeRecs' in childCodeRec && childCodeRec['hasChildCodeRecs']){
                        childCodeRec['_children'] = [];
                    }
                    if(childCodeRec.isRelatedCodeAndTag){
                        this.listPreSelectedCodeIds = [...this.listPreSelectedCodeIds, childCodeRec['codeId']];
                    }
                });
            }
            listChildCodeRecs =  listChildCodes;
        });
        return listChildCodeRecs;
    }

    async resetParentCodeWithChildCodes(toggledCodeId, listCodesRecs, listChildCodeRecs){
        console.log(`resetting parent code with child codes`);
        return listCodesRecs.map(row=>{
            let hasChildren = false;
            if('_children' in row && row['_children'] && Array.isArray(row['_children']) && row['_children'].length>0){
                hasChildren = true;
            }
            if(row.codeId === toggledCodeId){
                row['_children'] = listChildCodeRecs;
            }
            else if(hasChildren){
                this.resetParentCodeWithChildCodes(toggledCodeId, row['_children'], listChildCodeRecs);
            }
            // console.log(`row = ${JSON.stringify(row)}`);
            return row;
        });
    }


    // handleNextButtonClicked(event){
    //     if(event){
    //         this.listSelectedCodes = [];
    //         let treeGridComponent = this.template.querySelector('lightning-tree-grid');
    //         if(treeGridComponent){
    //             let listSelectedRows = treeGridComponent.getSelectedRows();
    //             console.log(`listSelectedRows = ${JSON.stringify(listSelectedRows)}`);
    //             if(listSelectedRows && Array.isArray(listSelectedRows) && listSelectedRows.length>0){
    //                 listSelectedRows.forEach(selectedRow=>{
    //                     selectedRow['_children'] = [];
    //                     selectedRow['executed'] = false;
    //                     this.listSelectedCodes = [...this.listSelectedCodes, selectedRow];
    //                 });
    //             }

    //             this.getSelectedRecordsWithParents(listSelectedRows);

    //             console.log(`this.listSelectedCodes = ${JSON.stringify(this.listSelectedCodes)}`);
    //             console.log(`this.listSelectedCodes = ${this.listSelectedCodes.length}`);

    //         }
    //     }
    // }

    handleNextButtonClicked(event){
        if(event){
            this.listSelectedCodes = [];
            this.listSuperParentsWithSelectedCodes = [];
            let treeGridComponent = this.template.querySelector('lightning-tree-grid');
            if(treeGridComponent){
                let listSelectedRows = treeGridComponent.getSelectedRows();
                this.findSuperParentForSelectedRec(listSelectedRows);
            }
        }
    }

    async findSuperParentForSelectedRec(listSelectedCodes){
        if(listSelectedCodes && Array.isArray(listSelectedCodes) && listSelectedCodes.length>0){
            console.log('1. First step completed');
            await listSelectedCodes.forEach(async selectedCode=>{
                let superParentCode =  this.fetchSuperParent(selectedCode);
                console.log(`superParentCode = ${JSON.stringify(superParentCode)}`);
                console.log('2. Second step completed');
                if(superParentCode){
                    await this.formatSelectedRowsWithSuperParent(superParentCode, selectedCode)
                    console.log(`3. Third step completed`);
                }
            });
            
            console.log(`this.listSuperParentsWithSelectedCodes 1 = ${JSON.stringify(this.listSuperParentsWithSelectedCodes)}`);
            if(this.listSuperParentsWithSelectedCodes && Array.isArray(this.listSuperParentsWithSelectedCodes) && this.listSuperParentsWithSelectedCodes.length>0){
                let codesSelectedEvent = new CustomEvent('nextbuttonclick',{detail:this.listSuperParentsWithSelectedCodes});
                this.dispatchEvent(codesSelectedEvent);
            }
        }
    }
    
    fetchSuperParent(codeRec){
         // get the record -> check if it has a parent id
        //if it doesn't have a parentid. return from this method.
        //if it has a parentId find the record in the master list and call this method again
        console.log(`${codeRec['codeName']}`);
        if('parentCodeId' in codeRec && codeRec['parentCodeId']!=''){
            console.log(`${codeRec['codeName']} has parent id`);
            if(this.listAllCodeRecs && Array.isArray(this.listAllCodeRecs) && this.listAllCodeRecs.length>0){
                for (let parentCodeRec of this.listAllCodeRecs){
                    if('codeId' in parentCodeRec && parentCodeRec['codeId'] && parentCodeRec['codeId'] == codeRec['parentCodeId']){
                        console.log(`${parentCodeRec['codeName']} matched.`);
                        if('parentCodeId' in parentCodeRec && parentCodeRec['parentCodeId']!=''){
                            console.log(`${parentCodeRec['codeName']} has parentCodeId.`);
                            return this.fetchSuperParent(parentCodeRec);
                        }
                        else{
                            console.log(`${parentCodeRec['codeName']} doesn't have parentCodeId.`);
                            return parentCodeRec;
                        }
                    }
                }
            }
        }   
        else{
            console.log(`${codeRec['codeName']} is the parent code record`);
            return codeRec;
        }
    }

    async formatSelectedRowsWithSuperParent(superParent, selectedCode){
        console.log(`super parent = ${JSON.stringify(superParent)}`);
        console.log(`selectedCode = ${JSON.stringify(selectedCode)}`);
        console.log(`this.listSuperParentsWithSelectedCodes 2 = ${JSON.stringify(this.listSuperParentsWithSelectedCodes)}`);
        let superParentFound = false;
        if(selectedCode){
            if(this.listSuperParentsWithSelectedCodes && Array.isArray(this.listSuperParentsWithSelectedCodes) && this.listSuperParentsWithSelectedCodes.length>0){
                this.listSuperParentsWithSelectedCodes.forEach(async superParentCodeRec=>{
                    if(superParentCodeRec['codeId'] == superParent['codeId']){
                        superParentFound = true;
                        superParentCodeRec['selectedCodes'] =  [...superParentCodeRec['selectedCodes'], selectedCode];
                    }
                });
                if(!superParentFound){
                    let selectedCodeRec = {};
                    Object.keys(selectedCode).forEach(key=>{
                        selectedCodeRec[key] = selectedCode[key]
                    });
                    superParent['selectedCodes'] = [...[],selectedCodeRec];
                    this.listSuperParentsWithSelectedCodes =  [...this.listSuperParentsWithSelectedCodes, superParent];
                }
            }
            else{
                let selectedCodeRec = {};
                Object.keys(selectedCode).forEach(key=>{
                    selectedCodeRec[key] = selectedCode[key]
                });
                superParent['selectedCodes'] = [...[],selectedCodeRec];
                this.listSuperParentsWithSelectedCodes =  [...this.listSuperParentsWithSelectedCodes, superParent];
            }
        }
        else{
            this.listSuperParentsWithSelectedCodes =  [...this.listSuperParentsWithSelectedCodes, superParent];
        }
    }
}