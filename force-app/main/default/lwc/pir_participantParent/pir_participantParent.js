import { LightningElement, api } from 'lwc';
export default class Pir_participantParent extends LightningElement {
    @api peId;
    @api firstName;
    @api phoneNumber;
    @api studyName;
    @api referredBy;
    @api selectedPE;
    @api isLoaded = false;

    selectedPI(event){
        this.selectedPE = event.detail;
        console.log('pe-parent'+JSON.stringify(this.selectedPE));
        this.template.querySelector("c-pir_participant-header").selectedPE = this.selectedPE;
        this.template.querySelector("c-pir_participant-header").doSelectedPI();
    }
    curentMobileView = "list";
    mobileViewToggle(){
        if(this.curentMobileView=="list"){
            this.curentMobileView="detail";
            this.template.querySelectorAll(".D").forEach(function (D) {
                D.classList.remove("hideMobile");
            });
            this.template.querySelectorAll(".L").forEach(function (L) {
                L.classList.add("hideMobile");
            });
        }
        else{
            this.curentMobileView="list";
            this.template.querySelectorAll(".L").forEach(function (L) {
                L.classList.remove("hideMobile");
            });            
            this.template.querySelectorAll(".D").forEach(function (D) {
                D.classList.add("hideMobile");
            });
        }
        
    }
    //pagination
    totalRecord;
    pageChanged(event){
        this.page = event.detail.page;
        this.template.querySelector("c-pir_participant-list").pageNumber = this.page;
        this.template.querySelector("c-pir_participant-list").fetchList();
    }
    recCountUpdate(event){
        this.totalRecord = event.detail;
    }
    handleSpinner(event){
        this.isLoaded = event.detail;
    }
    changePage(event){
        let dir = event.detail;
        if(dir == 'next'){
            this.template.querySelector("c-pir_participant-pagination").nextPage();
        }
        if(dir == 'prev'){
            this.template.querySelector("c-pir_participant-pagination").previousPage();
        }
    }
    //
}