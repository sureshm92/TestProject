public without sharing class CPD_DistanceCalculator 
{
    public class siteDistanceWrapperWrapper
    {
        public Study_Site__c studySite;
        public string distance;

        public siteDistanceWrapperWrapper(Study_Site__c studySite,string distance)
        {
            this.studySite = studySite;
            this.distance = distance;
        } 
    }
    
    public class georesultWrapper
    {
        public Integer place_id {get;set;} 
        public String licence {get;set;} 
        public String osm_type {get;set;} 
        public Integer osm_id {get;set;} 
        public List<String> boundingbox {get;set;} 
        public String lat {get;set;} 
        public String lon {get;set;} 
        public String display_name {get;set;} 
        public String class_Z {get;set;} // in json: class
        public String type_Z {get;set;} // in json: type
        public Double importance {get;set;} 
        public String icon {get;set;} 
    }
    
    @AuraEnabled
    public static Account getTmpAccount() {
        try 
        {
            Account acc = [
                    SELECT Id,
                            BillingGeocodeAccuracy,
                            BillingLongitude,
                            BillingLatitude,
                            BillingCity,
                            BillingCountryCode,
                            BillingCountry,
                            BillingStateCode,
                            BillingState,
                            BillingStreet,
                            BillingPostalCode
                    FROM Account
                    WHERE Name='Dummy-Covid-19' Limit 1
            ];
            return acc;
        } catch (Exception e) {
            return (Account) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static String getsiteDistanceCalculation() 
    {
        List<siteDistanceWrapperWrapper> siteDistanceWrapperWrapperList = new List<siteDistanceWrapperWrapper>();
        List<Study_Site__c> studySiteList = new List<Study_Site__c>();
        Location contactLocation;
        Location accounLocation;
        String protocolId = 'C19NYBC';
        String studyAccepted = 'Accepted';
        String studyAcceptedAdmin = 'Accepted (Admin)';
        List<georesultWrapper> result;

        List<Account> accList = [Select Id,BillingLatitude,BillingLongitude from Account where Name='Dummy-Covid-19'];
        System.debug('***accList'+ accList);
        if(!accList.isEmpty() && accList[0].BillingLatitude != null && accList[0].BillingLongitude != null)
        {
            contactLocation = Location.newInstance(accList[0].BillingLatitude,accList[0].BillingLongitude);
        }
        else
        {
            contactLocation = Location.newInstance(null,null);
        }    
        if(contactLocation.Latitude != null && contactLocation.Latitude != null )
        {
            String query = 'SELECT Id, Name, Protocol_ID__c, Study_Site_Number__c,Clinical_Trial_Profile__r.Study_Code_Name__c, '+
            'Site__r.BillingAddress,Site__r.BillingStreet,Site__r.BillingCity,Site__r.BillingCountry,Site__r.BillingPostalCode, '+
            'Site__r.BillingState,Site__r.BillingLatitude,Site__r.BillingLongitude ' + 
            'FROM Study_Site__c  WHERE ';
            query +='( (Override_PI_Referral_Status__c =: studyAccepted OR Override_PI_Referral_Status__c =: studyAcceptedAdmin ) AND Study_Site_Number__c != NULL AND Clinical_Trial_Profile__r.Protocol_ID__c = :protocolId )';
            query += ' ORDER BY DISTANCE(Site__r.BillingAddress, GEOLOCATION(' + contactLocation.Latitude + ', ' + contactLocation.Longitude + '), \'mi\') ASC ';
            studySiteList = database.Query(query);
        }
        else
        {
            studySiteList = [Select Id, Name, Protocol_ID__c, Study_Site_Number__c, 
            Clinical_Trial_Profile__r.Study_Code_Name__c,Site__r.BillingAddress,
            Site__r.BillingStreet,Site__r.BillingCity,Site__r.BillingCountry,
            Site__r.BillingPostalCode,Site__r.BillingState,Site__r.BillingLatitude,Site__r.BillingLongitude
            From Study_Site__c Where Clinical_Trial_Profile__r.Protocol_ID__c =: protocolId AND (Override_PI_Referral_Status__c =: studyAccepted OR Override_PI_Referral_Status__c =: studyAcceptedAdmin) AND Study_Site_Number__c != NULL];
        }
        for(Study_Site__c site : studySiteList) 
        {
            accounLocation = Location.newInstance(site.Site__r.BillingLatitude,site.Site__r.BillingLongitude);
            double distance = Location.getDistance(accounLocation, contactLocation, 'mi');
            System.debug('***distance'+distance);

            if(accounLocation.Latitude != null && accounLocation.Latitude != null && distance != null)
            {
                siteDistanceWrapperWrapperList.add(new siteDistanceWrapperWrapper(site,roundDouble(distance)));
            }
            else 
            {
                siteDistanceWrapperWrapperList.add(new siteDistanceWrapperWrapper(site,'0'));
            }
            
        }
        System.debug('****siteDistanceWrapperWrapperList' + siteDistanceWrapperWrapperList);
        try
        {
            if(!accList.isEmpty())
            {
                delete accList;
            }
            return JSON.serialize(siteDistanceWrapperWrapperList);
        }
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }  
    
    public static String roundDouble(Double rawDouble) 
    {
        return ((rawDouble * 10).round() / 10.0).format();
    }

   /* @AuraEnabled
    public static String getsiteDistanceCalculation(String state,string country,string zipcode) 
    {
        List<siteDistanceWrapperWrapper> siteDistanceWrapperWrapperList = new List<siteDistanceWrapperWrapper>();
        List <Study_Site__c> studySiteList = new List <Study_Site__c>();
        Location contactLocation;
        Location accounLocation;
        String protocolId = 'C19NYBC';
        String studyAccepted = 'Accepted';
        List<georesultWrapper> result;
        
        String jsonResults = getGeocode(state,country,zipcode);
        System.debug('jsonResults===' + jsonResults);

        if(jsonResults != null && jsonResults != '[]' && jsonResults != '')
        {
            result = (List<georesultWrapper>) JSON.deserialize(jsonResults, List<georesultWrapper>.class);
            if(result != null && result.get(0).lat != null && result.get(0).lon != null)
            {
                Double latitude= Double.valueOf(result.get(0).lat);
                Double longitude= Double.valueOf(result.get(0).lon);
                contactLocation = Location.newInstance(latitude,longitude);
            }
        }
        else
        {
            contactLocation = Location.newInstance(null,null);
        }
        System.debug('@@@contactLocation'+contactLocation);

        if(contactLocation.Latitude != null && contactLocation.Latitude != null )
        {
            String query = 'SELECT Id, Name, Protocol_ID__c, Study_Site_Number__c,Clinical_Trial_Profile__r.Study_Code_Name__c, '+
            'Site__r.BillingAddress,Site__r.BillingStreet,Site__r.BillingCity,Site__r.BillingCountry,Site__r.BillingPostalCode, '+
            'Site__r.BillingState,Site__r.BillingLatitude,Site__r.BillingLongitude ' + 
            'FROM Study_Site__c  WHERE ';
            query +='( Override_PI_Referral_Status__c =: studyAccepted AND Study_Site_Number__c != NULL AND Clinical_Trial_Profile__r.Protocol_ID__c = :protocolId AND DISTANCE(Site__r.BillingAddress, GEOLOCATION(' + contactLocation.Latitude + ', ' + contactLocation.Longitude + '), \'mi\') < 50000)';
            query += ' ORDER BY DISTANCE(Site__r.BillingAddress, GEOLOCATION(' + contactLocation.Latitude + ', ' + contactLocation.Longitude + '), \'mi\') ASC ';
            studySiteList = database.Query(query);
        }
        else
        {
            studySiteList = [Select Id, Name, Protocol_ID__c, Study_Site_Number__c, 
            Clinical_Trial_Profile__r.Study_Code_Name__c,Site__r.BillingAddress,
            Site__r.BillingStreet,Site__r.BillingCity,Site__r.BillingCountry,
            Site__r.BillingPostalCode,Site__r.BillingState,Site__r.BillingLatitude,Site__r.BillingLongitude
            From Study_Site__c Where Clinical_Trial_Profile__r.Protocol_ID__c = 'C19NYBC' AND Override_PI_Referral_Status__c =: studyAccepted AND Study_Site_Number__c != NULL];
        }
        for(Study_Site__c site : studySiteList) 
        {
            accounLocation = Location.newInstance(site.Site__r.BillingLatitude,site.Site__r.BillingLongitude);
            double distance = Location.getDistance(accounLocation, contactLocation, 'mi');
            System.debug('***distance'+distance);

            if(accounLocation.Latitude != null && accounLocation.Latitude != null && distance != null)
            {
                siteDistanceWrapperWrapperList.add(new siteDistanceWrapperWrapper(site,roundDouble(distance)));
            }
            else 
            {
                siteDistanceWrapperWrapperList.add(new siteDistanceWrapperWrapper(site,'0'));
            }
        }
        System.debug('****siteDistanceWrapperWrapperList' + siteDistanceWrapperWrapperList);
        try
        {
            return JSON.serialize(siteDistanceWrapperWrapperList);
        }
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }   */

    /*@AuraEnabled
    public static String getsiteDistanceCalculation(String ContactId) 
    {
        List<siteDistanceWrapperWrapper> siteDistanceWrapperWrapperList = new List<siteDistanceWrapperWrapper>();
        List <Study_Site__c> studySiteList = new List <Study_Site__c>();
        Location contactLocation;
        Location accounLocation;
        String protocolId = 'C19NYBC';
        String studyAccepted = 'Accepted';
        List<georesultWrapper> result;
        List<Contact> contactRecord = new List<Contact>();
        String jsonResults ='';
        contactRecord = [SELECT Id, MailingPostalCode,MailingCountryCode, MailingState FROM Contact where id =: ContactId limit 1];          
        if(!contactRecord.isEmpty() && contactRecord[0].MailingState != null &&  contactRecord[0].MailingCountryCode != null 
                && contactRecord[0].MailingPostalCode != null)
        {
       
            jsonResults = getGeocode(contactRecord[0].MailingState,contactRecord[0].MailingCountryCode,contactRecord[0].MailingPostalCode);

        }
        System.debug('jsonResults===' + jsonResults);
        if(jsonResults != null && jsonResults != '[]' && jsonResults != '')
        {
            result = (List<georesultWrapper>) JSON.deserialize(jsonResults, List<georesultWrapper>.class);
            if(result != null && result.get(0).lat != null && result.get(0).lon != null)
            {
                Double latitude= Double.valueOf(result.get(0).lat);
                Double longitude= Double.valueOf(result.get(0).lon);
                contactLocation = Location.newInstance(latitude,longitude);
            }
        }
        else
        {
            contactLocation = Location.newInstance(null,null);
        }
        System.debug('@@@contactLocation'+contactLocation);

        if(contactLocation.Latitude != null && contactLocation.Latitude != null )
        {
            String query = 'SELECT Id, Name, Protocol_ID__c, Study_Site_Number__c,Clinical_Trial_Profile__r.Study_Code_Name__c, '+
            'Site__r.BillingAddress,Site__r.BillingStreet,Site__r.BillingCity,Site__r.BillingCountry,Site__r.BillingPostalCode, '+
            'Site__r.BillingState,Site__r.BillingLatitude,Site__r.BillingLongitude ' + 
            'FROM Study_Site__c  WHERE ';
            query +='( Override_PI_Referral_Status__c =: studyAccepted AND Study_Site_Number__c != NULL AND Clinical_Trial_Profile__r.Protocol_ID__c = :protocolId AND DISTANCE(Site__r.BillingAddress, GEOLOCATION(' + contactLocation.Latitude + ', ' + contactLocation.Longitude + '), \'mi\') < 500)';
            query += ' ORDER BY DISTANCE(Site__r.BillingAddress, GEOLOCATION(' + contactLocation.Latitude + ', ' + contactLocation.Longitude + '), \'mi\') ASC ';
            studySiteList = database.Query(query);
        }
        else
        {
            studySiteList = [Select Id, Name, Protocol_ID__c, Study_Site_Number__c, 
            Clinical_Trial_Profile__r.Study_Code_Name__c,Site__r.BillingAddress,
            Site__r.BillingStreet,Site__r.BillingCity,Site__r.BillingCountry,
            Site__r.BillingPostalCode,Site__r.BillingState,Site__r.BillingLatitude,Site__r.BillingLongitude
            From Study_Site__c Where Clinical_Trial_Profile__r.Protocol_ID__c = 'C19NYBC' AND Override_PI_Referral_Status__c =: studyAccepted AND Study_Site_Number__c != NULL];
        }
        for(Study_Site__c site : studySiteList) 
        {
            accounLocation = Location.newInstance(site.Site__r.BillingLatitude,site.Site__r.BillingLongitude);
            double distance = Location.getDistance(accounLocation, contactLocation, 'mi');

            if(accounLocation.Latitude != null && accounLocation.Latitude != null && distance != null)
            {
                siteDistanceWrapperWrapperList.add(new siteDistanceWrapperWrapper(site,roundDouble(distance)));
            }
            else 
            {
                siteDistanceWrapperWrapperList.add(new siteDistanceWrapperWrapper(site,'0'));
            }
        }
        System.debug('****siteDistanceWrapperWrapperList' + siteDistanceWrapperWrapperList);
        try
        {
            return JSON.serialize(siteDistanceWrapperWrapperList);
        }
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }    */
   

   /* public static string getGeocode(String state, String country, String zipcode)
    {
        //https://nominatim.openstreetmap.org/search?format=json&q=New+york+US+10012
        //String replcestate = state.replace(' ', '+');
        //String AddressURL= 'state='+replcestate+'&country='+country+'&postalcode='+zipcode;
        String AddressURL= '&country='+country+'&postalcode='+zipcode;

        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setMethod('GET');
        String url = 'https://nominatim.openstreetmap.org/search?format=json&q=&'+AddressURL+'&format=json&limit=1';
        System.debug('***url'+url);
        req.setEndPoint(url);
        HTTPResponse resp = http.send(req); 
        String jsonResults;
        jsonResults = resp.getBody().replace('\n', '');
        return jsonResults;
    }   */
   
}