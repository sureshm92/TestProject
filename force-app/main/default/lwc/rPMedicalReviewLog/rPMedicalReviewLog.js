import { LightningElement,track, api } from 'lwc';

export default class RPMedicalReviewLog extends LightningElement {
    @track peId;
    @api result = false;
    @api gizmoData = null; @api gizmosrc='';
    connectedCallback() {
        this._listenForMessage   = this.listenForMessage.bind(this);
        window.addEventListener("message", this._listenForMessage);
    }
    disconnectedCallback() {
        window.removeEventListener('message', this._listenForMessage);
      }

    listenForMessage(message){
        console.log('eventhandled-->'+JSON.stringify(message.data)); 
       if(message.data.messageType === 'SurveyGizmoResult'){
            if (message.data.pdfContent) {
                this.gizmoData = message.data.pdfContent;
            }
            if(message.data.success){
                this.result = true;
            }else{this.result = false;}
            console.log('Result---------->'+this.result);
            console.log('Result---------->'+this.gizmoData);
            const mrrResult = new CustomEvent('medicalreviewresult',{
                detail:{
                    result : this.result,
                    gizmoData : this.gizmoData
                }
            });
            this.dispatchEvent(mrrResult);
       }else{
           console.log('Error'); 
       }
    }
    
}