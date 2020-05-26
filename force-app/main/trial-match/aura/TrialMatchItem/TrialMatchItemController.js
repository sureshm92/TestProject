({
    navigateToLearnMorePage : function(component, event, helper) {
        var ctpidval = component.get("v.trialMatch.ctpid");
        console.log(ctpidval);
        $A.createComponent(
            "c:TrialMatchPageLearnMoreLink",
            {
                ctpId: ctpidval,
            },
            function(newCmp){
                   //alert("new comp");
            }
        );
    }
})