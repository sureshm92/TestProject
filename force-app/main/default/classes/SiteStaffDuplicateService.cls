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
        
        public Site_Staff__c getSiteStaff(){
            if(isSiteStaff()) return (Site_Staff__c)duplicate;
            return null;
        }
    
        public Contact getContact(){
            if(!isSiteStaff()) return (Contact)duplicate;
            return null;
        }

    }
    
    public SiteStaffDuplicateService(Map<String, Site_Staff__c> newSiteStaff){
        System.debug('Inside SiteStaffDuplicateService');
        System.debug('newSiteStaff-->' + newSiteStaff);

        List<String> emails = new List<String>();
        List<String> phones = new List<String>();
        List<String> epkeys = new List<String>();
        for(String ss : newSiteStaff.keySet()){
            epkeys.add(ss);
            if(newSiteStaff.get(ss).Phone__c != Null) 
                phones.add(newSiteStaff.get(ss).Phone__c);
            if(newSiteStaff.get(ss).Email__c != Null) 
                emails.add(newSiteStaff.get(ss).Email__c);
        }
        System.debug('phones-->' + phones);
        System.debug('emails-->' + emails);
        System.debug('epkeys-->' + epkeys);

        //Find Study Staff
        Map<String, Site_Staff__c> studyStaffByKeyMap = new Map<String, Site_Staff__c>();
        
        for(Site_Staff__c ss : [SELECT Id, Email__c, Phone__c, Site_Number__c, Roles__c, Site_Contact__c, Site_Email_Key__c, Study_Site__r.Study_Site_Number__c 
                                FROM Site_Staff__c
                                WHERE Email__c IN: emails AND Phone__c IN: phones]){
            DuplicateContainer duplicate;
            if(newSiteStaff != null){
                for(String epkey : newSiteStaff.keySet()){
                    if(epkey!= null && epkey == ss.Site_Email_Key__c){
                        studyStaffByKeyMap.put(epkey, ss);
                        duplicate = new DuplicateContainer(studyStaffByKeyMap.get(epkey)); 
                        system.debug('site staff duplicate ' + duplicate);
                        if(duplicate != null){
                            setDuplicate(newSiteStaff.get(epkey), duplicate);
                    	}   
                    }                        
                }
            }              
        }
        
        
        //Find contacts:
        List<Contact> existedContacts = [
                SELECT Id, FirstName, LastName, Email, Phone, Birthdate
                FROM Contact
                WHERE Email IN: emails OR Phone IN: phones
        ];
        Map<String, Contact> contactsByEmailMap = new Map<String, Contact>();
        Map<String, Contact> contactsByPhoneMap = new Map<String, Contact>();
        for(Contact contact : existedContacts){
            if(contact.Email != null) contactsByEmailMap.put(contact.Email.toLowerCase(), contact);
            if(contact.Phone != null) contactsByPhoneMap.put(contact.Phone, contact);
        }
    
        for(Site_Staff__c ss : newSiteStaff.values()){
            DuplicateContainer duplicate;
            if(ss.Site_Contact__r.Email != null && contactsByEmailMap.get(ss.Site_Contact__r.Email.toLowerCase()) != null){
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
        if(newSiteStaff.Phone__c != null) sourceSiteStaff.Phone__c = newSiteStaff.Phone__c;
        if(newSiteStaff.Email__c == null) sourceSiteStaff.Email__c = newSiteStaff.Email__c;
        //if(newSiteStaff.Site_Number__c == null) sourceSiteStaff.Email__c = newSiteStaff.Site_Number__c;
        
    }
    



}