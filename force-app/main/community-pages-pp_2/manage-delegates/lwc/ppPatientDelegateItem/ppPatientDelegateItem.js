import { LightningElement, track, api } from 'lwc';
import changeDelegateStatus from '@salesforce/apex/PatientDelegateRemote.changeDelegateStatus';
import btnMainActivate from '@salesforce/label/c.BTN_Main_Activate';
import btnDectivate from '@salesforce/label/c.BTN_Deactivate';
import PP_Patient_Delegate_Deactivate_Mess from '@salesforce/label/c.PP_Patient_Delegate_Deactivate_Mess';
import pgPstLDelegatesRemoveDelegate from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Delegate';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
export default class PpPatientDelegateItem extends LightningElement {
    showpopup = false;
    @api contact;
    @api isActive;
    clickedButtonLabel;
    callback = {};
    messText = '';
    titText = '';
    @api selectedparent;
    @api usermode;
    isLoading = false;
    icon_url = pp_icons + '/user_delegate_avatar.svg';
    label = {
        btnMainActivate,
        btnDectivate,
        PP_Patient_Delegate_Deactivate_Mess,
        pgPstLDelegatesRemoveDelegate
    };
    handleClick(event) {
        let isActive = !this.isActive;
        if (!isActive) {
            let contact = this.contact;
            this.messText = this.label.PP_Patient_Delegate_Deactivate_Mess.replace(
                '##Name',
                contact.FirstName + ' ' + contact.LastName
            );
            this.titText = this.label.pgPstLDelegatesRemoveDelegate;
            this.showpopup = true;
        } else {
            this.isLoading = true;
            let contactId = this.contact.Id;
            changeDelegateStatus({
                contactId: contactId,
                isActive: isActive
            })
                .then((result) => {
                    this.isLoading = false;
                    const selectedEvent = new CustomEvent('rerenderteampage', {
                        detail: {
                            contact: contactId,
                            usermode: this.usermode,
                            selectedparent: this.selectedparent
                        }
                    });
                    this.dispatchEvent(selectedEvent);
                })
                .catch((error) => {
                    this.isLoading = false;
                });
        }
    }
    get btntitle() {
        if (this.isActive) {
            return btnDectivate;
        } else {
            return btnMainActivate;
        }
    }

    get delegateFullname() {
        if (this.contact != undefined && this.contact != null && this.contact != '') {
            if (
                this.contact.FirstName == null ||
                this.contact.FirstName == undefined ||
                this.contact.FirstName == ''
            ) {
                return this.contact.LastName;
            } else {
                return this.contact.FirstName + ' ' + this.contact.LastName;
            }
        }
    }

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
    handleConfirmdelete(event) {
        this.isLoading = true;
        let contactobj = event.detail.contact;
        changeDelegateStatus({
            contactId: contactobj.Id,
            isActive: false
        })
            .then((result) => {
                const selectedEvent = new CustomEvent('rerenderteampage', {
                    detail: {
                        contact: contactobj.Id,
                        usermode: event.detail.usermode,
                        selectedparent: event.detail.selectedparent
                    }
                });
                this.dispatchEvent(selectedEvent);
                this.showpopup = false;
                this.isLoading = false;
            })
            .catch((error) => {
                this.isLoading = false;
            });
    }
}
