global without sharing class SiteCalendarController {
    private static final String CANCELLED = 'Cancelled';
    @AuraEnabled
    public static List<visitDataWrapperSort> recordsOfTeleAndInitialVisit(
        String filterData
    ) {
        try {
            List<visitDataWrapperSort> visitRecords = new List<visitDataWrapperSort>();
            Datetime currentDateTime = Datetime.now();
            Datetime next24HoursDateTime = Datetime.now().addHours(24);
            String boxVisitCSS = '';
            //Parse filter data
            filterWrapper filterDetails = (filterWrapper) JSON.deserialize(
                filterData,
                filterWrapper.class
            );
            DateTime startDate = Datetime.newInstance(filterDetails.calendarDate.year(), filterDetails.calendarDate.month(),filterDetails.calendarDate.day());
            DateTime endDate = Datetime.newInstance(filterDetails.calendarDate.year(), filterDetails.calendarDate.month(),filterDetails.calendarDate.day(),23,59,59);
            //Fetch Televisit data
            List<Televisit__c> televisitData = [
                SELECT
                Id,
                Title__c,
                Visit_Date__c,
                Visit_Date_Time__c,
                Start_Time__c,
                Visit_Link_Activation_Start_Time__c,
                Visit_Link_Activation_End_Time__c,
                Status__c,
                Meeting_URL__c,
                Participant_Enrollment__r.Participant_Name__c,
                Duration__c,
                Participant_Enrollment__r.Participant__r.First_Name__c,
                Participant_Enrollment__r.Participant__r.Last_Name__c,
                Participant_Enrollment__r.Participant_Surname__c,
                Participant_Enrollment__r.Name,
                Participant_Enrollment__r.study_Site__r.Clinical_Trial_Profile__c,
                Participant_Enrollment__r.study_Site__r.Banner_Display_Offset_Time__c,
                Participant_Enrollment__r.study_Site__r.Banner_Dispose_Offset_Time__c,
                (SELECT Id, User__c FROM Televisit_Attendee__r)
                FROM Televisit__c
                WHERE
                Visit_Date_Time__c >= :startDate 
                AND Visit_Date_Time__c <= :endDate
                AND Status__c != :CANCELLED
                AND Participant_Enrollment__r.Study_Site__c IN :filterDetails.studySite
                AND Participant_Enrollment__r.Clinical_Trial_Profile__c IN :filterDetails.study          
                ORDER BY Visit_Date_Time__c DESC
            ];
            
            for (Televisit__c visitData : televisitData) {
                string visitTime = timeFormatForVisits(visitData.Start_Time__c);
                Boolean isJoin = isJoinEnabled(visitData);
                if (isJoin) {
                    boxVisitCSS = 'box-visit-screen join-btn-bg';
                } else {
                    boxVisitCSS = 'box-visit-screen';
                }
                String participantName = visitData.Participant_Enrollment__r.Participant__r.Last_Name__c;
                if (
                    String.isNotBlank(
                        visitData.Participant_Enrollment__r.Participant__r.First_Name__c
                    )
                ) {
                    participantName +=
                        ', ' +
                        visitData.Participant_Enrollment__r.Participant__r.First_Name__c;
                }
                string completeName =
                    visitData.Participant_Enrollment__r.Participant_Name__c +
                    ' ' +
                    visitData.Participant_Enrollment__r.Participant_Surname__c;
                TimeZone tz = UserInfo.getTimeZone();
                DateTime StartTime =visitData.Visit_Date_Time__c.AddSeconds(tz.getOffset(visitData.Visit_Date_Time__c)/1000);
                String RefIdNumberToSort =  visitData.Participant_Enrollment__r.Name;
                RefIdNumberToSort = RefIdNumberToSort.replaceAll('[REF]', '');
                visitRecords.add(
                    new visitDataWrapperSort(
                        boxVisitCSS,
                        visitData.Id,
                        visitData.Title__c,
                        participantName,
                        visitTime,
                        visitData.Duration__c,
                        visitData.Participant_Enrollment__r.Name,
                        completeName,
                        isJoin,
                        visitData.Meeting_URL__c,
                        visitData.Visit_Date_Time__c,
                        StartTime,
                        Integer.valueof(RefIdNumberToSort)
                    )
                );
                visitRecords.sort();
            }
            //Fetch Initial Visit data
            List<Participant_Enrollment__c> initialVisitData = [
                SELECT
                Id,
                Name,
                Participant_Surname__c,
                Participant_Name__c,
                Initial_visit_scheduled_date__c,
                Initial_visit_scheduled_flag__c,
                Initial_visit_scheduled_time__c,
                Participant__r.First_Name__c,
                Participant__r.Last_Name__c,
                Participant_Status_Last_Changed_Date__c
                FROM Participant_Enrollment__c
                WHERE
                Study_Site__c IN :filterDetails.studySite
                AND Study_Site__r.Clinical_Trial_Profile__c IN :filterDetails.study
                AND Initial_visit_scheduled_date__c = :filterDetails.calendarDate
                ORDER BY Initial_visit_scheduled_date__c DESC
            ];
            
            for (Participant_Enrollment__c visitData : initialVisitData) {
                string visitTime = timeFormatForVisits(
                    visitData.Initial_visit_scheduled_time__c
                );
                boxVisitCSS = 'box-visit-screen';
                string completeName =
                    visitData.Participant_Name__c +
                    ' ' +
                    visitData.Participant_Surname__c;
                String participantName = visitData.Participant__r.Last_Name__c;
                if (String.isNotBlank(visitData.Participant__r.First_Name__c)) {
                    participantName += ', ' + visitData.Participant__r.First_Name__c;
                }
                TimeZone tz = UserInfo.getTimeZone();
                DateTime dt = DateTime.newInstance(visitData.Initial_visit_scheduled_date__c, visitData.Initial_visit_scheduled_time__c);
                DateTime StartTime =dt.AddSeconds(tz.getOffset(dt)/1000);
                String RefIdNumberToSort =  visitData.Name;
                RefIdNumberToSort = RefIdNumberToSort.replaceAll('[REF]', '');
                visitRecords.add(
                    new visitDataWrapperSort(
                        boxVisitCSS,
                        visitData.Id,
                        System.Label.Pre_Enrollment_Visit_Plan,
                        participantName,
                        visitTime,
                        null,
                        visitData.Name,
                        completeName,
                        false,
                        '',
                        visitData.Initial_visit_scheduled_date__c,
                        StartTime,
                        Integer.valueof(RefIdNumberToSort)
                    )
                );
                visitRecords.sort();
            }
            return visitRecords;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static string timeFormatForVisits(time visitTime) {
        string visitTimeFormat;
        if (visitTime != null) {
            string timestring = string.valueOf(visitTime);
            List<string> timeList = new List<string>();
            for (string s : timestring.split(':')) {
                timeList.add(s);
            }
            String formattedTime = '';
            if (integer.valueOf(timeList[0]) <= 12) {
                formattedTime = timeList[0];
            } else {
                formattedTime = (String.valueOf(integer.valueOf(timeList[0]) - 12))
                    .leftPad(2, '0');
            }
            formattedTime = formattedTime + ':' + timeList[1];
            if (integer.valueOf(timeList[0]) < 12) {
                formattedTime = formattedTime + ' AM';
            } else {
                formattedTime = formattedTime + ' PM';
            }
            visitTimeFormat = formattedTime;
        }
        return visitTimeFormat;
    }
    
    public static Boolean isJoinEnabled(Televisit__c tvisit) {
        Id userId = UserInfo.getUserId();
        Boolean isJoin = false;
        Map<Id, Televisit__c> televistMap = new Map<Id, Televisit__c>();
        for (Televisit_Attendee__c tattendee : tvisit.Televisit_Attendee__r) {
            if (tattendee.User__c == userId) {
                if (
                    system.now() >= tvisit.Visit_Link_Activation_Start_Time__c &&
                    system.now() < tvisit.Visit_Link_Activation_End_Time__c
                ) {
                    isJoin = true;
                }
            }
        }
        return isJoin;
    }
    
    global class visitDataWrapperSort implements Comparable 
    {
        @AuraEnabled
        public string boxVisitCSS { get; set; }
        @AuraEnabled
        public string visitId { get; set; }
        @AuraEnabled
        public string visitTitle { get; set; }
        @AuraEnabled
        public string participantName { get; set; }
        @AuraEnabled
        public string visitTime { get; set; }
        @AuraEnabled
        public string durationTime { get; set; }
        @AuraEnabled
        public string refIdName { get; set; }
        @AuraEnabled
        public string fullName { get; set; }
        @AuraEnabled
        public Boolean isJoin { get; set; }
        @AuraEnabled
        public String meetingURL { get; set; }
        @AuraEnabled
        public Datetime visitDateTime {get; set;}
        @AuraEnabled
        public Datetime visitDateTimeToSort {get; set;}
        @AuraEnabled
        public Integer RefIdNumberToSort {get; set;}
        
        public visitDataWrapperSort(
            String boxVisitCSS,
            String visitId,
            String visitTitle,
            String participantName,
            String visitTime,
            String durationTime,
            String refIdName,
            String fullName,
            Boolean isJoin,
            String meetingURL,
            DateTime visitDateTime,
            Datetime visitDateTimeToSort,
            Integer RefIdNumberToSort
        ) {
            this.boxVisitCSS = boxVisitCSS;
            this.visitId = visitId;
            this.visitTitle = visitTitle;
            this.participantName = participantName;
            this.visitTime = visitTime;
            this.durationTime = durationTime;
            this.refIdName = refIdName;
            this.fullName = fullName;
            this.isJoin = isJoin;
            this.meetingURL = meetingURL;
            this.visitDateTime = visitDateTime;
            this.visitDateTimeToSort = visitDateTimeToSort;
            this.RefIdNumberToSort = RefIdNumberToSort;
        }
        global Integer compareTo(Object ObjToCompare) {
            Integer returnValue;
            if (this.visitDateTimeToSort >((visitDataWrapperSort)ObjToCompare).visitDateTimeToSort) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (this.visitDateTimeToSort <((visitDataWrapperSort)ObjToCompare).visitDateTimeToSort) {
                // Set return value to a negative value.
                returnValue = -1;
            }else if (this.visitDateTimeToSort ==((visitDataWrapperSort)ObjToCompare).visitDateTimeToSort) {
                // Set return value to a negative value.
                if (this.participantName >((visitDataWrapperSort)ObjToCompare).participantName) {
                    // Set return value to a positive value.
                    returnValue = 1;
                } else if (this.participantName <((visitDataWrapperSort)ObjToCompare).participantName) {
                    // Set return value to a negative value.
                    returnValue = -1;
                }else if (this.participantName ==((visitDataWrapperSort)ObjToCompare).participantName) {
                    // Set return value to a negative value.
                    if (this.RefIdNumberToSort >((visitDataWrapperSort)ObjToCompare).RefIdNumberToSort) {
                        // Set return value to a positive value.
                        returnValue = 1;
                    } else if (this.RefIdNumberToSort <((visitDataWrapperSort)ObjToCompare).RefIdNumberToSort) {
                        // Set return value to a negative value.
                        returnValue = -1;
                    }else if (this.RefIdNumberToSort ==((visitDataWrapperSort)ObjToCompare).RefIdNumberToSort) {
                        // Set return value to a negative value.
                        returnValue = 0;
                    }
                }
            }
            return returnValue;
        }
    }
    
    public class filterWrapper {
        @AuraEnabled
        public Date calendarDate;
        @AuraEnabled
        public List<String> study;
        @AuraEnabled
        public List<String> studySite;
    }
}