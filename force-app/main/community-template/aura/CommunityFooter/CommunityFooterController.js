/**
 * Created by Nargiz Mamedova on 8/11/2020.
 */

({
    doInit: function(component, event, helper) {
        let sponsor = communityService.getCurrentSponsorName();
        let communityName = communityService.getCurrentCommunityName();
        let strCommunityName = '';
        //let isGsk = communityService.getCommunityURLPathPrefix().includes("/gsk");
        if (communityName == 'GSK Community') {
            component.set('v.isGsk', true);
            strCommunityName = 'GSK Community';
        } else if (
            communityName == 'Janssen Community' ||
            communityName.includes('Janssen')
        ) {
            component.set('v.communityType', 'Janssen');
            strCommunityName = 'Janssen Community';
             
        } 
        if(communityService.getCurrentCommunityTemplateName()=='PatientPortal'){
            component.set('v.isPatientPortal', true);
            strCommunityName = 'PatientPortal'; 
        } 
        if(communityName == 'IQVIA Referral Hub')
        {
            strCommunityName = 'IQVIA Referral Hub'; 
        }

        var action = component.get("c.getCPRALink");
        action.setParams({ strCommunityType : strCommunityName });
        action.setCallback(this, function(response) {
            if(response.getReturnValue())
            {
                var getReturnValueMD = response.getReturnValue();
                component.set('v.enablePrivacyChoice',true);
                var labelReference = $A.getReference("$Label.c." + getReturnValueMD.CPRA_Label__c);
 
                component.set('v.CPRAlabel', labelReference); 
                component.set('v.CPRALinkToredirect',getReturnValueMD.Link_to_redirect__c); 
            }
            else {
                component.set('v.enablePrivacyChoice',false);
                
            }
            
        });
        $A.enqueueAction(action);

        if ($A.get('$Browser.formFactor') !== 'DESKTOP') {
            component.set('v.mobile', true);
        }else{
            component.set('v.mobile', false);
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