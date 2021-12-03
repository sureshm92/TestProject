import { LightningElement, api, wire } from 'lwc';
import getListViewData from '@salesforce/apex/PIR_HomepageController.getListViewData';
import pirResources from '@salesforce/resourceUrl/pirResources';
import { CurrentPageReference } from 'lightning/navigation';

export default class Pir_participantList extends LightningElement {    
    currentPageReference = null; 
    urlStateParameters = null;
    
    /* Params from Url */
    urlStudyId = null;
    urlSiteId = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }
 
    setParametersBasedOnUrl() {
       this.urlStudyId = this.urlStateParameters.id || null;
       this.urlSiteId = this.urlStateParameters.siteId || null;
    }
    totalRecordCount = -1;
    @api pageNumber = 1;
    participantList;
    studyIdlist=null;
    siteIdlist=null;
    iconHighRisk =pirResources+'/pirResources/icons/status-alert.svg';
    iconHighPriority = pirResources+'/pirResources/icons/arrow-up.svg';
    iconActionReq = pirResources+'/pirResources/icons/bell.svg';    
    err='';
    peMap = new Map();
    peCurrentIndexMap = new Map();
    selectedIndex = -1 ;
    @api selectedPE;
    keyCount = 0;

    connectedCallback(){        
       console.log(this.urlStudyId+'>>'+this.urlSiteId);
       this.fetchList(); 
    }   
    rendered=false;
    renderedCallback(){
        console.log("renderedCallbackinit");
        if(!this.rendered){
            this.rendered=true;
            console.log("renderedCallback");
            this.setKeyAction();            
        }
        this.changeSelected();
    }

    @api fetchList(){
        this.participantList=null;
        getListViewData({pageNumber : this.pageNumber, totalCount : this.totalRecordCount, studyIdlist : this.studyIdlist, siteIdlist : this.siteIdlist })
        .then(result => {
            this.participantList = result.listViewWrapper;
            if(result.listViewWrapper.length>0){
                this.selectedIndex = 0;
                this.selectedPE=result.listViewWrapper[0];                
            }
            for(var i=0 ; i<result.listViewWrapper.length;i++){
                this.peMap.set(result.listViewWrapper[i].id,result.listViewWrapper[i]);
                this.peCurrentIndexMap.set(i,result.listViewWrapper[i].id);
            }
            if(this.totalRecordCount !=  result.totalRecordCount){
                this.totalRecordCount =  result.totalRecordCount;
                const updateCount = new CustomEvent("reccountupdate", {
                    detail: this.totalRecordCount
                });
                this.dispatchEvent(updateCount);  
            }
            if(!this.siteIdlist){
                this.siteIdlist = result.siteIdlist;
            }
            if(!this.studyIdlist){
                this.studyIdlist = result.studyIdlist;
            }
            //this.setKeyAction();
        })
        .catch(error => {
            this.err = error;
            console.log('Error : '+this.err);
            this.participantList = undefined;
        });
    }
    setKeyAction(){
        this.template.querySelector('.keyup').addEventListener('keyup', (event) => {
            console.log(1123465);
            var name = event.key;
            var code = event.code;
            this.keyCount++;        
            if((name=='ArrowDown' || name=='ArrowUp')){
                var updateSelected=false;
                if(name=='ArrowDown' && this.selectedIndex<9){
                    this.selectedIndex++;
                    updateSelected=true;
                }
                if(name=='ArrowUp' && this.selectedIndex>0){
                    this.selectedIndex--;
                    updateSelected=true;
                } 
                if(updateSelected){
                    this.changeSelected();
                }
            }
        }, false);
    }
    handleMouseSelect(event){
        const mToggle = new CustomEvent("mtoggle", {
            detail: ""
        });
        this.dispatchEvent(mToggle); 
        if(this.selectedIndex != event.currentTarget.dataset.id){
            this.selectedIndex = event.currentTarget.dataset.id;
            this.changeSelected();
        }
    }
    changeSelected(){
        if(this.selectedIndex != -1){
            var cards = this.template.querySelectorAll('.list-card');
            for(var j = 0; j < cards.length; j++){
                if(j==this.selectedIndex){
                    cards[j].classList.add("selected");
                    this.selectedPE= this.peMap.get(this.peCurrentIndexMap.get(j)); 
                    const selectedEvent = new CustomEvent("selectedpevaluechange", {
                        detail: this.selectedPE
                    });
                    this.dispatchEvent(selectedEvent);   
                }
                else{
                    cards[j].classList.remove("selected");
                }
            }
        }
    }
}