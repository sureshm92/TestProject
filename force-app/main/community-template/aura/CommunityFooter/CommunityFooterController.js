/**
 * Created by Nargiz Mamedova on 8/11/2020.
 */

({
    doInit: function(component, event, helper) {
        let sponsor = communityService.getCurrentSponsorName();
        console.log('commName: ' + communityService.getCurrentCommunityName());
        //let isGsk = communityService.getCommunityURLPathPrefix().includes("/gsk");
        if (communityService.getCurrentCommunityName() == 'GSK Community') {
            component.set('v.isGsk', true);
        } else if (
            communityService.getCurrentCommunityName() == 'Janssen Community' ||
            communityService.getCommunityName().includes('Janssen')
        ) {
            component.set('v.communityType', 'Janssen');
        }

        if(communityService.getCurrentCommunityTemplateName()=='PatientPortal'){
            component.set('v.isPatientPortal', true);
        }
        let currentPage = communityService.getPageName();
        let hasIQVIAStudiesPI = communityService.getHasIQVIAStudiesPI();
        const pagesWithSharedPrivacyPolicy = communityService.getPagesWithSharedPrivacyPolicy();
        component.set(
            'v.defaultTC',
            pagesWithSharedPrivacyPolicy.has(currentPage) && hasIQVIAStudiesPI
        );
        component.set('v.sponsor', sponsor);
        component.set('v.retUrl', communityService.createRetString());
    }
});
