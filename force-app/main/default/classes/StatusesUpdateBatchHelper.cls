/**
 * Created by Andrii Kryvolap.
 */

global without sharing class StatusesUpdateBatchHelper {
    private static final Map<String, Map<String, String>> statusesMap = new Map<String, Map<String, String>>{
            'referral sent to pi' => new Map<String, String>{
                    '' => 'Received'
            },
            'referred'=> new Map<String, String>{
                    '' => 'Received'
            },
            'contact successful' => new Map<String, String>{
                    '' => 'Successfully Contacted'
            },
            'contact attempt in progress' => new Map<String, String>{
                    '' => 'Contact Attempted'
            },
            'contact failed' => new Map<String, String>{
                    '' => 'Unable to Reach'
            },
            'screening failed' => new Map<String, String>{
                    'didn’t show for appointment' => 'Unable to Screen'
            },
            'screening complete' => new Map<String, String>{
                    '' => 'Screening Passed'
            },
            'enrollment failed' => new Map<String, String>{
                    'failed inclusion/exclusion criteria' => 'Screening Failed'
            }
    };

    private static final Map<String, Map<String, String>> reasonsMap = new Map<String, Map<String, String>>{
            'screening failed' => new Map<String, String>{
                    'didn’t show for appointment' => 'Did Not Attend Appointment',
                    'other' => 'Other',
                    '' => 'Did Not Meet Inclusion/Exclusion Criteria'
            },
            'enrollment failed' => new Map<String, String>{
                    'didn’t sign consent' => 'Declined or Withdrew Consent',
                    'failed inclusion/exclusion criteria' => 'Did Not Meet Inclusion/Exclusion Criteria',
                    'patient declined' => 'Declined or Withdrew Consent',
                    'patient decision' => 'Declined or Withdrew Consent'
            }
    };

    private static String getUpdateFromMap(Map<String, Map<String, String>> updatesMap, String firstKey, String secondKey){
        if(!updatesMap.containsKey(firstKey)){
            return null;
        }
        else{
            Map<String, String> secondKeyMap = updatesMap.get(firstKey);
            if(secondKeyMap.containsKey(secondKey)){
                return secondKeyMap.get(secondKey);
            }
            else{
                return secondKeyMap.get('');
            }
        }
    }

    global static String getUpdatedStatus(String status, String reason){
        return getUpdateFromMap(statusesMap, status, reason);
    }

    global static String getUpdatedReason(String status, String reason){
        return getUpdateFromMap(reasonsMap, status, reason);
    }

}