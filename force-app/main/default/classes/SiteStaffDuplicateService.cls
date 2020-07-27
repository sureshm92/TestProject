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
    
    public SiteStaffDuplicateService(List<Site_Staff__c> newSiteStaff){
        List<String> emails = new List<String>();
        List<String> phones = new List<String>();
        List<String> epkeys = new List<String>();
        for(Site_Staff__c ss : newSiteStaff){
            if(ss.Phone__c != Null) 
                phones.add(ss.Phone__c);
            if(ss.Email__c != Null) 
                emails.add(ss.Email__c);
            if(ss.Email__c != Null || ss.Phone__c != Null)
                epkeys.add(ss.Site_Number2__c + '_' + ss.Phone__c + '_' + ss.Email__c);
        }
        
        //Find Study Staff
        List<Site_Staff__c> existedSiteStaff = [SELECT Id, Email__c, Phone__c, Site_Number2__c, Roles__c, Site_Contact__c, Site_Email_Key__c
												FROM Site_Staff__c
												WHERE Email__c IN: emails OR Phone__c IN: phones];
            
        Map<String, Site_Staff__c>  siteStaffByEmailMap = new Map<String, Site_Staff__c>();
       	for(Site_Staff__c siteStaff : existedSiteStaff)
		{
			if(siteStaff.Site_Email_Key__c !=null)siteStaffByEmailMap.put(siteStaff.Site_Email_Key__c, siteStaff);
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
    
        for(Site_Staff__c ss : newSiteStaff){
            DuplicateContainer duplicate;
            if(siteStaffByEmailMap.get(ss.Site_Number2__c+'_'+ss.Phone__c+'_'+ss.Email__c.toLowerCase()) != null){
				duplicate = new DuplicateContainer(siteStaffByEmailMap.get(ss.Site_Number2__c+'_'+ss.Phone__c+'_'+ss.Email__c.toLowerCase()));
        	}else if(ss.Email__c != null && contactsByEmailMap.get(ss.Email__c.toLowerCase()) != null){
                duplicate = new DuplicateContainer(contactsByEmailMap.get(ss.Email__c.toLowerCase()));
            }else if(ss.Phone__c != null && contactsByPhoneMap.get(ss.Phone__c) != null){
                duplicate = new DuplicateContainer(contactsByPhoneMap.get(ss.Phone__c));
            }
            
            if(duplicate != null){
                setDuplicate(ss, duplicate);
                continue;
            }    
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
        if(duplicate.isSiteStaff()){
            mergeStudyStaff(duplicate.getSiteStaff(), newSiteStaff);
        }
        duplicatesMap.put(studyStaffID, duplicate);
    }
    
    private static void mergeStudyStaff(Site_Staff__c sourceSiteStaff, Site_Staff__c newSiteStaff){
        if(sourceSiteStaff == null || newSiteStaff == null) return;
        if(newSiteStaff.Phone__c != null) sourceSiteStaff.Phone__c = newSiteStaff.Phone__c;
        if(newSiteStaff.Email__c != null) sourceSiteStaff.Email__c = newSiteStaff.Email__c;        
    }
    



}