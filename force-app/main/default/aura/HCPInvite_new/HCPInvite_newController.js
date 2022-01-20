({
    doInit: function (cmp, event, helper) {
        cmp.find('spinner').show();
        var getcmp = cmp.find("createCmp");
        $A.createComponent(
            "c:HCPInvite_VerifyInformation",
            {},
            function verifyInfo(verifyInfoCmp, status) {
                if (cmp.isValid() && status === "SUCCESS") {
                    var body = getcmp.get("v.body");
                    body.push(verifyInfoCmp);
                    // cmp.find('spinner').hide();
                    getcmp.set("v.body", body);
                    cmp.find('spinner').hide();
                }
            }
        );
    },
    
    handleEvent: function (cmp, evt, helper) {
        cmp.find('spinner').show();
        var userName = evt.getParam("UserName");
        var userId = evt.getParam("UserId");
        var contactUserWrapper = evt.getParam("contactUserWrapper");
        var componentCalledfrom = evt.getParam("componentCalled");
        
        var getProfileDivCmp = cmp.find("profileDiv");
        var getProfileTextDivCmp = cmp.find("profileDivText");
        var getTermsDivCmpTerms = cmp.find("TermsDiv");
        var getTermsTextDivCmpTerms = cmp.find("TermsDivText");
        var getcmp = cmp.find("createCmp");
        if (componentCalledfrom == "verifyInfo") {
            
            $A.util.addClass(getProfileDivCmp, "selected");
            $A.util.addClass(getProfileTextDivCmp, "selected");
            $A.util.removeClass(getTermsDivCmpTerms, "selected"); 
            $A.util.removeClass(getTermsTextDivCmpTerms, "selected");
            $A.createComponent(
                "c:HCPInvite_ProfileInformation",
                {
                    UserName: userName,  
                    userId: userId, 
                    ContactUserWrapperData : contactUserWrapper //This data will be coming from terms n condtions back button  
                },
                function verifyInfo(verifyInfoCmp, status) {
                    if (cmp.isValid() && status === "SUCCESS") {
                        var body = getcmp.get("v.body");
                        //body.push(verifyInfoCmp);
                        cmp.find('spinner').hide();
                        getcmp.set("v.body", verifyInfoCmp);
                    }
                }
            );
        } else {
            $A.util.addClass(getTermsDivCmpTerms, "selected");
            $A.util.addClass(getTermsTextDivCmpTerms, "selected"); 
            $A.createComponent(
                "c:HCPInvite_TermsConditions",
                {
                    UserName: userName,  
                    userId: userId,
                    ContactUserWrapperData : contactUserWrapper 
                },
                function verifyInfo(verifyInfoCmp, status) {
                    if (cmp.isValid() && status === "SUCCESS") {
                        var body = getcmp.get("v.body");
                        //body.push(verifyInfoCmp);
                        cmp.find('spinner').hide();
                        getcmp.set("v.body", verifyInfoCmp);
                    }
                }
            );
        }
    },
});