import { api, LightningElement } from 'lwc';

export default class Pir_sharingOptionForm extends LightningElement {
    @api addDelegateList;
    @api addHCPDelegateList;
    @api isAddDelegates;
    @api isHCPAddDelegates;
    @api yob;
    @api existingDelegates;
    @api peDetails;
    sharingObject;
    @api participantObject;
    @api targetObject;
    @api isHCPDelegate;
    @api isRpContact;
    @api addRpList;
    buttonLabel;
    //isAddDelegate = false;
    isAddRp = false;
    isAddHcp = false;
    isDisplayAddButton = true;

    connectedCallback() {
        this.resetDelegateList();
        if(this.targetObject === 'delegate') {
            this.buttonLabel = 'Add Delegate';
        } else {
            this.buttonLabel = 'Add Provider';
        }

        if(this.targetObject === 'rp') {
            this.isDisplayAddButton = false;
        }
        this.updateExistingDelegates();
    }

    @api
    updateExistingDelegates() {
        let delegateObj;
        
        if(this.targetObject == 'delegate') {
            if(this.addDelegateList) {    
                let mergedList = this.addDelegateList;           
                for(let i=0; i<mergedList;i++) {
                    let obj = {"sObjectType": 'Object'};
                    let mergedObj = { ...mergedList[i], ...obj };                    
                    mergedList[i] = mergedObj;
                }
                this.addDelegateList = mergedList;
                this.isAddDelegates = true;
                /*this.isAddDelegates = false;
                this.isHCPDelegate = true;
                this.isAddDelegates = true;
                this.isHCPDelegate = false;*/
            }
        }
        if(this.targetObject == 'hcp') {
            if(this.addDelegateList) {
                let mergedList = this.addDelegateList;
                for(let i=0; i<mergedList.length;i++) {
                    let obj = {"sObjectType": 'Healthcare_Provider__c'};
                    let mergedObj = { ...mergedList[i], ...obj };
                    mergedList[i] = mergedObj;
                }
                this.addHCPDelegateList = mergedList;
                this.isAddHcp = true;
                /*this.isHCPDelegate = false;
                this.isHCPAddDelegates = false;
                this.isHCPDelegate = true;
                this.isHCPAddDelegates = true;*/
            }
        }
        if(this.targetObject === 'rp') {
            if(this.addDelegateList) {
                let mergedList = this.addDelegateList;                
                this.addRpList = mergedList;
                this.isAddRp = true;
                //this.isRpContact = true;
            }
        }
    }

    addDelegateFormFields() {
        let delegateObj;
        if(this.targetObject == 'delegate') {          
            delegateObj = {sObjectType:'Object'};
        } else if(this.targetObject == 'hcp'){           
            delegateObj = {sObjectType:'Healthcare_Provider__c'};
        }
        if(this.targetObject != 'rp') {
            if(!this.addDelegateList) {
                this.addDelegateList= [];
                this.addDelegateList.push(delegateObj)
            } else {
                let delegateList = [];
                delegateList.push(delegateObj);
                this.addDelegateList = [...this.addDelegateList, ...delegateList];
            }
        }

        if( this.addDelegateList.length > 0) {
            if(this.targetObject == 'delegate') {          
                this.isAddDelegates = true;                
            } else if(this.targetObject == 'hcp'){           
                this.isAddHcp = true;
            } else {
                this.isAddRp = true;
            }
        }
        
    }
    
    @api resetDelegateList() {
        this.isAddDelegates = false;
        //this.addDelegateList = [];
        this.isAddRp = false;
        this.isAddHcp = false;
    }    
    
}