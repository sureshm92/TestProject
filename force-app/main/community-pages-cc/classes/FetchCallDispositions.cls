public without sharing class FetchCallDispositions {
    
    @AuraEnabled(Cacheable = true)
    public static todayDate gettodaydate(){
        try {
            Integer Year = Date.Today().Year();
            Integer day = Date.Today().day();
            DateTime dt = Datetime.now();
            Contact userContact = CommunityService.getUserContact();
            String dy='';           
            
            if(day == 01 || day == 21 || day == 31)
            {
                dy=day+'st';  
            }
            else if(day == 02|| day == 22){
                dy=day+'nd'; 
            }
            else if(day == 03|| day == 23){
                dy=day+'rd'; 
            }
            else
            {
                dy=day+'th';
            }            
            
            todayDate td = new todayDate();
            td.day=dy;
            td.year =Year;
            if(dt.format('MMMM') == 'January')
            {
              td.month=System.Label.January;
            }else if(dt.format('MMMM') == 'February'){
              td.month=System.Label.February;
            }else if(dt.format('MMMM') == 'March'){
              td.month=System.Label.March;
            }else if(dt.format('MMMM') == 'April'){
              td.month=System.Label.April;
            }else if(dt.format('MMMM') == 'May'){
              td.month=System.Label.May;
            }else if(dt.format('MMMM') == 'June'){
              td.month=System.Label.June;
            }else if(dt.format('MMMM') == 'July'){
              td.month=System.Label.July;
            }else if(dt.format('MMMM') == 'August'){
              td.month=System.Label.August;
            }else if(dt.format('MMMM') == 'September'){
              td.month=System.Label.September;
            }else if(dt.format('MMMM') == 'October'){
              td.month=System.Label.October;
            }else if(dt.format('MMMM') == 'November'){
              td.month=System.Label.November;
            }else if(dt.format('MMMM') == 'December'){
              td.month=System.Label.December;
            }
            else{
              td.month=dt.format('MMMM');
            }
            
            
            //td.month= dt.format('MMMM');
            td.conName =userContact.Name;
            return td;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static wrapcalls getcalls(integer limits,string siteId){
        try {
            List<Call_Dispositions__c> lstCD =new  List<Call_Dispositions__c>();
            List<Call_Dispositions__c> lstCallDispositions =new  List<Call_Dispositions__c>();
            List<Wrapcd> lstcalldts = new List<Wrapcd>();
            List<String> lstCallDateTime = new List<String>();
            Integer count=0;
            lstCD = [select Id,Call_Category__c,Caller__c,Caller__r.Name,CreatedDate,Inbound_Outbound__c,IQVIA_intervention_completed__c,IQVIA_intervention_required__c,Study_Site__c,Notes__c 
                     from Call_Dispositions__c where Study_Site__c=:siteId order by CreatedDate desc limit:limits];
            count =[select count() from Call_Dispositions__c where Study_Site__c=:siteId];
            
            string calldatetime='';
            string a='';
            string month='';
            for(Call_Dispositions__c c:lstCD)
            {
                calldatetime='';
                a='';
                month='';
                DateTime dt = c.CreatedDate;
                if(dt.format('dd') == '01' || dt.format('dd') == '21' || dt.format('dd') == '31')
                {
                    a='st';  
                }
                else if(dt.format('dd') == '02'|| dt.format('dd') == '22')
                {
                    a='nd'; 
                }
                else if(dt.format('dd') == '03'|| dt.format('dd') == '23')
                {
                    a='rd'; 
                }
                else
                {
                    a='th';
                }
                
                if(dt.format('MMMM') == 'January')
                {
                  month=System.Label.January;
                }else if(dt.format('MMMM') == 'February'){
                  month=System.Label.February;
                }else if(dt.format('MMMM') == 'March'){
                  month=System.Label.March;
                }else if(dt.format('MMMM') == 'April'){
                  month=System.Label.April;
                }else if(dt.format('MMMM') == 'May'){
                  month=System.Label.May;
                }else if(dt.format('MMMM') == 'June'){
                  month=System.Label.June;
                }else if(dt.format('MMMM') == 'July'){
                  month=System.Label.July;
                }else if(dt.format('MMMM') == 'August'){
                  month=System.Label.August;
                }else if(dt.format('MMMM') == 'September'){
                  month=System.Label.September;
                }else if(dt.format('MMMM') == 'October'){
                  month=System.Label.October;
                }else if(dt.format('MMMM') == 'November'){
                  month=System.Label.November;
                }else if(dt.format('MMMM') == 'December'){
                  month=System.Label.December;
                }
                else{
                  month=dt.format('MMMM');
                }
                
                calldatetime=calldatetime+month+' '+dt.format('dd')+a+', '+dt.format('yyyy')+', '+dt.format('h:mm a');
                system.debug('cd-->'+c.id+' '+calldatetime);
                lstcalldts.add(new Wrapcd(c, calldatetime));
                lstCallDispositions.add(c);
                lstCallDateTime.add(calldatetime);
            }
            
            
            wrapcalls wc = new wrapcalls();
            wc.lstCDs=lstcalldts;
            //wc.callDateTime=lstCallDateTime;
            wc.count=count;
            return wc;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class todayDate {
        @AuraEnabled
        public String day { get; set; }
        @AuraEnabled
        public string month { get; set; }
        @AuraEnabled
        public Integer year { get; set; }
        @AuraEnabled
        public string conName { get; set; }
    }
    public class wrapcalls {
        @AuraEnabled
        public List<Wrapcd> lstCDs { get; set; }
        @AuraEnabled
        public Integer count { get; set; }
        
        
    }
    public class Wrapcd
    {
        @AuraEnabled
        public Call_Dispositions__c cd { get; set; }
        @AuraEnabled
        public String dtcd{ get; set; }
        public Wrapcd(Call_Dispositions__c cd,String dtcd) {
            this.cd= cd;
            this.dtcd= dtcd;
            
        }
    }
    
}