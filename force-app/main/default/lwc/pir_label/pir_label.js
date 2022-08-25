import { LightningElement } from 'lwc';
import Received from '@salesforce/label/c.Received';
import PWS_Contact_Name from '@salesforce/label/c.PWS_Contact_Name';
import PWS_Initial_Visit_Name from '@salesforce/label/c.PWS_Initial_Visit_Name';
import PWS_Eligibility_Name from '@salesforce/label/c.PWS_Eligibility_Name';
import PWS_Screening_Name from '@salesforce/label/c.PWS_Screening_Name';
import PWS_Enrolled_Card_Name from '@salesforce/label/c.PWS_Enrolled_Card_Name';
import PWS_Randomization_Card_Name from '@salesforce/label/c.PWS_Randomization_Card_Name';
import Contact_Attempted from '@salesforce/label/c.Contact_Attempted';
import Pre_review_Passed from '@salesforce/label/c.Pre_review_Passed';
import Pre_review_Failed from '@salesforce/label/c.Pre_review_Failed';
import PWS_Contact_Outcome_Placeholder from '@salesforce/label/c.PWS_Contact_Outcome_Placeholder';
import Contacted_Not_Suitable from '@salesforce/label/c.Contacted_Not_Suitable';
import Successfully_Contacted from '@salesforce/label/c.Successfully_Contacted';
import Successfully_Re_Engaged from '@salesforce/label/c.Successfully_Re_Engaged';
import Unable_to_Reach from '@salesforce/label/c.Unable_to_Reach';
import Eligibility_Passed from '@salesforce/label/c.Eligibility_Passed';
import Eligibility_Failed from '@salesforce/label/c.Eligibility_Failed';
import Ready_to_Screen from '@salesforce/label/c.Ready_to_Screen';
import Screening_In_Progress from '@salesforce/label/c.Screening_In_Progress';
import In_Wash_Out_Period from '@salesforce/label/c.In_Wash_Out_Period';
import Screening_Failed from '@salesforce/label/c.Screening_Failed';
import Unable_to_Screen from '@salesforce/label/c.Unable_to_Screen';
import Withdrew_Consent from '@salesforce/label/c.Withdrew_Consent';
import Declined_Consent from '@salesforce/label/c.Declined_Consent';
import Screening_Passed from '@salesforce/label/c.Screening_Passed';
import Enrollment_Success from '@salesforce/label/c.Enrollment_Success';
import Enrollment_Failed from '@salesforce/label/c.Enrollment_Failed';
import Withdrew_Consent_After_Screening from '@salesforce/label/c.Withdrew_Consent_After_Screening';
import Declined_Final_Consent from '@salesforce/label/c.Declined_Final_Consent';
import Randomization_Failed from '@salesforce/label/c.Randomization_Failed';
import Randomization_Success from '@salesforce/label/c.Randomization_Success';
import PWS_On from '@salesforce/label/c.PWS_On';
import PWS_From from '@salesforce/label/c.PWS_From';
import PG_IMI_L_by_user from '@salesforce/label/c.PG_IMI_L_by_user';
import None from '@salesforce/label/c.None';
import PE_Status_History_On_Date from '@salesforce/label/c.PE_Status_History_On_Date';
import PWS_Contact_History_Title from '@salesforce/label/c.PWS_Contact_History_Title';
import PWS_Initial_Visit_History_Title from '@salesforce/label/c.PWS_Initial_Visit_History_Title';
import PWS_Eligibility_History_Title from '@salesforce/label/c.PWS_Eligibility_History_Title';
import PWS_Screening_History_Title from '@salesforce/label/c.PWS_Screening_History_Title';
import PWS_Randomization_History_Title from '@salesforce/label/c.PWS_Randomization_History_Title';
import PWS_Enrolled_History_Title from '@salesforce/label/c.PWS_Enrolled_History_Title';
import PWS_Randomization_No_Outcome from '@salesforce/label/c.PWS_Randomization_No_Outcome';
import PWS_Contact_No_Outcome from '@salesforce/label/c.PWS_Contact_No_Outcome';
import PWS_Screening_No_Outcome from '@salesforce/label/c.PWS_Screening_No_Outcome';
import PWS_Enrolled_No_Outcome from '@salesforce/label/c.PWS_Enrolled_No_Outcome';
import PWS_Eligibility_No_Outcome from '@salesforce/label/c.PWS_Eligibility_No_Outcome';
import pir_Received_History from '@salesforce/label/c.pir_Received_History';
import PWS_Received_Card_Name from '@salesforce/label/c.PWS_Received_Card_Name';
import PWS_Contact_Card_Name from '@salesforce/label/c.PWS_Contact_Card_Name';
import PWS_Initial_Visit_Card_Name from '@salesforce/label/c.PWS_Initial_Visit_Card_Name';
import PWS_Eligibility_Card_Name from '@salesforce/label/c.PWS_Eligibility_Card_Name';
import PWS_Screening_Card_Name from '@salesforce/label/c.PWS_Screening_Card_Name';
import RH_And from '@salesforce/label/c.RH_And';
import Initial_Visit_Scheduled_Date_and_Time from '@salesforce/label/c.Initial_Visit_Scheduled_Date_and_Time';
import RH_Proceed_to_tab from '@salesforce/label/c.RH_Proceed_to_tab';
import SitePreference from '@salesforce/label/c.SitePreference';
import PIR_Left_a_Message from '@salesforce/label/c.PIR_Left_a_Message';
import PIR_Transportation_Issues from '@salesforce/label/c.PIR_Transportation_Issues';
import PIR_Childcare_Issues from '@salesforce/label/c.PIR_Childcare_Issues';
import PIR_Participant_Not_Interested from '@salesforce/label/c.PIR_Participant_Not_Interested';
import PIR_PI_Decision from '@salesforce/label/c.PIR_PI_Decision';
import PIR_Other from '@salesforce/label/c.PIR_Other';
import PIR_Protocol_Concerns from '@salesforce/label/c.PIR_Protocol_Concerns';
import PIR_Didnt_Meet_Pre_Screening_Eligibility from '@salesforce/label/c.PIR_Didnt_Meet_Pre_Screening_Eligibility';
import PIR_Visit_Out_Of_Window from '@salesforce/label/c.PIR_Visit_Out_Of_Window';
import PIR_Inadequate_Documentation from '@salesforce/label/c.PIR_Inadequate_Documentation';
import PIR_Does_Not_Meet_Eligibility_Criteria from '@salesforce/label/c.PIR_Does_Not_Meet_Eligibility_Criteria';
import PIR_Not_Ready_to_Schedule from '@salesforce/label/c.PIR_Not_Ready_to_Schedule';
import PIR_Call_Back from '@salesforce/label/c.PIR_Call_Back';
import PWS_Received_Name from '@salesforce/label/c.PWS_Received_Name';
import PG_ACPE_L_Outcome from '@salesforce/label/c.PG_ACPE_L_Outcome';
import PG_ACPE_L_Reason from '@salesforce/label/c.PG_ACPE_L_Reason';
import FD_PE_Field_Initial_Visit_Scheduled_Date from '@salesforce/label/c.FD_PE_Field_Initial_Visit_Scheduled_Date';
import FD_PE_Field_Initial_Visit_Scheduled_Time from '@salesforce/label/c.FD_PE_Field_Initial_Visit_Scheduled_Time';
import FD_PE_Field_Initial_Visit_Attended from '@salesforce/label/c.FD_PE_Field_Initial_Visit_Attended';
import FD_PE_Field_Initial_Visit_Attended_Date from '@salesforce/label/c.FD_PE_Field_Initial_Visit_Attended_Date';
import FD_PE_Field_Informed_Consent_Signed from '@salesforce/label/c.FD_PE_Field_Informed_Consent_Signed';
import FD_PE_Field_Informed_Consent_Signed_Date from '@salesforce/label/c.FD_PE_Field_Informed_Consent_Signed_Date';
import FD_PE_Field_Wash_Out_Required from '@salesforce/label/c.FD_PE_Field_Wash_Out_Required';
import FD_PE_Field_Revisit_Date from '@salesforce/label/c.FD_PE_Field_Revisit_Date';
import PG_AP_F_Screening_Subject_Id from '@salesforce/label/c.PG_AP_F_Screening_Subject_Id';
import FG_PE_Inf_Consent from '@salesforce/label/c.FG_PE_Inf_Consent';
import FG_PE_Wash_Out from '@salesforce/label/c.FG_PE_Wash_Out';
import PE_Randomization_ID from '@salesforce/label/c.PE_Randomization_ID';
import PE_Enrollment_ID from '@salesforce/label/c.PE_Enrollment_ID';
import PIR_Declined_Practitioner from '@salesforce/label/c.PIR_Declined_Practitioner';
import FD_PE_Field_Final_Consent from '@salesforce/label/c.FD_PE_Field_Final_Consent';
import PIR_Did_Not_Meet_Inclusion_Exclusion_Criteria from '@salesforce/label/c.PIR_Did_Not_Meet_Inclusion_Exclusion_Criteria';
import PIR_Did_Not_Attend_Appointment from '@salesforce/label/c.PIR_Did_Not_Attend_Appointment';
import PG_ACPE_L_Notes_Required from '@salesforce/label/c.PG_ACPE_L_Notes_Required';
import PG_ACPE_L_Notes_Optional from '@salesforce/label/c.PG_ACPE_L_Notes_Optional';
import BTN_Yes from '@salesforce/label/c.BTN_Yes';
import FD_PE_Field_Arm_Cohort from '@salesforce/label/c.FD_PE_Field_Arm_Cohort';
import RH_ParticipantNoshow from '@salesforce/label/c.RH_ParticipantNoshow';
import Cancel_Scheduled_Visit from '@salesforce/label/c.Cancel_Scheduled_Visit';
import CancelfovWarning from '@salesforce/label/c.CancelfovWarning';
import CancelfovWarnings from '@salesforce/label/c.CancelfovWarnings';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';
import Proceed from '@salesforce/label/c.Proceed';
import PIR_In_Wash_Out_Period from '@salesforce/label/c.PIR_In_Wash_Out_Period';
import PIR_Declined from '@salesforce/label/c.PIR_Declined';
import PWS_Picklist_Value_Withdrew from '@salesforce/label/c.PWS_Picklist_Value_Withdrew';
import PWS_Picklist_Value_Childcare_Issues from '@salesforce/label/c.PWS_Picklist_Value_Childcare_Issues';
import PWS_Picklist_Value_Other from '@salesforce/label/c.PWS_Picklist_Value_Other';
import PWS_Picklist_Value_Participant_Not_Interested from '@salesforce/label/c.PWS_Picklist_Value_Participant_Not_Interested';
import PWS_Picklist_Value_Transportation_Issues from '@salesforce/label/c.PWS_Picklist_Value_Transportation_Issues';
import PWS_Picklist_Value_Protocol_Concerns from '@salesforce/label/c.PWS_Picklist_Value_Protocol_Concerns';
import PE_STATUS_ENROLLMENT_SUCCESS from '@salesforce/label/c.PE_STATUS_ENROLLMENT_SUCCESS';
import BTN_Participant_Information from '@salesforce/label/c.BTN_Participant_Information';
import PG_Ref_L_Participant_require_invitation from '@salesforce/label/c.PG_Ref_L_Participant_require_invitation';
import PG_EMN_MSG_Update_Participant_Info from '@salesforce/label/c.PG_EMN_MSG_Update_Participant_Info';
import PG_AS_F_First_name from '@salesforce/label/c.PG_AS_F_First_name';
import PG_AS_F_Middle_name from '@salesforce/label/c.PG_AS_F_Middle_name';
import PG_AS_F_Last_name from '@salesforce/label/c.PG_AS_F_Last_name';
import PG_AS_F_Suffix from '@salesforce/label/c.PG_AS_F_Suffix';
import PG_AS_F_Nickname from '@salesforce/label/c.PG_AS_F_Nickname';
import PG_AS_F_Date_of_Birth from '@salesforce/label/c.PG_AS_F_Date_of_Birth';
import PG_AS_F_Gender from '@salesforce/label/c.PG_AS_F_Gender';
import PG_EMN_MSG_Update_Contact_Info from '@salesforce/label/c.PG_EMN_MSG_Update_Contact_Info';
import PG_Ref_L_Primary_daytime_telephone_number from '@salesforce/label/c.PG_Ref_L_Primary_daytime_telephone_number';
import PG_AP_F_Phone_Type from '@salesforce/label/c.PG_AP_F_Phone_Type';
import PG_AS_F_Email_address from '@salesforce/label/c.PG_AS_F_Email_address';
import PE_Country from '@salesforce/label/c.PE_Country';
import PE_State from '@salesforce/label/c.PE_State';
import PG_AS_F_Zip_Postal_Code from '@salesforce/label/c.PG_AS_F_Zip_Postal_Code';
import PG_AP_F_Alternative_Phone_Number from '@salesforce/label/c.PG_AP_F_Alternative_Phone_Number';
import PG_AP_F_Alternative_Phone_Type from '@salesforce/label/c.PG_AP_F_Alternative_Phone_Type';
import SS_Confirm_and_Manage from '@salesforce/label/c.SS_Confirm_and_Manage';
import BTN_Invite from '@salesforce/label/c.BTN_Invite';
import Do_Not_Invite from '@salesforce/label/c.Do_Not_Invite';
import PP_Participant from '@salesforce/label/c.PP_Participant';
import PP_Delegate from '@salesforce/label/c.PP_Delegate';
import PP_Provider_Access from '@salesforce/label/c.PP_Provider_Access';
import PP_Review_and_Confirm from '@salesforce/label/c.PP_Review_and_Confirm';
import PG_AP_H_Patient_Details from '@salesforce/label/c.PG_AP_H_Patient_Details';
import PG_AP_H_Patient_Contact_Information from '@salesforce/label/c.PG_AP_H_Patient_Contact_Information';
import PG_L_Name from '@salesforce/label/c.PG_L_Name';
import PE_Phone_number from '@salesforce/label/c.PE_Phone_number';
import RP_DOB_label from '@salesforce/label/c.RP_DOB_label';
import PG_Ref_L_Delegate_Information from '@salesforce/label/c.PG_Ref_L_Delegate_Information';
import PG_Ref_L_Delegate_ensure_info_uptodate from '@salesforce/label/c.PG_Ref_L_Delegate_ensure_info_uptodate';
import PG_AS_F_Phone_Type from '@salesforce/label/c.PG_AS_F_Phone_Type';
import PG_Ref_L_Delegate_continue_be_delegate from '@salesforce/label/c.PG_Ref_L_Delegate_continue_be_delegate';
import Continue from '@salesforce/label/c.Continue';
import Do_Not_Continue from '@salesforce/label/c.Do_Not_Continue';
import PG_Ref_L_Participant_require_optional_email from '@salesforce/label/c.PG_Ref_L_Participant_require_optional_email';
import PG_Ref_L_Participant_require_agree from '@salesforce/label/c.PG_Ref_L_Participant_require_agree';
import Add_Delegate from '@salesforce/label/c.Add_Delegate';
import HealthCare_Provider_Stop_Sharing from '@salesforce/label/c.HealthCare_Provider_Stop_Sharing';
import HealthCare_Provider_Connect from '@salesforce/label/c.HealthCare_Provider_Connect';
import BTN_HealthCare_Provider_Information from '@salesforce/label/c.BTN_HealthCare_Provider_Information';
import BTN_Participant_Would_Like_Share_Info from '@salesforce/label/c.BTN_Participant_Would_Like_Share_Info';
import BTN_Add_Provider from '@salesforce/label/c.BTN_Add_Provider';
import BTN_Save from '@salesforce/label/c.BTN_Save';
import BTN_Next from '@salesforce/label/c.BTN_Next';
import BTN_Back from '@salesforce/label/c.BTN_Back';
import Participant_No_Show from '@salesforce/label/c.Participant_No_Show';


    const label = {
        Received: Received,
        PWS_Received_Name:PWS_Received_Name,
        PWS_Contact_Name: PWS_Contact_Name,
        PWS_Initial_Visit_Name: PWS_Initial_Visit_Name,
        PWS_Eligibility_Name: PWS_Eligibility_Name,
        PWS_Screening_Name: PWS_Screening_Name,
        PWS_Enrolled_Card_Name : PWS_Enrolled_Card_Name,
        PWS_Randomization_Card_Name : PWS_Randomization_Card_Name,
        Contact_Attempted : Contact_Attempted,
        Pre_review_Passed : Pre_review_Passed,
        Pre_review_Failed :Pre_review_Failed,
        PWS_Contact_Outcome_Placeholder:PWS_Contact_Outcome_Placeholder,
        Contacted_Not_Suitable:Contacted_Not_Suitable,
        Successfully_Contacted:Successfully_Contacted,
        Successfully_Re_Engaged:Successfully_Re_Engaged,
        Unable_to_Reach:Unable_to_Reach,
        Eligibility_Passed:Eligibility_Passed,
        Eligibility_Failed:Eligibility_Failed,
        Ready_to_Screen:Ready_to_Screen,
        Screening_In_Progress:Screening_In_Progress,
        In_Wash_Out_Period:In_Wash_Out_Period,
        Screening_Failed:Screening_Failed,
        Unable_to_Screen:Unable_to_Screen,
        Withdrew_Consent:Withdrew_Consent,
        Declined_Consent:Declined_Consent,
        Screening_Passed:Screening_Passed,
        Enrollment_Success:Enrollment_Success,
        Enrollment_Failed:Enrollment_Failed,
        Withdrew_Consent_After_Screening:Withdrew_Consent_After_Screening,
        Declined_Final_Consent:Declined_Final_Consent,
        Randomization_Failed:Randomization_Failed,
        Randomization_Success:Randomization_Success,
        PWS_On:PWS_On,
        PWS_From:PWS_From,
        PG_IMI_L_by_user:PG_IMI_L_by_user,
        None:None,
        PE_Status_History_On_Date:PE_Status_History_On_Date,
        PWS_Contact_History_Title:PWS_Contact_History_Title,
        PWS_Initial_Visit_History_Title:PWS_Initial_Visit_History_Title,
        PWS_Eligibility_History_Title:PWS_Eligibility_History_Title,
        PWS_Screening_History_Title:PWS_Screening_History_Title,
        PWS_Randomization_History_Title:PWS_Randomization_History_Title,
        PWS_Enrolled_History_Title:PWS_Enrolled_History_Title,
        PWS_Randomization_No_Outcome:PWS_Randomization_No_Outcome,
        PWS_Contact_No_Outcome:PWS_Contact_No_Outcome,
        PWS_Screening_No_Outcome:PWS_Screening_No_Outcome,
        PWS_Enrolled_No_Outcome:PWS_Enrolled_No_Outcome,
        PWS_Eligibility_No_Outcome:PWS_Eligibility_No_Outcome,
        pir_Received_History:pir_Received_History,
        PWS_Received_Card_Name:PWS_Received_Card_Name,
        PWS_Contact_Card_Name:PWS_Contact_Card_Name,
        PWS_Initial_Visit_Card_Name:PWS_Initial_Visit_Card_Name,
        PWS_Eligibility_Card_Name:PWS_Eligibility_Card_Name,
        PWS_Screening_Card_Name:PWS_Screening_Card_Name,
        RH_And:RH_And,
        Initial_Visit_Scheduled_Date_and_Time:Initial_Visit_Scheduled_Date_and_Time,
        RH_Proceed_to_tab:RH_Proceed_to_tab,
        SitePreference:SitePreference,
        PIR_Left_a_Message:PIR_Left_a_Message,
        PIR_Transportation_Issues:PIR_Transportation_Issues,
        PIR_Childcare_Issues:PIR_Childcare_Issues,
        PIR_Participant_Not_Interested:PIR_Participant_Not_Interested,
        PIR_PI_Decision:PIR_PI_Decision,
        PIR_Other:PIR_Other,
        PIR_Protocol_Concerns:PIR_Protocol_Concerns,
        PIR_Didnt_Meet_Pre_Screening_Eligibility:PIR_Didnt_Meet_Pre_Screening_Eligibility,
        PIR_Visit_Out_Of_Window:PIR_Visit_Out_Of_Window,
        PIR_Inadequate_Documentation:PIR_Inadequate_Documentation,
        PIR_Does_Not_Meet_Eligibility_Criteria:PIR_Does_Not_Meet_Eligibility_Criteria,
        PIR_Not_Ready_to_Schedule:PIR_Not_Ready_to_Schedule,
        PIR_Call_Back:PIR_Call_Back,
        PG_ACPE_L_Outcome:PG_ACPE_L_Outcome,
        PG_ACPE_L_Reason:PG_ACPE_L_Reason,
        FD_PE_Field_Initial_Visit_Scheduled_Date:FD_PE_Field_Initial_Visit_Scheduled_Date,
        FD_PE_Field_Initial_Visit_Scheduled_Time:FD_PE_Field_Initial_Visit_Scheduled_Time,
        FD_PE_Field_Initial_Visit_Attended:FD_PE_Field_Initial_Visit_Attended,
        FD_PE_Field_Initial_Visit_Attended_Date:FD_PE_Field_Initial_Visit_Attended_Date,
        FD_PE_Field_Informed_Consent_Signed:FD_PE_Field_Informed_Consent_Signed,
        FD_PE_Field_Informed_Consent_Signed_Date:FD_PE_Field_Informed_Consent_Signed_Date,
        FD_PE_Field_Wash_Out_Required:FD_PE_Field_Wash_Out_Required,
        FD_PE_Field_Revisit_Date:FD_PE_Field_Revisit_Date,
        PG_AP_F_Screening_Subject_Id:PG_AP_F_Screening_Subject_Id,
        FG_PE_Inf_Consent:FG_PE_Inf_Consent,
        FG_PE_Wash_Out:FG_PE_Wash_Out,
        PE_Randomization_ID:PE_Randomization_ID,
        PE_Enrollment_ID:PE_Enrollment_ID,
        PIR_Declined_Practitioner:PIR_Declined_Practitioner,
        FD_PE_Field_Final_Consent:FD_PE_Field_Final_Consent,
        PIR_Did_Not_Meet_Inclusion_Exclusion_Criteria:PIR_Did_Not_Meet_Inclusion_Exclusion_Criteria,
        PIR_Did_Not_Attend_Appointment:PIR_Did_Not_Attend_Appointment,
        PG_ACPE_L_Notes_Required:PG_ACPE_L_Notes_Required,
        PG_ACPE_L_Notes_Optional:PG_ACPE_L_Notes_Optional,
        BTN_Yes:BTN_Yes,
        FD_PE_Field_Arm_Cohort:FD_PE_Field_Arm_Cohort,
        RH_ParticipantNoshow:RH_ParticipantNoshow,
        Cancel_Scheduled_Visit:Cancel_Scheduled_Visit,
        CancelfovWarning:CancelfovWarning,
        CancelfovWarnings:CancelfovWarnings,
        BTN_Cancel:BTN_Cancel,
        Proceed:Proceed,
        PIR_In_Wash_Out_Period:PIR_In_Wash_Out_Period,
        PIR_Declined:PIR_Declined,
        PWS_Picklist_Value_Withdrew:PWS_Picklist_Value_Withdrew,
        PWS_Picklist_Value_Childcare_Issues:PWS_Picklist_Value_Childcare_Issues,
        PWS_Picklist_Value_Other:PWS_Picklist_Value_Other,
        PWS_Picklist_Value_Participant_Not_Interested:PWS_Picklist_Value_Participant_Not_Interested,
        PWS_Picklist_Value_Transportation_Issues:PWS_Picklist_Value_Transportation_Issues,
        PWS_Picklist_Value_Protocol_Concerns:PWS_Picklist_Value_Protocol_Concerns,
        PE_STATUS_ENROLLMENT_SUCCESS:PE_STATUS_ENROLLMENT_SUCCESS,
        BTN_Participant_Information:BTN_Participant_Information,
        PG_Ref_L_Participant_require_invitation:PG_Ref_L_Participant_require_invitation,
        PG_EMN_MSG_Update_Participant_Info:PG_EMN_MSG_Update_Participant_Info,
        PG_AS_F_First_name:PG_AS_F_First_name,
        PG_AS_F_Middle_name:PG_AS_F_Middle_name,
        PG_AS_F_Last_name:PG_AS_F_Last_name,
        PG_AS_F_Suffix:PG_AS_F_Suffix,
        PG_AS_F_Nickname:PG_AS_F_Nickname,
        PG_AS_F_Date_of_Birth:PG_AS_F_Date_of_Birth,
        PG_AS_F_Gender:PG_AS_F_Gender,
        PG_EMN_MSG_Update_Contact_Info:PG_EMN_MSG_Update_Contact_Info,
        PG_Ref_L_Primary_daytime_telephone_number:PG_Ref_L_Primary_daytime_telephone_number,
        PG_AP_F_Phone_Type:PG_AP_F_Phone_Type,
        PG_AS_F_Email_address:PG_AS_F_Email_address,
        PE_Country:PE_Country,
        PE_State:PE_State,
        PG_AS_F_Zip_Postal_Code:PG_AS_F_Zip_Postal_Code,
        PG_AP_F_Alternative_Phone_Number:PG_AP_F_Alternative_Phone_Number,
        PG_AP_F_Alternative_Phone_Type:PG_AP_F_Alternative_Phone_Type,
        SS_Confirm_and_Manage:SS_Confirm_and_Manage,
        BTN_Invite:BTN_Invite,
        Do_Not_Invite:Do_Not_Invite,
        PP_Participant:PP_Participant,
        PP_Delegate:PP_Delegate,
        PP_Provider_Access:PP_Provider_Access,
        PP_Review_and_Confirm:PP_Review_and_Confirm,
        PG_AP_H_Patient_Details:PG_AP_H_Patient_Details,
        PG_AP_H_Patient_Contact_Information:PG_AP_H_Patient_Contact_Information,
        PG_L_Name:PG_L_Name,
        PE_Phone_number:PE_Phone_number,
        RP_DOB_label:RP_DOB_label,
        PG_Ref_L_Delegate_Information:PG_Ref_L_Delegate_Information,
        PG_Ref_L_Delegate_ensure_info_uptodate:PG_Ref_L_Delegate_ensure_info_uptodate,
        PG_AS_F_Phone_Type:PG_AS_F_Phone_Type,
        PG_Ref_L_Delegate_continue_be_delegate:PG_Ref_L_Delegate_continue_be_delegate,
        Continue:Continue,
        Do_Not_Continue:Do_Not_Continue,
        PG_Ref_L_Participant_require_optional_email:PG_Ref_L_Participant_require_optional_email,
        PG_Ref_L_Participant_require_agree:PG_Ref_L_Participant_require_agree,
        Add_Delegate:Add_Delegate,
        HealthCare_Provider_Stop_Sharing:HealthCare_Provider_Stop_Sharing,
        HealthCare_Provider_Connect:HealthCare_Provider_Connect,
        BTN_HealthCare_Provider_Information:BTN_HealthCare_Provider_Information,
        BTN_Participant_Would_Like_Share_Info:BTN_Participant_Would_Like_Share_Info,
        BTN_Add_Provider:BTN_Add_Provider,
        BTN_Save:BTN_Save,
        BTN_Next:BTN_Next,
        BTN_Back:BTN_Back,
        Participant_No_Show:Participant_No_Show
    };
    export {label};