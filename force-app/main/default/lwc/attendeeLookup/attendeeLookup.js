import { LightningElement,api,track } from 'lwc';

const cbClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
const isMenuOpen = ' slds-is-open';
export default class MultiLookup extends LightningElement {
    @api placeHolder = 'Search...';
    @track optionsToDisplay = [];
    @track selectedOptions = [];
    @track showSelectedOptions = false;
    @track cbComputedClass = cbClass;
    @track isComboExpanded = false;
    @track searchKey;
    @track noResultsFound = false;
    @api hideButtonIcon = false;
    _options = [];
    selOptionsMap = new Map();

    @api selectedElementIds;
    @api get selectedElements(){
        return this.selectedElementIds;
    };
    set selectedElements(value){
        this.selectedElementIds = value; 

        console.log('this.selectedElementIds :',this.selectedElementIds);
        if(this.selectedElementIds!==undefined){
            this.handleSelection();
        }
    }

    @api removeElementId;
    @api get removeElement(){
        return this.removeElementId;
    };
    set removeElement(value){
        this.removeElementId = value;
        console.log('this.removeElementId :',this.removeElementId);
        console.log('this.removeElementId :',this.removeElementId.name);
        console.log('this.removeElementId :',this.removeElementId.id);
        console.log('this.removeElementId :',this.removeElementId.index);
        if(this.removeElementId.name!==''){
            this.removeSelectedOption();
        }
            
    }

    @api
    get options(){
        return this._options;
    }

    set options(value){
        console.log('Options :',value);
        this._options = [];
        this.optionsToDisplay = [];
        let i=0;
        value.forEach((opt) => {
            
            let obj = {...opt};
            obj.index = i++;
            obj.id = obj.label;
            //obj.index = obj.label;
            obj.hasIcon = obj.icon ? true : false;
            this.optionsToDisplay.push(obj);
            this._options.push(obj);
        });
        console.log('this._options ',this._options);
    }
    
    openOptionsMenu(){
        this.isComboExpanded = true;
        this.cbComputedClass = cbClass+isMenuOpen;
    }
    closeOptionsMenu(){
        this.isComboExpanded = false;
        this.cbComputedClass = cbClass;        
    }
    handleSearch(event) {
        const searchKey = event.target.value;
        this.noResultsFound = false;
        if(searchKey){          
            this.optionsToDisplay = this._options.filter(obj => obj.value.toLowerCase().includes(searchKey.toLowerCase()));
            if(this.optionsToDisplay.length === 0) this.noResultsFound = true;
            this.openOptionsMenu();
        }else{
            this.closeOptionsMenu();
            this.optionsToDisplay = this._options;
        }        
    }

    handleSelection(event) {
        if(event !== undefined){
            console.log('handleSelection : ',event.target.id.split('-')[0]);
            let index = event.target.id.split('-')[0];
            this.selOptionsMap.set(''+index, this._options[index]);
            this.selectedOptions = Array.from(this.selOptionsMap.values());
            if(!this.hideButtonIcon){
                this.showSelectedOptions = true;
            }
            this.closeOptionsMenu();
            if(this.selectedOptions.length > 0)
                this.dispatchEvent(new CustomEvent('optionchange', {detail: this.selectedOptions}));
        }else{
            console.log('Inside auto selected');
            this.selectedElementIds.forEach((opt) => {
            
                let obj = {...opt};
                let index = obj.index;
                this.selOptionsMap.set(''+index, this._options[index]);
                this.selectedOptions = Array.from(this.selOptionsMap.values());
                if(!this.hideButtonIcon){
                    this.showSelectedOptions = true;
                }
                this.closeOptionsMenu();
                if(this.selectedOptions.length > 0)
                    this.dispatchEvent(new CustomEvent('optionchange', {detail: this.selectedOptions}));
            });
            
        }

    }

    removeSelectedOption(event) {
        console.log('removeSelectedOption :',event);
        let index;
        if(event !== undefined){
            index = event.target.name;
            this.selOptionsMap.delete(''+index);
            this.selectedOptions = Array.from(this.selOptionsMap.values());
            if(this.selectedOptions.length === 0) this.showSelectedOptions = false;
            this.dispatchEvent(new CustomEvent('optionchange', {detail: this.selectedOptions}));
        }else{
            index = this.removeElementId.index;
            this.selOptionsMap.delete(''+index);
            this.selectedOptions = Array.from(this.selOptionsMap.values());
            if(this.selectedOptions.length === 0) this.showSelectedOptions = false;
            this.dispatchEvent(new CustomEvent('optionchange', {detail: this.selectedOptions}));
        }
        
        
    }

    @api //Method can be called from parent component
    clear(){
        this.selectedOptions = [];
        this.selOptionsMap = new Map();
        this.showSelectedOptions = false;
    }
}