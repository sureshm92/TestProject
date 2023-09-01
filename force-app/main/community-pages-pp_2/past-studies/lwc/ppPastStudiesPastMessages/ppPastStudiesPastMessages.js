import { LightningElement,api,track } from 'lwc';
import getrecentlycommunicatedmembers from '@salesforce/apex/ppPastStudiesTabUtility.getrecentlycommunicatedmembers';
import { NavigationMixin } from 'lightning/navigation';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import PP_View_Messages from '@salesforce/label/c.PP_View_Messages';
import PP_No_messages_available from '@salesforce/label/c.PP_No_messages_available';
export default class PpPastStudiesPastMessages extends NavigationMixin(LightningElement) {
    @api per;
    @api contactid;
    @api noMessagesIcon;
    hasmembers;
    messagesIcon = pp_icons + '/' + 'messageIcon.svg';;
    @track userrdetails;
    label = {
        PP_View_Messages,
        PP_No_messages_available
    }
    connectedCallback() {
        console.log('++++++++++++++per'+JSON.stringify(this.per) + 'ppp'+this.contactid);
        getrecentlycommunicatedmembers({
            contID: this.contactid,
            per: this.per
        }).then((result) => {
            console.log(JSON.stringify(result));
            if(result.length > 0){
                this.hasmembers = true;
                this.userrdetails = result;
            }else{
                this.hasmembers = false;
            }

        })
        .catch((error) => {
            console.error('Error:', error);
            this.hasmembers = false;
        });
    }
    navigatetomessagepage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'messages'
            },
            state: {
                c__study : this.per.Clinical_Trial_Profile__c
            }
            
        });
    }
}