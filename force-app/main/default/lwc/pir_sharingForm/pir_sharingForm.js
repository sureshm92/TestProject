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
    buttonLabel;

    connectedCallback() {
        this.resetDelegateList();
        if(this.targetObject === 'delegate') {
            this.buttonLabel = 'Add Delegate';
        } else {
            this.buttonLabel = 'Add Provider';
        }
        this.updateExistingDelegates();
    }

    @api
    updateExistingDelegates() {
        if(this.targetObject == 'delegate') {
            if(this.addDelegateList) {    
                let mergedList = this.addDelegateList;           
                for(let i=0; i<mergedList;i++) {
                    let obj = {"sObjectType": 'Object'};
                    let mergedObj = { ...mergedList[i], ...obj };                    
                    mergedList[i] = mergedObj;
                }
                this.addDelegateList = mergedList;
                this.isAddDelegates = false;
                this.isHCPDelegate = true;
                this.isAddDelegates = true;
                this.isHCPDelegate = false;
            }
        }
        if(this.targetObject == 'hcp') {
            if(this.addHCPDelegateList) {
                let mergedList = this.addHCPDelegateList;
                for(let i=0; i<mergedList.length;i++) {
                    let obj = {"sObjectType": 'Healthcare_Provider__c'};
                    let mergedObj = { ...mergedList[i], ...obj };
                    mergedList[i] = mergedObj;
                }
                this.addHCPDelegateList = mergedList;
                this.isHCPDelegate = false;
                this.isHCPAddDelegates = false;
                this.isHCPDelegate = true;
                this.isHCPAddDelegates = true;
            }
        }
    }

    addDelegateFormFields() {
        if(this.targetObject == 'delegate') {
            this.isAddDelegates = false;
            this.isHCPDelegate = true;
            let delegateObj = {sObjectType:'Object'};
            
            if(!this.addDelegateList) {
                this.addDelegateList= [];
                this.addDelegateList.push(delegateObj)
            } else {
                let delegateList = [];
                delegateList.push(delegateObj);
                this.addDelegateList = [...this.addDelegateList, ...delegateList];
            }
            if( this.addDelegateList.length >= 0) {            
                this.isAddDelegates = true;     
                this.isHCPDelegate = false;  
            }
        } else {
            this.isHCPAddDelegates = false;
            this.isHCPDelegate = false;
            let hcpDelegateObj = {sObjectType:'Healthcare_Provider__c'};

            if(!this.addHCPDelegateList) {
                this.addHCPDelegateList= [];
                this.addHCPDelegateList.push(hcpDelegateObj)
            } else {
                let hcpDelegateList = [];
                hcpDelegateList.push(hcpDelegateObj);
                this.addHCPDelegateList = [...this.addHCPDelegateList, ...hcpDelegateList];
            }

            if( this.addHCPDelegateList.length >= 0) {            
                this.isHCPAddDelegates = true;   
                this.isHCPDelegate = true;     
            }
        }
    }
    
    @api resetDelegateList() {
        this.isAddDelegates = false;
        this.addDelegateList = [];
        this.isHCPAddDelegates = false;
        this.addHCPDelegateList = [];
    }    
    
}