import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BTN_Add_New_Delegate from '@salesforce/label/c.Add_New_Delegate';
import PP_ManageDelegates from '@salesforce/label/c.PP_ManageDelegates';
import PP_Remove from '@salesforce/label/c.PP_Remove';
import PG_PST_L_Delegates_Remove_Mess_P1_New from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Mess_P1_New';
import PG_PST_L_Delegates_Remove_Mess_P3_New from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Mess_P3_New';
import PG_PST_L_Delegates_Remove_Himself_Header from '@salesforce/label/c.PG_PST_L_Delegates_Remove_Himself_Header';
import PP_Delegate_Updated from '@salesforce/label/c.PP_Delegate_Updated';
import PP_ActiveDelegates from '@salesforce/label/c.PP_ActiveDelegates';
import PP_FormerDelegates from '@salesforce/label/c.PP_FormerDelegates';
import PP_AddAssignment from '@salesforce/label/c.PP_AddAssignment';
import PP_DelegateWithdrawn from '@salesforce/label/c.PP_DelegateWithdrawn';
import PP_Delegate_Delegate_Warning from '@salesforce/label/c.PP_Delegate_Delegate_Warning';
import PP_Delegate_Delegate from '@salesforce/label/c.PP_Delegate_Delegate';
import BTN_Save from '@salesforce/label/c.BTN_Save';
import PP_Delegate_Email_Consent from '@salesforce/label/c.PP_Delegate_Email_Consent';
import PIR_Discard from '@salesforce/label/c.PIR_Discard';
import PP_NO_Active_Delegate from '@salesforce/label/c.PP_NO_Active_Delegate';
import Icon_Delete from '@salesforce/label/c.pir_Delete_Btn';
//import getisRTL from '@salesforce/apex/PreferenceManagementController.getIsRTL';
import { loadScript } from 'lightning/platformResourceLoader';
import rrCommunity from '@salesforce/resourceUrl/rr_community_js';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import pirResources from '@salesforce/resourceUrl/pirResources';
import messageChannel from '@salesforce/messageChannel/ppLightningMessageService__c';
import getPDE from '@salesforce/apex/PatientDelegateEnrollmentService.getPDE';
import removeAssignment from '@salesforce/apex/PatientDelegateEnrollmentService.removeAssignment';
import doAddAssignment from '@salesforce/apex/PatientDelegateEnrollmentService.doAddAssignment';
import deleteDelegates from '@salesforce/apex/PatientDelegateEnrollmentService.deleteDelegates';
import getFilterData from '@salesforce/apex/MyTeamRemote.getFilterData';
import largeTemplate from './manageDelegatesDesktop.html';
import mobileTemplate from './manageDelegatesMobile.html';
import formFactor from '@salesforce/client/formFactor';

import {
    subscribe,
    unsubscribe,
    MessageContext,
    APPLICATION_SCOPE
} from 'lightning/messageService';
export default class ManageDelegates extends NavigationMixin(LightningElement) {
    @api isDelegate;
    @api participantState;
    isDesktop;
    @api consentPreferenceData;
    @api userMode;
    @api isRTL;
    @track listPDE = [];
    @track formerListPDE = [];
    @wire(MessageContext)
    messageContext;
    subscription = null;
    icon_url = pp_icons + '/Avatar_Delegate.svg';
    noDelIcon_url = pp_icons + '/Avatar-Delegate-Gray.svg';
    selectMenuTriagleDown_url = pp_icons + '/SelectMenuTriangleDown_blue.svg';
    iconTriangleRight_url = pp_icons + '/iconTriangleRight_blue.svg';
    deleteIcon = pirResources + '/pirResources/icons/trash-delete.svg';
    deleteIconRed = pirResources + '/pirResources/icons/trash-delete-red.svg';
    spinner = false;
    loaded = false;
    showAddDelegatePage = false;
    showpopup = false;
    removeStudyPDEId;
    deletePatientDelId;
    showDeletePopup = false;
    modalMesstext;
    showActiveDelegates = true;
    showFormerDelegates = true;
    hasNoActiveDelegate = true;
    hasNoFormerDelegate = true;
    addNewStudy = false;
    @track availableStudyData = [];
    @track studyToAssing = [];
    @track studiesSelected = [];
    totalNoOfStudies;
    totalNoOfStudiesToAssign = 0;
    totalNoOfStudiesActivelyAssigned = 0;
    isAtLeastOneStudySelected = false;
    diabledAddNewButton = false;
    dataInitialized = false;
    isEmailConsentChecked = false;

    label = {
        BTN_Add_New_Delegate,
        PP_ManageDelegates,
        PP_Remove,
        PG_PST_L_Delegates_Remove_Mess_P1_New,
        PG_PST_L_Delegates_Remove_Mess_P3_New,
        PG_PST_L_Delegates_Remove_Himself_Header,
        PP_Delegate_Updated,
        PP_ActiveDelegates,
        PP_FormerDelegates,
        PP_AddAssignment,
        PP_DelegateWithdrawn,
        PP_Delegate_Delegate_Warning,
        PP_Delegate_Delegate,
        BTN_Save,
        PP_Delegate_Email_Consent,
        PIR_Discard,
        PP_NO_Active_Delegate,
        Icon_Delete
    };

    connectedCallback() {
        formFactor != 'Small' ? (this.isDesktop = true) : (this.isDesktop = false);

        if (!this.loaded) {
            loadScript(this, rrCommunity).then(() => {
                if (communityService.isMobileSDK()) {
                    this.isDesktop = false;
                }
            });
            // getisRTL()
            //     .then((data) => {
            //         this.isRTL = data;
            //     })
            //     .catch(function (error) {
            //         console.error('Error RTL: ' + JSON.stringify(error));
            //     });
        }
        this.initializeData();
        this.subscribeToMessageChannel();
    }

    render() {
        //return this.isDesktop ? manageDelegatesDesktop : manageDelegatesMobile;
        return formFactor === 'Small' ? mobileTemplate : largeTemplate;
    }

    initializeData() {
        this.spinner = true;

        //get Available list of studies of participant
        getFilterData({
            userMode: this.userMode
        })
            .then((result) => {
                this.availableStudyData = result;
                // //console.log('Delegate fileter data: '+JSON.stringify(result));
                this.totalNoOfStudies = result.studies.length;
                // this.isLoading = false;
                // this.spinner = false;
            })
            .catch((error) => {
                this.isLoading = false;
                communityService.showToast(
                    '',
                    'error',
                    'Failed To read the Data(study Filter)...',
                    100
                );
                this.spinner = false;
            });

        //Get Patient Delegate Enrollment records.
        getPDE()
            .then((result) => {
                //console.log('success', result);
                this.setInitializedData(result);
                this.spinner = false;
                this.dataInitialized = true;
            })
            .catch((error) => {
                //console.log('error');
                this.spinner = false;
            });
    }

    setInitializedData(result) {
        this.listPDE = result.activePDEWrapperList;
        this.formerListPDE = result.formerPDEWrapperList;
        this.setDefaultValuesToInItData(this.listPDE, true);
        this.setDefaultValuesToInItData(this.formerListPDE, false);
        this.setActiveAndFormerDelegateFlags();
    }

    setActiveAndFormerDelegateFlags() {
        this.hasNoActiveDelegate = this.listPDE.length == 0 ? true : false;
        this.hasNoFormerDelegate = this.formerListPDE.length == 0 ? true : false;
    }
    //this method will separate email chars in two parts to partially mask the email address.
    setDefaultValuesToInItData(pdeList, activeDelegates) {
        pdeList.forEach((pde) => {
            this.maskEmail(pde);
            //Add Additional default flags in the list of PDEnrollments.
            if (activeDelegates) {
                //For Active Delegates.
                pde['addNewStudy'] = false;
                pde['disableAddAssignmentButton'] = false;
                pde['isEmailConsentChecked'] = false;
                this.totalNoOfStudiesActivelyAssigned = 0;
                pde.PDEEnrollments.forEach((pden) => {
                    pden['disableRemoveButton'] = false;
                    if (pden.Status__c === 'Active') {
                        pden['isActive'] = true;
                        this.totalNoOfStudiesActivelyAssigned += 1;
                    } else {
                        pden['isActive'] = false;
                    }
                });
                pde['showAddAssignmentButton'] = this.showAddAssignmentButton();
                //Filter studies which are not assigned to patient Delegates.
                pde['studieToAssign'] = [];
                this.availableStudyData.studies.forEach((std) => {
                    std['assigned'] = false;
                    std['active'] = false;
                    std['pdEnrollmentId'] = '';
                    //let tempStudy = [];
                    pde.PDEEnrollments.forEach((pden) => {
                        if (std.value === pden.Participant_Enrollment__c) {
                            std.assigned = true;
                            std.pdEnrollmentId = pden.Id;
                            //If Study is assinged to delege and also active.
                            if (pden.Status__c === 'Active') {
                                std.active = true;
                            }
                        }
                    });
                    pde.studieToAssign.push({
                        label: std.label,
                        value: std.value,
                        assigned: std.assigned,
                        active: std.active,
                        pdEnrollmentId: std.pdEnrollmentId
                    });
                });
            } else {
                //for Former Delegate, set flag default value to false.
                pde['showDeleteRedIcon'] = false;
                pde['addNewStudyFormer'] = false;
                pde['disableAddAssignmentButton'] = false;
                pde['disableDeleteButton'] = false;
                pde['isEmailConsentChecked'] = false;
                // pde.PDEEnrollmentsFormer.forEach((pdenFormer) => {
                //     //If not withdrawn delegate.
                //     if(!std.isWithdrawn){
                //     }
                // });
            }
        });
    }

    //mask Email for active/former delegate
    maskEmail(pde) {
        let pdeEmailLength = pde.PatientDelegate.Email__c.length;
        let maskedEmail = '';
        for (let i = 0; i < pdeEmailLength; i++) {
            if (i <= 2) {
                maskedEmail += pde.PatientDelegate.Email__c.charAt(i);
            } else {
                maskedEmail += '*';
            }
        }
        pde.PatientDelegate.Email__c = maskedEmail;
    }
    //Subscribe the message channel to read the message published.
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                messageChannel,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }
    //Handler for message received by Aura component
    handleMessage(message) {
        //If backToManageDelegate = false when we click on back to Manage delegate button.
        if (
            message != undefined &&
            message.showAddDelegatePage != undefined &&
            message.showAddDelegatePage == false
        ) {
            //this.spinner = true;
            this.initializeData();
            this.showAddDelegatePage = false;
            //this.spinner = false;
        }
        //handle selected studies from the child component.
        if (message != undefined && message.selectedListOfStudies != undefined) {
            this.studiesSelected = [];
            //this.delegateFilterData.studiesSelected = message.selectedListOfStudies;
            this.studiesSelected = message.selectedListOfStudies;
            //console.log('studiesSelected: ', this.studiesSelected);
            if (message.selectedListOfStudies.length > 0) {
                this.isAtLeastOneStudySelected = true;
            } else if (message.selectedListOfStudies.length == 0) {
                this.isAtLeastOneStudySelected = false;
            }
        }
    }
    //Subscribe the message channel
    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    get addDelBtnMarin() {
        return this.isRTL
            ? 'mr-5 add-Delegate-Btn slds-float_left'
            : 'ml-5 add-Delegate-Btn slds-float_right';
    }
    // get addDelBtnMarinMobile() {
    //     return this.isRTL
    //         ? 'slds-m-top_small slds-p-left_large'
    //         : 'slds-m-top_small slds-p-right_large';
    // }
    get removeDelBtn() {
        return this.isRTL
            ? 'ml-24p remove-Delegate-Btn slds-float_left'
            : 'mr-24p remove-Delegate-Btn slds-float_right';
    }
    get removeDelBtnMobile() {
        return this.isRTL
            ? 'ml-24p remove-Delegate-Btn slds-float_left h-40'
            : 'mr-24p remove-Delegate-Btn slds-float_right h-40';
    }
    get studyCodeNameClass() {
        return this.isRTL ? 'mr-27p study-code-name' : 'ml-27p study-code-name h-40';
    }
    get studyCodeNameClassMobile() {
        return this.isRTL ? 'mr-27p study-code-name' : 'ml-27p study-code-name h-40';
    }
    M;
    get addAssignmentBtn() {
        return this.isRTL
            ? 'slds-align_absolute-center add-assignment-Btn'
            : 'slds-align_absolute-center add-assignment-Btn';
    }
    get addAssignmentBtnMobile() {
        return this.isRTL
            ? 'slds-align_absolute-center add-assignment-Btn h-40'
            : 'slds-align_absolute-center add-assignment-Btn h-40';
    }
    get saveButtonClass() {
        return this.isEmailConsentChecked && this.isAtLeastOneStudySelected
            ? 'save-del-btn addDelegateMobile'
            : 'save-del-btn btn-save-opacity addDelegateMobile';
    }
    get delInfoFormer() {
        return this.isRTL ? 'slds-p-right_large' : 'slds-p-left_large';
    }
    get delInfoFormerMob() {
        return this.isRTL ? 'slds-p-right_small' : 'slds-p-left_small';
    }
    get delInfoFormer1() {
        return this.isRTL ? 'p-right-41' : 'p-left-41';
    }
    get delInfoFormer1Mob() {
        return this.isRTL ? 'p-right-12' : 'p-left-12';
    }
    get delInfoActive() {
        return this.isRTL ? 'slds-p-right_large' : 'slds-p-left_large';
    }
    get delInfoActiveMob() {
        return this.isRTL ? 'slds-p-right_small' : 'slds-p-left_small';
    }
    get delAvararIcon() {
        return this.isRTL
            ? 'slds-p-right_small slds-p-top_xx-small'
            : 'slds-p-left_small slds-p-top_xx-small';
    }
    get delAvararIconMobile() {
        return this.isRTL
            ? 'slds-p-right_small slds-p-top_x-small'
            : 'slds-p-left_small slds-p-top_x-small';
    }
    get deleteIconClassMobile() {
        return this.isRTL
            ? ' slds-align_absolute-center slds-p-right_medium'
            : ' slds-align_absolute-center slds-p-left_medium';
    }

    get disableSaveButton() {
        return this.isEmailConsentChecked && this.isAtLeastOneStudySelected ? false : true;
    }
    get isAddNewDelegate() {
        return false;
    }
    handleConsentCheckActiveDel(event) {
        let delId = event.currentTarget.dataset.pdid;
        let isEmailConsentChecked = event.target.checked;
        this.listPDE.forEach((pde) => {
            if (pde.PatientDelegate.Id === delId) {
                pde.isEmailConsentChecked = isEmailConsentChecked;
                this.isEmailConsentChecked = isEmailConsentChecked;
            }
        });
    }
    handleConsentCheckFormerDel(event) {
        let delId = event.currentTarget.dataset.pdid;
        let isEmailConsentChecked = event.target.checked;
        this.formerListPDE.forEach((pde) => {
            if (pde.PatientDelegate.Id === delId) {
                pde.isEmailConsentChecked = isEmailConsentChecked;
                this.isEmailConsentChecked = isEmailConsentChecked;
            }
        });
    }
    showAddAssignmentButton() {
        return this.totalNoOfStudies != this.totalNoOfStudiesActivelyAssigned ? true : false;
    }
    //Navigate to Add delegate screen
    navToAddDelegate() {
        //communityService.navigateToPage('new-team-member');
        this.showAddDelegatePage = true;
    }
    //This method will open Remove Delegate Modal.
    openRemoveDelegateModal(event) {
        this.removeStudyPDEId = '';
        let pdfn = event.target.dataset.pdfn;
        let pdln = event.target.dataset.pdln;
        this.removeStudyPDEId = event.currentTarget.dataset.pdeid;
        //console.log('removeStudyPDEId:', this.removeStudyPDEId);

        this.modalMesstext =
            this.label.PG_PST_L_Delegates_Remove_Mess_P1_New +
            ' ' +
            pdfn +
            ' ' +
            pdln +
            '. ' +
            this.label.PG_PST_L_Delegates_Remove_Mess_P3_New;
        this.showpopup = true;
        //this.removeStudyPDEId = event.currentTarget.dataset.pdeid;
    }
    openDeleteDelegateModal(event) {
        this.showDeletePopup = true;
        this.deletePatientDelId = event.currentTarget.dataset.id;
    }

    //This method will remove the delegate once Confirm button clicked on Remove Delegate Modal.
    handleRemoveDelegate(event) {
        this.spinner = true;
        let pdEnrollmentId = event.detail.pdenrollmentid;
        ////console.log('m-del pdEnrollmentId: ',this.removeStudyPDEId);
        removeAssignment({
            pDEId: pdEnrollmentId
        })
            .then((result) => {
                this.showpopup = false;
                this.setInitializedData(result);
                // window.scrollTo({ top: 0, behavior: 'smooth' });
                this.spinner = false;
                communityService.showToast('', 'success', this.label.PP_Delegate_Updated, 300);
            })
            .catch((error) => {
                //console.log('error');
                this.spinner = false;
            });
    }
    handleModalClose(event) {
        const showHideModal = event.detail;
        this.showpopup = showHideModal;
        this.removeStudyPDEId = '';
    }
    handleDeleteModalClose(event) {
        const showHideModal = event.detail;
        this.showDeletePopup = showHideModal;
        this.deletePatientDelId = '';
    }

    handleDeleteDelegate(event) {
        this.spinner = true;
        let patientdelegateid = event.detail.patientdelegateid;
        deleteDelegates({
            pdId: patientdelegateid
        })
            .then((result) => {
                this.showDeletePopup = false;
                this.setInitializedData(result);
                this.spinner = false;
                communityService.showToast('', 'success', this.label.PP_Delegate_Updated, 300);
            })
            .catch((error) => {
                //console.log('error');
                this.spinner = false;
            });
    }
    //This method will toggle the Active delegate view
    toggleActiveDelegateView() {
        this.showActiveDelegates = this.showActiveDelegates == true ? false : true;
    }
    //This method will toggle the Former delegate view
    toggleFormerDelegateView() {
        this.showFormerDelegates = this.showFormerDelegates == true ? false : true;
    }
    //Add assignment from Active delegate section
    addAssignment(event) {
        let delId = event.currentTarget.dataset.pdid;
        this.studyToAssing = [];
        this.totalNoOfStudiesToAssign = 0;
        this.diabledAddNewButton = true;
        this.listPDE.forEach((pde) => {
            if (pde.PatientDelegate.Id === delId) {
                pde.addNewStudy = true;
                pde.studieToAssign.forEach((std) => {
                    //if studie is not assinged or it is assinged but not active.
                    if (std.assigned == false || (std.assigned == true && std.active == false)) {
                        this.studyToAssing.push({ label: std.label, value: std.value });
                    }
                });
            }
            //Disable Add Assignment button for active delegates.
            pde.disableAddAssignmentButton = true;
            //Disable Remove buttons for other delegates.
            pde.PDEEnrollments.forEach((pden) => {
                pden.disableRemoveButton = true;
            });
        });
        this.totalNoOfStudiesToAssign = this.studyToAssing.length;

        //Disbale all the buttons at former delegate section.
        this.formerListPDE.forEach((pde) => {
            pde.disableAddAssignmentButton = true;
            pde.disableDeleteButton = true;
        });
    }

    //Add assignment from Former delegate section.
    addAssignmentFormer(event) {
        this.diabledAddNewButton = true;
        let delId = event.currentTarget.dataset.pdid;
        this.formerListPDE.forEach((pde) => {
            if (pde.PatientDelegate.Id === delId) {
                pde.addNewStudyFormer = true;
            }
            //Disable Add assignment and Delete buttons for former delegates.
            pde.disableAddAssignmentButton = true;
            pde.disableDeleteButton = true;
        });

        //Disable Add Assignment and Remove buttons for all the Active delegates.
        this.listPDE.forEach((pde) => {
            //Disable Add Assignment button
            pde.disableAddAssignmentButton = true;
            //Disable Remove buttons
            pde.PDEEnrollments.forEach((pden) => {
                pden.disableRemoveButton = true;
            });
        });
    }
    //Discard Assignment from Active delegate section.
    discardAssignment(event) {
        this.diabledAddNewButton = false;
        let delId = event.currentTarget.dataset.pdid;
        this.listPDE.forEach((pde) => {
            if (pde.PatientDelegate.Id === delId) {
                pde.addNewStudy = false;
                pde.isEmailConsentChecked = false;
                this.isEmailConsentChecked = false;
            }
            //Re Enable Add Assignment button for active delegates.
            pde.disableAddAssignmentButton = false;
            //Re Enable Remove buttons for active delegates.
            pde.PDEEnrollments.forEach((pden) => {
                pden.disableRemoveButton = false;
            });
        });
        //Re Enable all the buttons at former delegate section.
        this.formerListPDE.forEach((pde) => {
            pde.disableAddAssignmentButton = false;
            pde.disableDeleteButton = false;
        });
        this.isAtLeastOneStudySelected = false;
    }
    //Discard Assignment from Former delegate section.
    discardAssignmentFormer(event) {
        this.diabledAddNewButton = false;
        let delId = event.currentTarget.dataset.pdid;
        this.formerListPDE.forEach((pde) => {
            if (pde.PatientDelegate.Id === delId) {
                pde.addNewStudyFormer = false;
                pde.isEmailConsentChecked = false;
                this.isEmailConsentChecked = false;
            }
            //Re enable Add assignment and Delete buttons for former delegates.
            pde.disableAddAssignmentButton = false;
            pde.disableDeleteButton = false;
        });
        //Re Enable Add Assignment and Remove buttons for all the Active delegates.
        this.listPDE.forEach((pde) => {
            //Re Enable Add Assignment button
            pde.disableAddAssignmentButton = false;
            //Re Enable Remove buttons
            pde.PDEEnrollments.forEach((pden) => {
                pden.disableRemoveButton = false;
            });
        });
        this.isAtLeastOneStudySelected = false;
    }

    //Flipt the delete icon between gray and red.
    toggleDeleteIcon(event) {
        let recordId = event.currentTarget.dataset.pdid;
        let a = event.target.dataset.pdid;

        this.formerListPDE.filter(function (del) {
            if (del.pdId === recordId) {
                del.showDeleteRedIcon = del.showDeleteRedIcon ? false : true;
            }
        });
    }

    //Assign study/Studies to Active delegates.
    doSave(event) {
        this.spinner = true;
        this.diabledAddNewButton = false;
        let id = event.currentTarget.dataset.id;
        let pdid = event.currentTarget.dataset.pdid;
        let attestedtimestmp = event.currentTarget.dataset.attestedtimestmp;
        let attestedby = event.currentTarget.dataset.attestedby;
        let patientDelegate = {
            pdId: pdid,
            attestedby: attestedby,
            attestedtimestmp: attestedtimestmp
        };

        var studiesSelected = this.studiesSelected;
        let tudyToAssing = [];
        //Iterate over list of PDE list.
        this.listPDE.forEach((pde) => {
            //check if the Delegate is the current Delegate.
            if (pde.PatientDelegate.Id === id) {
                //Iterate over the list of selected studies for current Delegate.
                studiesSelected.forEach((stdSelected) => {
                    //Iterate over the list of studies to assign for current delegate.
                    pde.studieToAssign.forEach((pdStdToAssign) => {
                        if (stdSelected.value === pdStdToAssign.value) {
                            tudyToAssing.push({
                                label: pdStdToAssign.label,
                                value: pdStdToAssign.value,
                                assigned: pdStdToAssign.assigned,
                                active: pdStdToAssign.active,
                                pdEnrollmentId: pdStdToAssign.pdEnrollmentId
                            });
                        }
                    });
                });
            }
        });
        // //console.log('tudyToAssing: ',JSON.stringify(tudyToAssing));

        //Assign studies to the delegate.
        doAddAssignment({
            delegateStr: JSON.stringify(patientDelegate),
            studyPERData: JSON.stringify(tudyToAssing)
        })
            .then((result) => {
                //this.setInitializedData(result);
                this.studiesSelected = [];
                this.initializeData();
                this.spinner = false;
                this.template.querySelector('[data-id="emailconsentcheck"]').checked = false;
                this.isEmailConsentChecked = false;
                this.isAtLeastOneStudySelected = false;
                if (this.dataInitialized) {
                    communityService.showToast('', 'success', this.label.PP_Delegate_Updated, 300);
                }
            })
            .catch((error) => {
                //console.log('error');
                this.spinner = false;
            });
    }
    //Assign study/Studies to former delegates.
    doSaveFormer(event) {
        this.spinner = true;
        this.diabledAddNewButton = false;
        let id = event.currentTarget.dataset.id;
        let pdid = event.currentTarget.dataset.pdid;
        let attestedtimestmp = event.currentTarget.dataset.attestedtimestmp;
        let attestedby = event.currentTarget.dataset.attestedby;
        let patientDelegate = {
            pdId: pdid,
            attestedby: attestedby,
            attestedtimestmp: attestedtimestmp
        };

        var studiesSelected = this.studiesSelected;
        let tudyToAssing = [];
        //Iterate over list of PDE list.
        this.formerListPDE.forEach((pde) => {
            //check if the Delegate is the current Delegate.
            if (pde.PatientDelegate.Id === id) {
                //Iterate over the list of selected studies for current Delegate.
                studiesSelected.forEach((stdSelected) => {
                    let assigned = false;
                    let pdEnrollmentId = '';
                    //Iterate over the list of studies to assign for current delegate.
                    pde.PDEEnrollmentsFormer.forEach((pden) => {
                        //If Selected study is already assigned to delegate in past but active now.
                        if (stdSelected.value === pden.Participant_Enrollment__c) {
                            assigned = true;
                            pdEnrollmentId = pden.Id;
                        }
                    });
                    tudyToAssing.push({
                        label: stdSelected.label,
                        value: stdSelected.value,
                        assigned: assigned,
                        active: false,
                        pdEnrollmentId: pdEnrollmentId
                    });
                });
            }
        });
        //Assign studies to the former delegate.
        doAddAssignment({
            delegateStr: JSON.stringify(patientDelegate),
            studyPERData: JSON.stringify(tudyToAssing)
        })
            .then((result) => {
                //this.setInitializedData(result);
                this.studiesSelected = [];
                this.initializeData();
                this.spinner = false;
                this.template.querySelector('[data-id="emailconsentcheck"]').checked = false;
                this.isEmailConsentChecked = false;
                this.isAtLeastOneStudySelected = false;
                if (this.dataInitialized) {
                    communityService.showToast('', 'success', this.label.PP_Delegate_Updated, 300);
                }
            })
            .catch((error) => {
                //console.log('error');
                this.spinner = false;
            });
    }
}
