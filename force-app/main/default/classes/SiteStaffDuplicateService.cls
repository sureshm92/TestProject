/**
 ** Created by Sumit Surve
 */

public without sharing class SiteStaffDuplicateService {
    
    public class SiteStaffDuplicateServiceException extends Exception{}
    
    public Map<Integer, DuplicateContainer> duplicatesMap = new Map<Integer, DuplicateContainer>();
    @testVisible
    private class DuplicateContainer{
        public Object duplicate;
        
        public DuplicateContainer(Object duplicate){
            this.duplicate = duplicate;
        }
        
        public Boolean isSiteStaff(){
            return duplicate instanceof Site_Staff__c;
        }

        public String getFirstName(){
            if(isSiteStaff()){
                return ((Site_Staff__c)duplicate).Site_Contact__r.FirstName;
            }
            return ((Contact)duplicate).FirstName;
        }
        
        /*
        public Integer getYearOfBirth(){
            if(isParticipant()){
                Participant__c participant = (Participant__c)duplicate;
                return getYearOfBirthForParticipant(participant);
            }
            return null;
        }
        */
        
        public Site_Staff__c getSiteStaff(){
            if(isSiteStaff()) return (Site_Staff__c)duplicate;
            return null;
        }
    
        public Contact getContact(){
            if(!isSiteStaff()) return (Contact)duplicate;
            return null;
        }

    }
    
    public SiteStaffDuplicateService(Site_Staff__c study_staff){
        this(new List<Site_Staff__c>{study_staff});
    }
    
    public SiteStaffDuplicateService(List<Site_Staff__c> newSiteStaff){
        System.debug('Inside SiteStaffDuplicateService');
        System.debug('newSiteStaff-->' + newSiteStaff);

        List<String> emails = new List<String>();
        List<String> phones = new List<String>();
        for(Site_Staff__c ss : newSiteStaff){
            if(!String.isEmpty(ss.Phone__c)) phones.add(ss.Phone__c);
            if(!String.isEmpty(ss.Email__c)) emails.add(ss.Email__c);
        }
        System.debug('phones-->' + phones);
        System.debug('emails-->' + emails);

        //Find Study Staff
        List<Site_Staff__c> existedSiteStaff = [
                SELECT Id, Email__c, Phone__c
                FROM Site_Staff__c
                WHERE Email__c IN: emails OR Phone__c IN: phones
        ];
        System.debug('existedSiteStaff--->' + existedSiteStaff);

        Map<String, Site_Staff__c> studyStaffByEmailMap = new Map<String, Site_Staff__c>();
        Map<String, Site_Staff__c> studyStaffByPhoneMap = new Map<String, Site_Staff__c>();
        for(Site_Staff__c ss : existedSiteStaff){
            if(ss.Email__c != null) studyStaffByEmailMap.put(ss.Email__c.toLowerCase(), ss);
            if(ss.Phone__c != null) studyStaffByPhoneMap.put(ss.Phone__c, ss);
        }
        System.debug('studyStaffByEmailMap----> ' + studyStaffByEmailMap);
        System.debug('studyStaffByPhoneMap----> ' + studyStaffByPhoneMap);

        //Find contacts:
        List<Contact> existedContacts = [
                SELECT Id, FirstName, Email, Phone, Birthdate
                FROM Contact
                WHERE Email IN: emails OR Phone IN: phones
        ];
        Map<String, Contact> contactsByEmailMap = new Map<String, Contact>();
        Map<String, Contact> contactsByPhoneMap = new Map<String, Contact>();
        for(Contact contact : existedContacts){
            if(contact.Email != null) contactsByEmailMap.put(contact.Email.toLowerCase(), contact);
            if(contact.Phone != null) contactsByPhoneMap.put(contact.Phone, contact);
        }
    
        for(Site_Staff__c ss : newSiteStaff){
            DuplicateContainer duplicate;
            if(ss.Email__c != null && studyStaffByEmailMap.get(ss.Email__c.toLowerCase()) != null){
                duplicate = new DuplicateContainer(studyStaffByEmailMap.get(ss.Email__c.toLowerCase()));
            }else if(ss.Phone__c != null && studyStaffByPhoneMap.get(ss.Phone__c) != null){
                duplicate = new DuplicateContainer(studyStaffByPhoneMap.get(ss.Phone__c));
            }else if(ss.Site_Contact__r.Email != null && contactsByEmailMap.get(ss.Site_Contact__r.Email.toLowerCase()) != null){
                duplicate = new DuplicateContainer(contactsByEmailMap.get(ss.Site_Contact__r.Email.toLowerCase()));
            }else if(ss.Site_Contact__r.Phone != null && contactsByPhoneMap.get(ss.Site_Contact__r.Phone) != null){
                duplicate = new DuplicateContainer(contactsByPhoneMap.get(ss.Site_Contact__r.Phone));
            }
            
            System.debug('duplicate---> ' + duplicate);

            if(duplicate != null){
                setDuplicate(ss, duplicate);
                continue;
            }    

            /*
            if(duplicate != null){
                Integer birthYear = getYearOfBirthForParticipant(participant);
                System.debug('>>> BY: ' + birthYear);
                if(birthYear != null){
                    Integer participantAge = System.today().year() - birthYear;
                    System.debug('>>> Participant age: ' + participantAge);
                    Integer birthYearInTheSystem = duplicate.getYearOfBirth();
                    if(birthYearInTheSystem != null){
                        System.debug('>>> BY in the system: ' + birthYearInTheSystem);
                        if(birthYear == birthYearInTheSystem && duplicate.getFirstName() == participant.First_Name__c){
                            setDuplicate(participant, duplicate);
                            continue;
                        }
                    }else if(participantAge > 18 && duplicate.getFirstName() == participant.First_Name__c){
                        setDuplicate(participant, duplicate);
                        continue;
                    }
                }else{
                    if(duplicate.getFirstName() == participant.First_Name__c) {
                        setDuplicate(participant, duplicate);
                        continue;
                    }
                }
            
            }
            */
        }
    }
    
    public Site_Staff__c findDuplicate(Site_Staff__c site_staff){
        Integer siteStaffID = JSON.serialize(site_staff).hashCode();
        DuplicateContainer duplicate = duplicatesMap.get(siteStaffID);
        if(duplicate != null) return duplicate.getSiteStaff();
        return null;
    }
    
    public Contact findDuplicateContact(Site_Staff__c site_staff){
        Integer siteStaffID = JSON.serialize(site_staff).hashCode();
        DuplicateContainer duplicate = duplicatesMap.get(siteStaffID);
        if(duplicate != null) return duplicate.getContact();
        return null;
    }
    
    private void setDuplicate(Site_Staff__c newSiteStaff, DuplicateContainer duplicate){
        Integer studyStaffID = JSON.serialize(newSiteStaff).hashCode();
        system.debug('duplicate.isSiteStaff()---->' + duplicate.isSiteStaff());
        system.debug('newSiteStaff---->' + newSiteStaff);
        if(duplicate.isSiteStaff()){
            mergeStudyStaff(duplicate.getSiteStaff(), newSiteStaff);
        }
        duplicatesMap.put(studyStaffID, duplicate);
    }
    
    /*
    private static Integer getYearOfBirthForParticipant(Participant__c participant){
        if(!String.isEmpty(participant.Birth_Year__c)) return getYearFromString(participant.Birth_Year__c);
        if(!String.isEmpty(participant.Date_of_Birth__c)) return getYearFromString(participant.Date_of_Birth__c);
        return null;
    }
    
    private static Integer getYearFromString(String str){
        try{
            return Integer.valueOf(str.mid(0, 4));
        }catch (Exception e){}
        try {
            return Integer.valueOf(str.substring(6, 10));
        }catch (Exception e){
            throw new ParticipantDuplicateServiceException('Can not extract year from field value: ' + str);
        }
    }
    */
    
    
    private static void mergeStudyStaff(Site_Staff__c sourceSiteStaff, Site_Staff__c newSiteStaff){
        if(sourceSiteStaff == null || newSiteStaff == null) return;
        //if(newParticipant.Phone__c != null) sourceParticipant.Phone__c = newParticipant.Phone__c;
        //if(newParticipant.Email__c == null) sourceParticipant.Email__c = newParticipant.Email__c;
        //if(newSiteStaff.Mailing_Country_Code__c != null) sourceSiteStaff.Mailing_Country_Code__c = newParticipant.Mailing_Country_Code__c;
        //if(newSiteStaff.Mailing_State_Code__c != null) sourceSiteStaff.Mailing_State_Code__c = newParticipant.Mailing_State_Code__c;
        //if(newSiteStaff.Mailing_Zip_Postal_Code__c != null) sourceSiteStaff.Mailing_Zip_Postal_Code__c = newParticipant.Mailing_Zip_Postal_Code__c;
        //if(newParticipant.Last_Name__c != null) sourceParticipant.Last_Name__c = newParticipant.Last_Name__c;
        //if(newSiteStaff.Middle_Name__c != null) sourceSiteStaff.Middle_Name__c = newParticipant.Middle_Name__c;
        //if(newSiteStaff.Date_of_Birth__c != null) sourceSiteStaff.Date_of_Birth__c = newParticipant.Date_of_Birth__c;
        //if(newSiteStaff.Birth_Year__c != null) sourceSiteStaff.Birth_Year__c = newParticipant.Birth_Year__c;
    }
    



}