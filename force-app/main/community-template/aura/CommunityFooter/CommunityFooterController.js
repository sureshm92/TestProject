/**
 * Created by Nargiz Mamedova on 8/11/2020.
 */

({
    doInit : function (component, event, helper) {
        let sponsor = communityService.getCurrentSponsorName();
        let currentPage = communityService.getPageName();
        let hasIQVIAStudiesPI = communityService.getHasIQVIAStudiesPI();
        const pagesWithSharedPrivacyPolicy = communityService.getPagesWithSharedPrivacyPolicy();
        component.set('v.defaultTC', pagesWithSharedPrivacyPolicy.has(currentPage) && hasIQVIAStudiesPI);
        component.set('v.sponsor', sponsor)
        component.set('v.retUrl', communityService.createRetString());
    }
});