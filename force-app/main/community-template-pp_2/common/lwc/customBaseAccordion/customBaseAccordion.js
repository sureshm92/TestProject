import { LightningElement, track, api} from 'lwc';

export default class CustomBaseAccordion extends LightningElement {
    @api clinicaltrailrecrd;
    @api allowAllSectionDefaultOpen;
    @api allowOnlyOneSectionAtTime;
    @api clinicaltrailAccordionData;
    @track ctpAccordionData;
    allowAllSectionDefaultToOpen;
    allowOnlyOneSectionAtATime;

    isRTL = false;

    get arrowCss(){
        return this.isRTL ? 'plusminusRTL' : 'plusminus';
    }

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }

    connectedCallback(){
       this.allowAllSectionDefaultToOpen = this.allowAllSectionDefaultOpen;
       this.allowOnlyOneSectionAtATime = this.allowOnlyOneSectionAtTime;
       this.ctpAccordionData = JSON.parse(JSON.stringify(this.clinicaltrailAccordionData));
      if(this.allowAllSectionDefaultToOpen == true){
            this.ctpAccordionData.forEach(function (acList) {
                acList.bodyClass= "accordion_body"; 
                acList.iconName = 'utility:chevrondown';       
        });
      }     
      else {
        if(this.ctpAccordionData){
            this.ctpAccordionData.forEach(function (acList) {
                if(acList.allowDefaultSection){
                    acList.bodyClass= "accordion_body";  
                    acList.iconName = 'utility:chevrondown';      
                }
                else{
                    acList.bodyClass= "accordion_body hide"; 
                    acList.iconName = 'utility:chevronright'; 
                }
           }); 
        }
      } 
    }

    openAccordionBody(event){
        let id = event.target.getAttribute("data-id");        
        var allowOnlyOneSectionAtaTime = this.allowOnlyOneSectionAtATime;
        this.ctpAccordionData.forEach(function (acList) {
            if(allowOnlyOneSectionAtaTime == true){
                this.ctpAccordionData.forEach(function (acList) {
                    if(acList.id == id){
                        acList.bodyClass= "accordion_body"; 
                        acList.iconName = 'utility:chevrondown'; 
                    }
                    else{
                        acList.bodyClass= "accordion_body hide";
                        acList.iconName = 'utility:chevronright'; 
                    }                   
              });
            }
        else{
            if(acList.id == id){
                if(acList.bodyClass == 'accordion_body'){
                    acList.bodyClass= "accordion_body hide"; 
                    acList.iconName = 'utility:chevronright'; 
                }
                else if(acList.bodyClass= "accordion_body hide"){
                    acList.bodyClass= "accordion_body";
                    acList.iconName = 'utility:chevrondown'; 
                }
            }  
         }    
      });
    }
}