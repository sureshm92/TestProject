import { LightningElement, api } from 'lwc';
import getPPResources from '@salesforce/apex/ResourceRemote.getPPResources';
import { NavigationMixin } from 'lightning/navigation';

export default class PpSuggestedArticles extends NavigationMixin(LightningElement) {
    resourcesData =[];
    showData = false;
    firstrender=true;
    @api resid;
    showRight=false;
    state;
    resTypeMap = new Map();
    renderedCallback() {
        
        //  this.resourcesData.push(JSON.parse('{"isFavorite":false,"isVoted":false,"resource":{"Id":"a1H6s000000eUQvEAM","Title__c":"Lorem Ipsum is simply dummy text of the printing and typesetting industry","Description__c":"Time Magazine quotes IQVIA data to warn of severe flu season","Image__c":"https://media.healthday.com/Images/spanishtvthumbs/Spanish_Breast_MRI_060519.jpg","Multimedia__c":"https://media.healthday.com/Images/spanishtvthumbs/Spanish_Breast_MRI_060519.jpg","Body__c":"Body Test","CreatedDate":"2023-01-05T07:25:07.000Z","RecordTypeId":"0126s000000dOi2AAE","Content_Class__c":"Study-Specific","Content_Type__c":"Multimedia","X3rd_Party_Source__c":"IQVIA","Version_Date__c":"2023-02-10","RecordType":{"DeveloperName":"Multimedia","Id":"0126s000000dOi2AAE"}},"translations":[],"isMultimedia":true}'));
        //  this.resourcesData.push(JSON.parse('{"isFavorite":false,"isVoted":false,"resource":{"Id":"a1H6s000000eUQvEAM","Title__c":"Multimedia Multimedia Multimedia Multimedia Multimedia ","Description__c":"Time Magazine quotes IQVIA data to warn of severe flu season","Image__c":"https://media.healthday.com/Images/icimages/alzheimer9182.jpg","Multimedia__c":"https://media.healthday.com/Images/spanishtvthumbs/Spanish_Breast_MRI_060519.jpg","Body__c":"Body Test","CreatedDate":"2023-01-05T07:25:07.000Z","RecordTypeId":"0126s000000dOi2AAE","Content_Class__c":"Study-Specific","Content_Type__c":"Multimedia","X3rd_Party_Source__c":"IQVIA","Version_Date__c":"2023-02-10","RecordType":{"DeveloperName":"Multimedia","Id":"0126s000000dOi2AAE"}},"translations":[],"isMultimedia":true}'));
        // this.showData = true; 
        this.initializeData();
        if(this.template.querySelector(".topdiv")){
            console.log(1);
            this.template.querySelector(".topdiv").addEventListener('scroll', () => this.checkChevrons());
            var contents = this.template.querySelector(".topdiv");
            var divWidth = contents.offsetWidth;
            var scrollwidth =contents.scrollWidth;
            if(divWidth!=scrollwidth){
                this.showRight=true;         
            }
        }
    }    
    initializeData() {
        if (communityService.isInitialized() && this.firstrender) {            
            this.firstrender = false;
            var pData = communityService.getParticipantData();
            this.state = communityService.getCurrentCommunityMode().participantState;
            let data = JSON.stringify(pData);
            getPPResources({ participantData: data })
                .then((result) => {
                    for(var i = 0; i< result.wrappers.length; i++){
                        if(this.resid != result.wrappers[i].resource.Id){
                            this.resourcesData.push(result.wrappers[i]);
                            this.resTypeMap.set(result.wrappers[i].resource.Id,result.wrappers[i].resource.Content_Type__c);
                        }
                    }        
                    if(this.resourcesData.length>0)          
                        this.showData = true;                     
                })
                .catch((error) => {
                    if (this.spinner) {
                        this.spinner.hide();
                    }
                    this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                });
        }
    }
    goLeft(){
        if(this.showRight){
            var contents = this.template.querySelector(".topdiv");
            contents.scrollLeft -= 250;
            if(contents.scrollLeft<=250){
                this.template.querySelector(".chevronL").className="chevronL disableCursor";            
            }        
            this.template.querySelector(".chevronR").className = "chevronR";
        }
    }
    goRight(){
        if(this.showRight){
            var contents = this.template.querySelector(".topdiv");
            contents.scrollLeft += 250;
            this.template.querySelector(".chevronL").className = "chevronL";

            var newScrollLeft=contents.scrollLeft;
            var divWidth = contents.offsetWidth;
            var scrollwidth =contents.scrollWidth;
            if(scrollwidth - divWidth - newScrollLeft < 250){
                this.template.querySelector(".chevronR").className="chevronR disableCursor";   
            }
        }
    }    
    checkChevrons(){
        console.log('OUTPUT : ','move');
        clearTimeout(this.timeoutId);
        this.timeoutId = setTimeout(this.doValidateChevron.bind(this), 750);
    }
    doValidateChevron(){
        var contents = this.template.querySelector(".topdiv");
        var newScrollLeft=contents.scrollLeft;
        var divWidth = contents.offsetWidth;
        var scrollwidth =contents.scrollWidth;
        if(scrollwidth - divWidth - newScrollLeft <1){
            this.template.querySelector(".chevronR").className="chevronR disableCursor";   
        }
        else{
            this.template.querySelector(".chevronR").className="chevronR";   
        }
        if(contents.scrollLeft==0){
            this.template.querySelector(".chevronL").className="chevronL disableCursor";            
        }   
        else{
            this.template.querySelector(".chevronL").className="chevronL";   
        }
            
    }
    navigateToRes(event){
        let detailLink =
            window.location.origin +
            '/pp/s/resource-detail' +
            '?resourceid=' +
            event.currentTarget.dataset.id +
            '&resourcetype=' +
            this.resTypeMap.get(event.currentTarget.dataset.id) +
            '&state=' +
            this.state;
console.log('OUTPUT : ',detailLink);
        const config = {
            type: 'standard__webPage',

            attributes: {
                url: detailLink
            }
        };
try{
        this[NavigationMixin.GenerateUrl](config).then((url) => {
            window.open(url, '_self');
        });
    
}
catch(error){
    console.log(error);
}
}
}