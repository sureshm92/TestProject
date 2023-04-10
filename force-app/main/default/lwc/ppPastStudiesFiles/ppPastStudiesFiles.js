import { LightningElement, api} from 'lwc';
import getData from '@salesforce/apex/PpPastStudiesFilesController.getData';  
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import formFactor from '@salesforce/client/formFactor';




export default class PpPastStudiesFiles extends LightningElement {
    contID;
    isDelegate=false;
    isFile=true;
    studyList;
    studyListToShow=[];
    threedots_imgUrl = pp_icons + '/' + 'three_dots.png';
    communityTemplate;
    showDropdown=true;
    @api dropDownLabel;
    isMobile=false;
    isSaving  = false;
    totalSize;
    curentSize;
    connectedCallback(){
      if (formFactor === 'Small') {
          this.isMobile = true;
      } else {
        this.isMobile = false;
        
    }
    console.log('>>isMobile>>'+this.isMobile+'>>formfactor>>'+formFactor);
        if(communityService.getCurrentCommunityMode().currentDelegateId){ 
            this.isDelegate=true;
        }
         if (!communityService.isDummy()) {
          this.communityTemplate = communityService.getCurrentCommunityTemplateName();
            if(this.isDelegate){
                this.contID=communityService.getCurrentCommunityMode().currentDelegateId; //participant contact id
            }
            else{
                this.contID= communityService.getParticipantData().currentContactId; //part contact id
            }
        }
        this.isSaving=true;
               getData({ 
                    contID: this.contID,
                    isDelegate: this.isDelegate
                })
                .then(result => {
                    this.isSaving=false;
                    this.studyList=result.perList;
                    this.totalSize = result.perList.length;
                    this.curentSize = 0;
                    this.addMoreStudies();
                    this.dropDownLabel=result.perList[0].Clinical_Trial_Profile__r.Study_Code_Name__c;
                    if(result.perList.length>1){
                      this.showDropdown=true;
                    }
                    else{
                      this.showDropdown=false;
                    }

                })
                .catch(error => {
                  console.error('Error:', error);
              });
    }

    addMoreStudies(){
      console.log('OUTPUT : in addMoreAccounts');
      if(this.curentSize < this.totalSize){
          var tempAccRec = [];
         var tempSize = ((this.curentSize + 5) < this.totalSize ? (this.curentSize + 5) : this.totalSize);
         for(var i=0; i< tempSize; i++){
              tempAccRec.push(this.studyList[i]);
          }
          this.studyListToShow = tempAccRec;
          this.curentSize = this.studyListToShow.length;
      }
  }

  handleLazyLoading(event){
    var scrollTop = event.target.scrollTop;
    var offsetHeight = event.target.offsetHeight;
    var scrollHeight = event.target.scrollHeight;
    if (offsetHeight + scrollTop + 10 >= scrollHeight) {
        this.addMoreStudies();
    }
}

    renderedCallback(){

        if (this.isMobile) {
            this.template.querySelectorAll(".D").forEach(function (L) {
              L.classList.add("slds-size_12-of-12");
          });
          this.template.querySelectorAll(".D").forEach(function (L) {
            L.classList.remove("slds-size_4-of-12");
        });
        
        } else {
          console.log('deks');
          this.template.querySelectorAll(".D").forEach(function (L) {
            L.classList.remove("slds-size_12-of-12");
        });   
        this.template.querySelectorAll(".D").forEach(function (L) {
          L.classList.add("slds-size_4-of-12");
          
        });    
      
        }
    }
  
    showActionMenu(event){
        this.template.querySelectorAll(".D").forEach(function (L) {
          L.classList.toggle("slds-is-open");
      });
      this.addMoreAccounts();
     
    }
    callMethod(event){
        let index =  event.target.dataset.id;
        this.dropDownLabel= this.studyList[index].Clinical_Trial_Profile__r.Study_Code_Name__c;
    }
    closeMenu(){
        this.template.querySelectorAll(".D").forEach(function (L) {
            L.classList.remove("slds-is-open");
        });
            
    }


    //pagination
    totalRecord=10;
    noRecords=true;
    showZeroErr  = false;
    initialLoad = true;
    page;
    pageChanged(event) {
      console.log('>>page changed called>>>');
      this.page = event.detail.page;
      this.template.querySelector("c-ppview-files-page-new").pageNumber =this.page;
        if(!this.initialLoad){
          console.log('>>>fetch page called>>>');
          //this.template.querySelector("c-ppview-files-page-new").stopSpinner=false;
          //this.template.querySelector("c-ppview-files-page-new").updateInProgressOldData();
          //this.template.querySelector("c-ppview-files-page-new").fetchData();
        }
        this.initialLoad = false;
    }
    changePage(event) {
      let dir = event.detail;
      if (dir == "next") { 
        this.template.querySelector("c-pir_participant-pagination").nextPage();
      }
      if (dir == "prev") {
        this.template
          .querySelector("c-pir_participant-pagination")
          .previousPage();
      }
    }
    handleUpdate=false;
    handletotalrecord(event){
      this.totalRecord=event.detail;
      this.handleUpdate=true;
      this.handleresetpageonupdate();
      }
    isResetOnUpdate=false;
    isResetPagination=false;
    handleresetpageonupdate(){
      if( this.handleUpdate && !this.isResetPagination ){
        this.initialLoad=true;
        this.template.querySelector("c-pir_participant-pagination").totalRecords=this.totalRecord;
        //this.template.querySelector("c-pir_participant-pagination").updateInprogress();
        }
      this.handleUpdate=false;
      this.initialLoad=false; 

    }
    handleresetpagination(event){
      if(this.isResetPagination ){
        this.initialLoad = true;
        this.template.querySelector("c-pir_participant-pagination").totalRecords=this.totalRecord;
        this.template.querySelector("c-pir_participant-pagination").goToStart();
      }
      this.isResetPagination = false;  
    }

}