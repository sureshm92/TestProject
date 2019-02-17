({
    setData: function(component, pEnroll){

        var RRStatus = pEnroll.Medical_Record_Review_Status__c;
        var PStatus = pEnroll.Participant_Status__c;
        var PreSStatus = pEnroll.Pre_screening_Status__c;

        if(RRStatus === "Pass") {
            component.set("v.isReviewPass", true);
            component.set("v.recordReviewMessage", $A.get("$Label.c.PG_MRRLI_MSG_Passed_medical_record_review"));
        } else if(RRStatus === "Fail") {
            component.set("v.isReviewPass", false);
            component.set("v.recordReviewMessage", $A.get("$Label.c.PG_MRRLI_MSG_Failed_medical_record_review"));
        }

        if(PStatus === "Excluded from Referring"){
            component.set("v.isReferred", false);
            component.set("v.referringMessage", $A.get("$Label.c.PG_MRRLI_MSG_Excluded_from_referring"));
        } else if (PStatus === "Failed Referral") {
            component.set("v.isReferred", false);
            component.set("v.referringMessage", pEnroll.Non_Referral_Reason__c + " " + $A.get("$Label.c.PG_MRRLI_MSG_not_referred"));
        } else if (PStatus !== "Failed Review" && PStatus !== "Pending Referral") {
            component.set("v.isReferred", true);
            if(PreSStatus === "Pass"){
                component.set("v.referringMessage", $A.get("$Label.c.PG_MRRLI_MSG_Passed_pre_eligibility_screening_referred"));
            } else {
                component.set("v.referringMessage", $A.get("$Label.c.PG_MRRLI_MSG_Referred"));
            }
        }

        component.set("v.addedOnDate", $A.get("$Label.c.PG_MRRLI_MSG_Added_on") + " " + pEnroll.CreatedDate.substr(0, 10));
    }
})