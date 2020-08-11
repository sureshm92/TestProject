/**
 * Created by Nargiz Mamedova on 8/11/2020.
 */

({
    doInit : function (component, event, helper) {
        let sponsor = communityService.getCurrentSponsorName();
        component.set('v.sponsor', sponsor)
    }
});