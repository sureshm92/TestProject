import { LightningElement, track } from 'lwc';
import changeDelegateStatus from '@salesforce/apex/PatientDelegateRemote.changeDelegateStatus';
import btnMainActivate from '@salesforce/label/c.BTN_Main_Activate';
import btnDectivate from '@salesforce/label/c.BTN_Deactivate';
import patientDelegateDeactivateMess from '@salesforce/label/c.Patient_Delegate_Deactivate_Mess';
import pgPstLDelegatesRemoveDelegate from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Delegate';
export default class PpPatientDelegateItem extends LightningElement {
    showpopup = false;
    // contact;
    // isActive;
    // contactname;
    // title;
    // @track isRTL;
    // label = {
    //     btnMainActivate,
    //     btnDectivate,
    //     changeDelegateStatus,
    //     patientDelegateDeactivateMess,
    //     pgPstLDelegatesRemoveDelegate
    // };
    // mobile = !($Browser.formFactor != 'DESKTOP');
    // title = isActive ? label.BTN_Deactivate : label.BTN_Main_Activate;
    // contactname = (contact.FirstName == null ? '' : v.contact.FirstName) + ' ' + v.contact.LastName;
    // connectedcallback() {}
    // handleClick(event) {
    //     this.clickedButtonLabel = event.target.label;
    //     changeDelegateStatus({
    //         contactId: contact.id,
    //         isActive: isActive
    //     });
    //     if (this.isActive) {
    //         contact = contact;
    //         messText = label.Patient_Delegate_Deactivate_Mess.replace(
    //             '##Name',
    //             contact.FirstName + ' ' + contact.LastName
    //         );
    //         titText = label.PG_PST_L_Delegates_Remove_Delegate;
    //     } else {
    //         this.spinner = this.template.querySelector('c-web-spinner');
    //         callback();
    //     }
    // }
    get delegate() {
        return 'delegate';
    }
    get switcherDelegate() {
        return 'switcher_delegate';
    }
    handleRemoveDelegates() {
        this.showpopup = true;
    }
    handleModalClose(event) {
        const showHideModal = event.detail;
        this.showpopup = showHideModal;
    }
}
