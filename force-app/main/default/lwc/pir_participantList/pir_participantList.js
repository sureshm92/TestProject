import { LightningElement, api, wire } from 'lwc';
import getListViewData from '@salesforce/apex/PIR_HomepageController.getListViewData';
import pirResources from '@salesforce/resourceUrl/pirResources';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';
import RH_RP_No_Item_To_Display from '@salesforce/label/c.RH_RP_No_Item_To_Display';

export default class Pir_participantList extends LightningElement {    
    currentPageReference = null; 
    urlStateParameters = null;
    @api noRecords = false;
    
    /* Params from Url */
    urlStudyId = null;
    urlSiteId = null;

    label = {
        RH_RP_No_Item_To_Display
    };

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
    @api communityTemplate ='';
    backSwap = false;
    keypress = false;
    keyScope = '';

    connectedCallback(){        
       if(this.urlStudyId !== null && this.urlSiteId !== null){
        this.studyIdlist = [];
        this.studyIdlist.push(this.urlStudyId);
        this.siteIdlist = [];
        this.siteIdlist.push(this.urlSiteId);        
       }
        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            this.communityTemplate = communityService.getCurrentCommunityTemplateName();
        }).then(() => {
            this.fetchList(); 
        }).catch((error) => {
             console.log('Error: ' + error);
        });
     
    }   
    rendered=false;
    renderedCallback(){
        if(!this.rendered){
            this.rendered=true;
            this.setKeyAction();  
        }        
        this.keyScope += 'ren';  
        this.changeSelected();        
    }

    @api fetchList(){
        this.participantList=null;
        getListViewData({pageNumber : this.pageNumber, totalCount : this.totalRecordCount, studyIdlist : this.studyIdlist, siteIdlist : this.siteIdlist, sponsorName  : this.communityTemplate })
        .then(result => {
            this.participantList = result.listViewWrapper;
            if(result.listViewWrapper.length>0){
                this.noRecords = false;
                if(!this.backSwap){
                    this.selectedIndex = 0;
                    this.selectedPE=result.listViewWrapper[0];   
                }else{
                    this.backSwap = false;
                    this.selectedIndex = result.listViewWrapper.length -1;
                    this.selectedPE=result.listViewWrapper[result.listViewWrapper.length -1];   
                }

            }else{
                this.noRecords = true;
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
        })
        .catch(error => {
            this.err = error;
            console.log('Error : '+this.err);
            this.participantList = undefined;
        });
    }
    setKeyAction(){
        this.template.querySelector('.keyup').addEventListener('keydown', (event) => {     
            var name = event.key;    
            if((name=='ArrowDown' || name=='ArrowUp')){
                this.keypress = true;                 
                this.keyScope = 'down';  
                event.preventDefault();
                event.stopPropagation();
                var updateSelected=false;
                if(name=='ArrowDown' ) {
                    if( this.selectedIndex < (this.participantList.length - 1)){
                        this.selectedIndex++;
                        updateSelected=true;
                    }else if(this.selectedIndex == (this.participantList.length - 1)){
                        //goto to next page
                        const pageswap = new CustomEvent("pageswap", {
                            detail: "next"
                        });
                        this.dispatchEvent(pageswap); 
                    }
                }
                if(name=='ArrowUp') {
                    if( this.selectedIndex>0){
                        this.selectedIndex--;
                        updateSelected=true;
                    }else if(this.selectedIndex == 0){
                        //goto to previous page
                        if(this.pageNumber != 1){
                            this.backSwap = true;
                        }
                        const pageswap = new CustomEvent("pageswap", {
                            detail: "prev"
                        });
                        this.dispatchEvent(pageswap); 
                    }
                }
                if(updateSelected){
                    this.changeSelected();
                }
            }
        }, false);
    
        this.template.querySelector('.keyup').addEventListener('keyup', (event) => {
            var name = event.key;
            if((name=='ArrowDown' || name=='ArrowUp')){
                const selectedEvent = new CustomEvent("selectedpevaluechange", {
                    detail: this.selectedPE
                });
                this.dispatchEvent(selectedEvent);              
                this.keypress = false;
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
        this.keyScope += 'chsec';
        if(this.selectedIndex != -1){
            var cards = this.template.querySelectorAll('.list-card');
            for(var j = 0; j < cards.length; j++){
                if(j==this.selectedIndex){
                    cards[j].classList.add("selected");
                    cards[j].focus();
                    this.selectedPE= this.peMap.get(this.peCurrentIndexMap.get(j)); 
                    if((!this.keypress) || this.keyScope == 'downrenchsecrenchsec'){
                        const selectedEvent = new CustomEvent("selectedpevaluechange", {
                         detail: this.selectedPE
                        });
                        this.dispatchEvent(selectedEvent); 
                    }
                }
                else{
                    cards[j].classList.remove("selected");
                }
            }
        }
    }
    get pageLimit(){
        return this.pageNumber>200;
    }
}