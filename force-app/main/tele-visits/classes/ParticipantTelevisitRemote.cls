public without sharing class ParticipantTelevisitRemote {
    @AuraEnabled
    public static televisitWrapper getParticipantTelevisits(List<Id> joinbuttonids){
        try {
            List<Televisit_Attendee__c> televisitattendeeList = [Select Televisit__r.Id, Televisit__r.Meeting_URL__c,Televisit__r.Title__c,Televisit__r.Status__c,Televisit__r.Duration__c,Televisit__r.Visit_Date_Time__c from Televisit_Attendee__c where User__c =:UserInfo.getUserId() order by Televisit__r.Visit_Date_Time__c desc];
            Set<Id> televisitIdSet = new Set<Id>();
            televisitWrapper  tw = new televisitWrapper();
            if(televisitattendeeList != null && !televisitattendeeList.isempty()){
                Map<id,upcomingTelevisits> upcomingTelevisitmap = new Map<id,upcomingTelevisits>();
                Map<id,pastTelevisits> pastTelevisitsmap = new Map<id,pastTelevisits>();
                for(Televisit_Attendee__c attendee:televisitattendeeList){
                    televisitIdSet.add(attendee.Televisit__r.Id);
                    if(attendee.Televisit__r.Status__c != 'Cancelled' && attendee.Televisit__r.Status__c != 'Completed' &&
                       attendee.Televisit__r.Visit_Date_Time__c.addminutes(integer.valueof(attendee.Televisit__r.Duration__c.split(' ')[0])) >= system.now()){
                        upcomingTelevisits upcomingTelevisit = new upcomingTelevisits();
                        upcomingTelevisit.televisitId = attendee.Televisit__r.Id;
                        upcomingTelevisit.title = attendee.Televisit__r.Title__c;
                        upcomingTelevisit.televisitdate = attendee.Televisit__r.Visit_Date_Time__c;
                        upcomingTelevisit.televisitduration = attendee.Televisit__r.Duration__c.split(' ')[0] + ' min';
                        upcomingTelevisit.televisitmettingurl = attendee.Televisit__r.Meeting_URL__c;
                        if(joinbuttonids.contains(attendee.Televisit__r.Id)){
                            upcomingTelevisit.showjoinbutton = true;
                        }else{
                            upcomingTelevisit.showjoinbutton = false;
                        }
                        upcomingTelevisitmap.put(attendee.Televisit__r.Id,upcomingTelevisit);
                    }else if(attendee.Televisit__r.Visit_Date_Time__c.addminutes(integer.valueof(attendee.Televisit__r.Duration__c.split(' ')[0])) < system.now() || 
                             attendee.Televisit__r.Status__c == 'Cancelled'){
                        pastTelevisits pastTelevisit = new pastTelevisits();
                        pastTelevisit.title = attendee.Televisit__r.Title__c;
                        pastTelevisit.televisitdate = attendee.Televisit__r.Visit_Date_Time__c;
                        pastTelevisit.televisitduration = attendee.Televisit__r.Duration__c;
                        pastTelevisit.televisitId = attendee.Televisit__r.Id;
                        if(attendee.Televisit__r.Status__c == 'Cancelled'){
                            pastTelevisit.status = 'Canceled';
                            pastTelevisit.iscancelledone = true;
                        }
                        pastTelevisitsmap.put(attendee.Televisit__r.Id,pastTelevisit);
                    }                                       
                }
                List<Televisit__c> televisitList = [Select id,(select id,Attendee_Type__c,Firstname__c,Televisit__c,Lastname__c,CreatedBy.Name  from Televisit_Attendee__r) from Televisit__c 
                where Id IN : televisitIdSet order by Visit_Date_Time__c,Duration__c asc];
                List<Televisit_Attendee__c> attendeelist = new List<Televisit_Attendee__c>();
                if(televisitList != null && !televisitList.isempty()){
                    for(Televisit__c televisit: televisitList){
                        attendeelist.addAll(televisit.Televisit_Attendee__r);
                    }
                }
                Map<Id,List<televisitattendeeWrapper>> upcomingattendeesmap = new Map<Id,List<televisitattendeeWrapper>>();
                Map<Id,List<televisitattendeeWrapper>> pastattendeesmap = new Map<Id,List<televisitattendeeWrapper>>();

                for(Televisit_Attendee__c ta:attendeelist){
                    televisitattendeeWrapper taw = new televisitattendeeWrapper();
                    taw.firstname = ta.Firstname__c;
                    taw.lastname = ta.Lastname__c;
                    taw.attendeeType = ta.Attendee_Type__c;
                    if(pastTelevisitsmap.containskey(ta.Televisit__c)){
                        if(pastattendeesmap.containskey(ta.Televisit__c)){
                            pastattendeesmap.get(ta.Televisit__c).add(taw);
                        }else{                        
                            pastattendeesmap.put(ta.Televisit__c,new List<televisitattendeeWrapper> {taw});
                        }
                    }else if(upcomingTelevisitmap.containskey(ta.Televisit__c)){
                        if(upcomingattendeesmap.containskey(ta.Televisit__c)){
                            upcomingattendeesmap.get(ta.Televisit__c).add(taw);
                        }else{                        
                            upcomingattendeesmap.put(ta.Televisit__c,new List<televisitattendeeWrapper> {taw});
                        }
                    }
                   
                }
                List<upcomingTelevisits> finalupcomingTelevisitslist = new List<upcomingTelevisits>();
                List<pastTelevisits> finalpastTelevisitslist = new List<pastTelevisits>();
                for(Id i:upcomingattendeesmap.keyset()){
                    upcomingTelevisits ut = new upcomingTelevisits();
                    ut = upcomingTelevisitmap.get(i);
                    ut.relatedAttendees = upcomingattendeesmap.get(i);
                    if(finalupcomingTelevisitslist.size()<=6){
                        finalupcomingTelevisitslist.add(ut);
                    }else{
                        break;
                    }
                }
                for(Id i:pastTelevisitsmap.keyset()){
                    pastTelevisits pt = new pastTelevisits();
                    pt = pastTelevisitsmap.get(i);
                    pt.relatedAttendees = pastattendeesmap.get(i);
                    if(finalpastTelevisitslist.size()<=6){
                        finalpastTelevisitslist.add(pt);
                    }else{
                        break;
                    }
                }
                tw.televisitupcomingList = finalupcomingTelevisitslist;
                tw.televisitpastList = finalpastTelevisitslist;
                tw.showDefault = 'upcoming';
                tw.tz = [Select TimeZoneSidKey from User where id =: UserInfo.getUserId()][0].TimeZoneSidKey;
                /*if(!finalupcomingTelevisitslist.isEmpty() || finalpastTelevisitslist.isEmpty()){
                    tw.showDefault = 'upcoming';
                }else{
                    tw.showDefault = 'past';
                }*/
                return tw;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class upcomingTelevisits{
        @AuraEnabled public string title;
        @AuraEnabled public datetime televisitdate;
        @AuraEnabled public string televisitduration;
        @AuraEnabled public id televisitId;
        @AuraEnabled public string televisitmettingurl;
        @AuraEnabled public boolean showjoinbutton;
        @AuraEnabled public List<televisitattendeeWrapper> relatedAttendees;
    }
    public class pastTelevisits{
        @AuraEnabled public string title;
        @AuraEnabled public datetime televisitdate;
        @AuraEnabled public string televisitduration;
        @AuraEnabled public string status;
        @AuraEnabled public id televisitId;
        @AuraEnabled public boolean iscancelledone = false;
        @AuraEnabled public List<televisitattendeeWrapper> relatedAttendees;
    }
    public class televisitWrapper{
        @AuraEnabled public List<upcomingTelevisits> televisitupcomingList;
        @AuraEnabled public List<pastTelevisits> televisitpastList;
        @AuraEnabled public string showDefault;
        @AuraEnabled public string tz;
    }
    public class televisitattendeeWrapper{
        @AuraEnabled public string firstname;
        @AuraEnabled public string lastname;
        @AuraEnabled public string attendeeType;
        @AuraEnabled public boolean organiger = false;
    }
}