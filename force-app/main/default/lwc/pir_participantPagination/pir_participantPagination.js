import { LightningElement , api } from 'lwc';
import community_icon from '@salesforce/resourceUrl/rr_community_icons';
import RH_RP_Items from '@salesforce/label/c.RH_RP_Items';
import RH_RP_of from '@salesforce/label/c.RH_RP_of';
import RH_RP_Page from '@salesforce/label/c.RH_RP_Page';
import Page from '@salesforce/label/c.Page';
import of from '@salesforce/label/c.of';

export default class Pir_participantPagination extends LightningElement {
    label = {
        RH_RP_Items,
        RH_RP_of,
        RH_RP_Page,
        Page,
        of
    };
    startRecord = 0;
    endRecord = 0;
    totalPages= 0; 
    pageNumber = 0;
    @api isTable;
    @api totalRecords = 0;//push from parent
    first_page_arrow = community_icon + '/left-arrow.svg';
    right_arrow = community_icon + '/first-page-arrow.svg';
    isRendered = false;
    @api isRTLPg;
    @api maindivcls;
    connectedCallback(){
        if(this.isTable==true){
            this.calculate();
        }
    }
    
    renderedCallback(){
        if(!this.isRendered){            
            this.isRendered = true;
            if(this.totalRecords > 0){
                this.pageNumber = 1;
                this.calculate();
            }            
        }
        if(this.isTable==true){
            this.template.querySelectorAll(".page").forEach(function (L) {
                L.classList.add("pg-bulkimport");
            });
          
            
        }
        
        
    }

    @api updateInprogress(){
        this.calculate();    
        }
    
    calculate(){
        if(this.totalRecords>45000){  // limit the pagination to 4500 page or 45000 records as same limit is set in the PIR_HomepageController
            this.totalRecords = 45000;
        }
        if(this.pageNumber>0){
            this.startRecord = 1 + ((this.pageNumber-1)*10);        
            this.totalPages =  Math.ceil(this.totalRecords / 10);
            if(this.pageNumber == this.totalPages && this.totalRecords%10 != 0){
                this.endRecord = this.startRecord + this.totalRecords%10 -1 ;
            }
            else{
                this.endRecord = this.startRecord + 9;
            }
            if(this.pageNumber == 1){
                this.template.querySelector('.pre').classList.add("disabled");
            }
            else{            
                this.template.querySelector('.pre').classList.remove("disabled");
            }
            if(this.pageNumber == this.totalPages){
                this.template.querySelector('.nxt').classList.add("disabled");
            }
            else{            
                this.template.querySelector('.nxt').classList.remove("disabled");
            }
            const pagechange = new CustomEvent("pagechange", {
                detail: {
                    page: this.pageNumber
                }
            });
            this.dispatchEvent(pagechange);
        }
    }

    handlePageNumberChange(event) {
        this.pageNumber = event.target.value;
        if(this.pageNumber > this.totalPages ){
            this.pageNumber =this.totalPages;
            event.target.value = this.totalPages;
        }
        if(this.pageNumber<1){
            if(this.totalRecords>0){
                this.pageNumber =1;
            }
            else{
                this.pageNumber =0;
            }
            event.target.value = this.pageNumber;
        }
        this.calculate();
    }
    @api nextPage() {
        if(this.pageNumber < this.totalPages){
            this.pageNumber++;
            this.calculate();
        }
    }
    @api previousPage() {
        if(this.pageNumber > 1){
            this.pageNumber--;
            this.calculate();
        }
    }
    goToLast(){
        if( this.pageNumber!=this.totalPages){
            this.pageNumber= this.totalPages;        
            this.calculate();
        }
    }
    @api goToStart(){
        this.pageNumber= 1;        
        this.calculate();        
    }
}