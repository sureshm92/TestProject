import { LightningElement,api } from 'lwc';
import stopSharing from '@salesforce/apex/ReferHealthcareProviderRemote.stopSharing';
import inviteHP from '@salesforce/apex/ReferHealthcareProviderRemote.inviteHP';
import HealthCare_Providers_Last_Name from '@salesforce/label/c.HealthCare_Providers_Last_Name';
import HealthCare_Providers_Email from '@salesforce/label/c.HealthCare_Providers_Email';
import HealthCare_Providers_First_Name from '@salesforce/label/c.HealthCare_Providers_First_Name';
import HealthCare_Provider_Connect from '@salesforce/label/c.HealthCare_Provider_Connect';
import HealthCare_Provider_Stop_Sharing from '@salesforce/label/c.HealthCare_Provider_Stop_Sharing';
export default class Pir_participantEmancipatedHCPList extends LightningElement {
    @api email='';
    @api firstName='';
    @api lastName='';
    @api status='';
    @api hpId='';
    @api sharingObject = {};
    @api duplicateDelegateInfo;
    @api perid = '';
    @api hcpeId='';
    @api loading = false;
    label = {
        HealthCare_Providers_Last_Name,
        HealthCare_Providers_Email,
        HealthCare_Providers_First_Name,
        HealthCare_Provider_Connect,
        HealthCare_Provider_Stop_Sharing
    }
    get isInvited(){
        if(this.status == 'Invited' || this.status == 'Active'){
            return true;
        }else{
            return false;
        }
    }
    doConnect(){
        this.loading = true;
        this.sharingObject = {
            Id:this.hpId,
            sObjectType:"Healthcare_Provider__c",
            Email__c:this.email,
            First_Name__c:this.firstName,
            Last_Name__c:this.lastName,
            Status__c:this.status,
            Participant_Enrollment__c:this.perid,
            HCP_Enrollment__c:this.hcpeId
        }
        this.duplicateDelegateInfo = null;
        inviteHP({ peId: this.perid,
                   hp: JSON.stringify(this.sharingObject),
                   ddInfo:  JSON.stringify(this.duplicateDelegateInfo)
        })
        .then((result) => {
            let hcpstatus = result.filter(res => res.Id == this.hpId);
            this.status = hcpstatus[0].Status__c;
            this.loading = false;
        }).catch((error) => {
            console.log(error);
            this.loading = false;
        });
    }
    doDisconnect(){
        this.loading = true;
        stopSharing({ hpId: this.hpId,
                      delegateId: null
        }).then(() => {
            this.status = 'No Sharing';
            this.loading=false;
        })
        .catch((error) => {
            console.log(error);
            this.loading=false;
        });
    }
}