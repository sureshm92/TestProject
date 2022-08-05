import { LightningElement } from 'lwc';
import pgPstLDelegates_Add from '@salesforce/label/c.PG_PST_L_Delegates_Add';
export default class PpMyTeam extends LightningElement {
    userMode;
    label = {
        pgPstLDelegates_Add
    };
    doInit(event) {
        getInitData({
            userMode: userMode,
            parentId: selectedParent ? selectedParent : communityService.getDelegateId()
        });
    }
}
