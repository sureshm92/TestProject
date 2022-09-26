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
    _options = [];
    selOptionsMap = new Map();

    @api
    get options(){
        return this._options;
    }
    set options(value){
        this._options = [];
        this.optionsToDisplay = [];
        let i=0;
        value.forEach((opt) => {
            let obj = {...opt};
            obj.index = i++;
            obj.hasIcon = obj.icon ? true : false;
            this.optionsToDisplay.push(obj);
            this._options.push(obj);
        });
        let selectors = this.template.querySelector('[data-id="optionslist"]');
        if(selectors != null){
            this.template.querySelector('[data-id="selectedOptionsListId"]').style = 'min-height: '+selectors.clientHeight+'px';
        }  
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
        let index = event.target.id.split('-')[0];
        let indexvalue = this._options[index];
        this.selOptionsMap.set(''+indexvalue.id, this._options[index]);
        this.selectedOptions = Array.from(this.selOptionsMap.values());
        this.showSelectedOptions = true;
        this.closeOptionsMenu();
        if(this.selectedOptions.length > 0)
            this.dispatchEvent(new CustomEvent('optionchange', {detail: this.selectedOptions}));
    }

    removeSelectedOption(event) {
        let index = event.target.name;
        this.selOptionsMap.delete(''+index);
        this.selectedOptions = Array.from(this.selOptionsMap.values());
        if(this.selectedOptions.length === 0) this.showSelectedOptions = false;
        this.dispatchEvent(new CustomEvent('optionchange', {detail: this.selectedOptions}));
    }

    @api //Method can be called from parent component
    clear(){
        this.selectedOptions = [];
        this.selOptionsMap = new Map();
        this.showSelectedOptions = false;
    }
}