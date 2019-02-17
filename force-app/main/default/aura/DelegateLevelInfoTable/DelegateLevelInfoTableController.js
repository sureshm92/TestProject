/**
 * Created by Kryvolap on 13.09.2018.
 */
({
    doInit: function (component, event, hepler) {
        var userMode = component.get("v.userMode");
        debugger;
        if(userMode === 'PI'){
            var header = {
                text : $A.get("$Label.c.DLIT_L_PERMISSIONS_BY_LEVEL"),
                levels : ['1','2','3']
            };
            component.set("v.header",header);
            var capList = [
                {
                    text : $A.get("$Label.c.DLIT_L_Accept_a_referring_HCP"),
                    levels : [true,false,false]
                },
                {
                    text: $A.get("$Label.c.DLIT_L_Decline_or_place_on_hold_a_referring_HCP"),
                    levels: [true, false, false]
                },
                {
                    text : $A.get("$Label.c.DLIT_L_Accept_a_patient"),
                    levels : [true,true,false]
                },
                {
                    text : $A.get("$Label.c.DLIT_L_Update_status_of_an_accepted_patient"),
                    levels : [true,true,true]
                },
                {
                    text : $A.get("$Label.c.DLIT_L_View_Dashboard"),
                    levels : [true,true,true]
                },
                {
                    text : $A.get("$Label.c.DLIT_L_View_Export_Reports"),
                    levels : [true,true,true]
                },
            ];
            component.set("v.capList",capList);
        }
        else if(userMode === 'HCP'){
            var header = {
                text : $A.get("$Label.c.DLIT_L_PERMISSIONS_BY_LEVEL"),
                levels : ['1','2']
            };
            component.set("v.header",header);
            var capList = [
                {
                    text : $A.get("$Label.c.DLIT_L_Select_a_study_site_to_refer_to"),
                    levels : [true,false]
                },
                {
                    text : $A.get("$Label.c.DLIT_L_Refer_a_patient_to_a_study_site"),
                    levels : [true,false]
                },
                {
                    text : $A.get("$Label.c.DLIT_L_Pre_eligibility_screening"),
                    levels : [true,false]
                },
                {
                    text : $A.get("$Label.c.DLIT_L_Medical_Record_Review"),
                    levels : [true,true]
                },
                {
                    text : $A.get("$Label.c.DLIT_L_View_Dashboard"),
                    levels : [true,true]
                },
                {
                    text : $A.get("$Label.c.DLIT_L_View_Export_Reports"),
                    levels : [true,true]
                },
            ];
            component.set("v.capList",capList);
        }
    }
})