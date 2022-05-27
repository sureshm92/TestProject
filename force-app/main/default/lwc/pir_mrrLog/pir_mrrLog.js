import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import setMRRStatus from '@salesforce/apex/PIR_HomepageController.setMRRStatus';
import setPreScreenerStatus from '@salesforce/apex/PIR_HomepageController.setPreScreenerStatus';

export default class Pir_mrrLog extends LightningElement {
    @api peid;
    @api result = false;
    @api gizmoData = null; 
    @api gizmosrc='';
    @api mrrorprescreener;
    connectedCallback() {
        this._listenForMessage   = this.listenForMessage.bind(this);
        window.addEventListener("message", this._listenForMessage);
    }
    disconnectedCallback() {
        window.removeEventListener('message', this._listenForMessage);
      }

    listenForMessage(message){
       if(message.data.messageType === 'SurveyGizmoResult'){
            if (message.data.pdfContent) {
                this.gizmoData = message.data.pdfContent;
            }
            var status ='';
            if(message.data.success){
                this.result = true;
                status ='Pass';
            }else{this.result = false;
                  status ='Fail';
            }
            if(this.mrrorprescreener === 'prescreener'){
                setPreScreenerStatus({ peId: this.peid, status: status, surveyGizmoData: this.gizmoData })
                .then((result) => {
                    const preScreenerResult = new CustomEvent('prescreenerresult',{
                        detail:{
                            result : status
                        }
                    });
                    this.dispatchEvent(preScreenerResult);
                })
                .catch((error) => {
                    console.log(error);
                    this.showErrorToast(JSON.stringify(error.body.message));
                });
            }else{
            setMRRStatus({ peId: this.peid, status: status, surveyGizmoData: this.gizmoData })
            .then((result) => {
                const mrrResult = new CustomEvent('medicalreviewresult',{
                    detail:{
                        result : status
                    }
                });
                this.dispatchEvent(mrrResult);
            })
            .catch((error) => {
                console.log(error);
                this.showErrorToast(JSON.stringify(error.body.message));
            });
        }
       }else{
           console.log('Error'); 
       }
    }

    showErrorToast(msg) {
        const evt = new ShowToastEvent({
            title: msg,
            message: msg,
            variant: 'error',
            mode: 'dismissible'
        });
        this.dispatchEvent(evt);
    }
    
}