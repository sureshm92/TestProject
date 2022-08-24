import { LightningElement, api, track } from 'lwc';
import pgPstLDelegates_Add from '@salesforce/label/c.PG_PST_L_Delegates_Add';
import PG_MT_BTN_Add_New_Team_Member from '@salesforce/label/c.PG_MT_BTN_Add_New_Team_Member';
import PG_PST_L_Delegates_Click_Add_New from '@salesforce/label/c.PG_PST_L_Delegates_Click_Add_New';
import PP_ManageDelegates from '@salesforce/label/c.PP_ManageDelegates';
import Back_to_Manage_Delegates from '@salesforce/label/c.Back_to_Manage_Delegates';
import Add_New_Delegate from '@salesforce/label/c.Add_New_Delegate';

import PP_AS_COMPLETE_TASK from '@salesforce/label/c.PP_AS_COMPLETE_TASK';
import PP_AS_RECEIVE_EMAIL from '@salesforce/label/c.PP_AS_RECEIVE_EMAIL';
import PP_AS_LAB_RESULTS from '@salesforce/label/c.PP_AS_LAB_RESULTS';
import PP_AS_VITALS from '@salesforce/label/c.PP_AS_VITALS';
import PP_AS_MEASUREMENTS from '@salesforce/label/c.PP_AS_MEASUREMENTS';
import PP_AS_CONDITIONAL_FEATURE from '@salesforce/label/c.PP_AS_CONDITIONAL_FEATURE';

import getInitData from '@salesforce/apex/MyTeamRemote.getInitData';

export default class PpMyTeam extends LightningElement {
    @api usermode;
    @track delegates = [];
    @track delegateOptions = [];
    piSelectedParent = '';
    @track piDelegateParents = [];
    @track piSelectedParent = '';
    currentUserContactId = '';
    spinner = false;
    isLoading = false;
    isInitialized = false;

    showppNewTeamMember = false;
    label = {
        pgPstLDelegates_Add,
        PG_PST_L_Delegates_Click_Add_New,
        PG_MT_BTN_Add_New_Team_Member,
        PP_ManageDelegates,
        Back_to_Manage_Delegates,
        Add_New_Delegate,
        PP_AS_COMPLETE_TASK,
        PP_AS_RECEIVE_EMAIL,
        PP_AS_LAB_RESULTS,
        PP_AS_VITALS,
        PP_AS_MEASUREMENTS,
        PP_AS_CONDITIONAL_FEATURE
    };

    connectedCallback() {
        if (!communityService.isInitialized()) return;
        if (
            communityService.getCurrentCommunityMode().isDelegate &&
            this.usermode === 'Participant'
        )
            communityService.navigateToHome();
        var selectedParent = this.piSelectedParent;
        var URLParentId = communityService.getUrlParameter('id');
        if (
            (selectedParent === undefined || selectedParent === '') &&
            URLParentId !== undefined &&
            URLParentId !== ''
        ) {
            selectedParent = URLParentId;
        }
        this.handleOnLoadData(this.usermode, selectedParent);
    }

    get isDelegatePresent() {
        console.log('rk::', this.delegates.length);
        return this.delegates.length ? true : false;
    }
    handleBackToDelegates() {
        this.handleOnLoadData(this.usermode, this.piSelectedParent);
        this.showppNewTeamMember = false;
    }
    handleInitData(event) {
        this.handleOnLoadData(event.detail.usermode, event.detail.selectedparent);
    }
    inviteTeamMembers(event) {
        this.showppNewTeamMember = true;
    }
    handleOnLoadData(usermode, selectedparent) {
        this.isLoading = true;
        getInitData({
            userMode: usermode,
            parentId: selectedparent ? selectedparent : communityService.getDelegateId()
        })
            .then((result) => {
                var initData = JSON.parse(result);
                this.delegates = initData.delegates;
                this.delegateOptions = initData.delegateOptions;
                this.hasStudies = initData.hasStudies;
                this.currentUserContactId = initData.currentUserContactId;

                var selectedParent = selectedparent;
                if (selectedParent === undefined || selectedParent === '') {
                    this.piDelegateParents = initData.piDelegateParents;
                    this.piSelectedParent = initData.piSelectedParent;
                }
                this.showppNewTeamMember = false;
                this.isLoading = false;
                this.isInitialized = true;
            })
            .catch((error) => {
                communityService.showToast('', 'error', 'Failed To read the Data...', 100);
                this.isLoading = false;
            });
    }
}
