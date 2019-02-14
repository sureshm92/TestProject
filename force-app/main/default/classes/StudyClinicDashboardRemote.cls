/**
 * Created by Leonid Bartenev
 */

public class StudyClinicDashboardRemote {
    
    class FunnelItem{
        String category;
        Integer value;
        List<SubTotalItem> subTotals;
    }
    
    class SubTotalItem{
        String label;
        Integer value;
        String state;
    }
    
    @AuraEnabled
    public static String getInitData(Id trialId, Id clinicId){
        try{
            
            String filter = ' AND Study_Site__r.Clinical_Trial_Profile__c = \'' + trialId + '\' AND HCP__R.HCP_Contact__r.AccountId=\'' + clinicId + '\'';
            List<Participant_Enrollment__c> allPEList = ParticipantEnrollmentService.getReferredPEList(CommunityService.USER_MODE_PI, filter);
            System.debug('RECORDS COUNT: ' + allPEList.size());
            List<Map<String, Integer>> countersList = new List<Map<String, Integer>>();
            for(Integer i = 0; i < PEStatusState.STATUS_STEPS_TABLE.size(); i++) countersList.add(new Map<String, Integer>());
    
            for(Participant_Enrollment__c pe : allPEList){
                PEStatusState statusState = PEStatusState.STATUSES_MAP.get(pe.Participant_Status__c);
                for(Integer i = 0; i < statusState.order; i ++){
                    String stateStr = PEStatusState.STATUS_STATE_SUCCESS;
                    if(i == statusState.order - 1) stateStr = statusState.state;
                    Map<String, Integer> counterMap = countersList[i];
                    Integer stateCount = counterMap.get(stateStr);
                    if(stateCount == null) stateCount = 0;
                    stateCount++;
                    counterMap.put(stateStr, stateCount);
                }
            }
    
            List<FunnelItem> funnelItems = new List<FunnelItem>();
            for(Integer i = 0; i < PEStatusState.STATUS_STEPS_TABLE.size(); i++){
                PEStatusState.StatusStep statusStep = PEStatusState.STATUS_STEPS_TABLE[i];
                FunnelItem funnelItem = new FunnelItem();
                funnelItem.category = statusStep.name;
                funnelItem.subTotals = new List<SubTotalItem>();
                Map<String, Integer> counterMap = countersList[i];
                Integer stepSummary = 0;
                for(String state : counterMap.keySet()) {
                    Integer value = counterMap.get(state);
                    if(value == null) value = 0;
                    stepSummary += value;
                    SubTotalItem subTotalItem = new SubTotalItem();
                    subTotalItem.label = statusStep.states.get(state);
                    subTotalItem.state = state;
                    subTotalItem.value = value;
                    funnelItem.subTotals.add(subTotalItem);
                }
                funnelItem.value = stepSummary;
                funnelItems.add(funnelItem);
            }
    
            return JSON.serialize(funnelItems);
            
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}