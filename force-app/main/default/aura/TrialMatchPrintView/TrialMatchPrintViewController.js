/**
 * Created by Kryvolap
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;

        if(!communityService.isDummy()) {
            let peId = communityService.getUrlParameter('id');
            communityService.executeAction(component, 'getMatchCTPs', {
                urlid: peId
            }, function (data) {
                console.log('Data:'+JSON.stringify(data));
                component.set('v.trialmatchCTPs', data.trialmatchctps);
                component.set('v.initialized', true);
                
                setTimeout(
                    $A.getCallback(function () {
                        window.print();
                        window.close();
                    }), 500
                );
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    }
});