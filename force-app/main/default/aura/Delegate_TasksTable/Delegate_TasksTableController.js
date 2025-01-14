/**
 * Created by Deeksha on 09.07.2020.
 */
({
    doInit: function (component, event, hepler) {
        var userMode = component.get('v.userMode');

        var header;
        var capList;
        switch (userMode) {
            case 'PI':
                header = {
                    text: $A.get('$Label.c.DLIT_L_PERMISSIONS_BY_LEVEL'),
                    levels: ['1', '2', '3']
                };
                component.set('v.header', header);
                capList = [
                    {
                        text: $A.get('$Label.c.DLIT_L_Manage_team_member'),
                        levels: [true, false, false]
                    },
                    {
                        text: $A.get('$Label.c.DLIT_L_Accept_a_referring_HCP'),
                        levels: [true, false, false]
                    },
                    {
                        text: $A.get('$Label.c.DLIT_L_Decline_or_place_on_hold_a_referring_HCP'),
                        levels: [true, false, false]
                    },
                    {
                        text: $A.get('$Label.c.Add_Patient_Delegate'),
                        levels: [true, false, false]
                    },
                    {
                        text: $A.get('$Label.c.DLIT_L_Add_a_participants_provider'),
                        levels: [true, false, false]
                    },
                    {
                        text: $A.get('$Label.c.DLIT_L_Reffer'),
                        levels: [true, false, false]
                    },
                    /*{
                        text : $A.get("$Label.c.DLIT_L_Accept_a_patient"),
                        levels : [true,true,false]
                    },*/
                    {
                        text: $A.get('$Label.c.DLIT_L_Pre_screen_a_participant'),
                        levels: [true, true, false]
                    },
                    {
                        text: $A.get('$Label.c.DLIT_L_View_screener_responses'),
                        levels: [true, true, true]
                    },
                    {
                        text: $A.get('$Label.c.DLIT_L_Update_status_of_an_accepted_patient'),
                        levels: [true, true, true]
                    },
                    {
                        text: $A.get('$Label.c.DLIT_L_Manage_study_site_details'),
                        levels: [true, true, true]
                    },
                    {
                        text: $A.get('$Label.c.DLIT_L_View_Export_Reports'),
                        levels: [true, true, true]
                    },
                    {
                        text: $A.get('$Label.c.DLIT_L_Remove_a_participants_provider'),
                        levels: [true, true, true]
                    }
                ];
                component.set('v.capList', capList);
                break;

            case 'HCP':
                header = {
                    text: $A.get('$Label.c.DLIT_L_PERMISSIONS_BY_LEVEL'),
                    levels: ['1', '2']
                };
                component.set('v.header', header);
                capList = [
                    {
                        text: $A.get('$Label.c.DLIT_L_Manage_team_member'),
                        levels: [true, false]
                    },

                    {
                        text: $A.get('$Label.c.DLIT_L_Select_new_study_to_refer_to'),
                        levels: [true, false]
                    },

                    {
                        text: $A.get('$Label.c.DLIT_L_Select_a_study_site_to_refer_to'),
                        levels: [true, false]
                    },
                    {
                        text: $A.get('$Label.c.DLIT_L_Refer_a_patient_to_a_study_site'),
                        levels: [true, false]
                    },
                    {
                        text: $A.get('$Label.c.DLIT_L_Pre_eligibility_screening'),
                        levels: [true, true]
                    },
                    // {
                    //     text : $A.get("$Label.c.DLIT_L_Medical_Record_Review"),
                    //     levels : [true,true]
                    // },
                    {
                        text: $A.get('$Label.c.DLIT_L_View_Export_Reports'),
                        levels: [true, true]
                    }
                ];
                component.set('v.capList', capList);
                break;

            default:
                //Participant
                var headerText;
                if (communityService.isDelegate())
                    headerText = $A.get('$Label.c.PG_PST_L_Delegate_Permitted');
                else headerText = $A.get('$Label.c.PG_PST_L_Delegates_Permitted_Actions');
                header = {
                    text: headerText,
                    levels: []
                };
                component.set('v.header', header);
                capList = [
                    {
                        text: $A.get('$Label.c.PG_PST_L_Delegates_Compl_Task_Behalf')
                    },
                    {
                        text: $A.get('$Label.c.PG_PST_L_Delegates_Receive_Emails')
                    },
                    {
                        text: $A.get('$Label.c.PG_PST_L_Delegates_See_Survey_Resp')
                    },
                    {
                        text: $A.get('$Label.c.PG_PST_L_Delegates_See_Lab_Result')
                    },
                    {
                        text: $A.get('$Label.c.PG_PST_L_Delegates_See_Vitals')
                    },
                    {
                        text: $A.get('$Label.c.PG_PST_L_Delegates_My_Measur')
                    }
                    //@krishna Kumar Mahto - Removed for story PEH-2234 - Start
                    /*,
                    {
                        text : $A.get('$Label.c.PG_PST_L_Delegates_AAddit_Item')
                    }*/
                    //@krishna Kumar Mahto - Removed for story PEH-2234 - end
                ];
                component.set('v.capList', capList);
        }
    },
    handleSectionToggle: function (component, event) {
        var openSections = event.getParam('openSections');
    },

    toggleSection: function (component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute('data-auraId');
        if (sectionAuraId === null) {
            sectionAuraId = 'tasksSection';
        }
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
         */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open');

        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if (sectionState == -1) {
            sectionDiv.setAttribute('class', 'slds-section slds-is-open');
        } else {
            sectionDiv.setAttribute('class', 'slds-section slds-is-close');
        }
    }
});
