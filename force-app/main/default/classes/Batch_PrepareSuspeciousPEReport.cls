/*
 *Batch_PrepareSuspeciousPEReport
 *Apex class to extract RH suspecuious participant enrollment history and generate report
 *v02 04th_Nov_2020
 *created by Sumit Surve 
*/

global without sharing class Batch_PrepareSuspeciousPEReport extends Batch_ScheduledAbstract implements Database.Stateful {
   
    //global Set<Participant_Enrollment__History> suspectedPE = new Set<Participant_Enrollment__History>();
    //global String documentFolder = System.Label.PE_History_Report; //Participant Enrollment History Report; 
	global Folder folder;
    global List<Document> docList;
    global Datetime cdate;
	//global RH_Email_Address__mdt[] emailAddresses;
	global List<String> toAddresses = new List<String>();
	//global RH_User__mdt[] rhUsers;
	global List<String> rhUsersList = new List<String>();
	//global Smoke_Test_Study__mdt[] smokeTestStudies;
	global List<String> smokeTestStudyList = new List<String>();
    global Map<String, Participant_Enrollment__History> pehMap = new Map<String, Participant_Enrollment__History>();
	//global Map<Id, Participant_Enrollment__c> peMap = new Map<Id, Participant_Enrollment__c>();
		
    global Batch_PrepareSuspeciousPEReport(){
        String documentFolder = System.Label.PE_History_Report; //Participant Enrollment History Report; 
        folder = [SELECT Id, Name FROM Folder WHERE Name =: documentFolder LIMIT 1];
        docList = [SELECT Id, CreatedDate FROM Document WHERE FolderId =: folder.Id ORDER BY CreatedDate DESC];
        cdate = docList.isEmpty()? null : docList[0].CreatedDate;
		RH_Email_Address__mdt[] emailAddresses = [SELECT MasterLabel, Email__c FROM RH_Email_Address__mdt]; 
        for(RH_Email_Address__mdt email : emailAddresses){
			toAddresses.add(email.Email__c);
		}
        
		RH_User__mdt[] rhUsers = [SELECT MasterLabel FROM RH_User__mdt]; 
        for(RH_User__mdt usr : rhUsers){
			rhUsersList.add(usr.MasterLabel);
		}

		Smoke_Test_Study__mdt[] smokeTestStudies = [SELECT MasterLabel, Study_ID__c FROM Smoke_Test_Study__mdt];     
        for(Smoke_Test_Study__mdt sstudy : smokeTestStudies){
			smokeTestStudyList.add(sstudy.Study_ID__c);
		}
		
    }

	public Database.QueryLocator start(Database.BatchableContext bc) {
        Database.QueryLocator peQuery; 
        String query; 
        if(docList.isEmpty()){
            query = 'SELECT Id, Name, Clinical_Trial_Profile__r.Protocol_ID__c, Study_Site__c, PI_Contact__r.Id, HCP_Contact_HCPEnroll__r.Id, CreatedBy.Name FROM Participant_Enrollment__c';
        }else{
            query = 'SELECT Id, Name, Clinical_Trial_Profile__r.Protocol_ID__c, Study_Site__c, PI_Contact__r.Id, HCP_Contact_HCPEnroll__r.Id, CreatedBy.Name, CreatedDate, LastModifiedDate FROM Participant_Enrollment__c WHERE CreatedDate >= : cdate OR LastModifiedDate >= : cdate';
        }
		
		if(!smokeTestStudyList.isEmpty()) 
		{
			query = query + ' AND ID NOT IN : smokeTestStudyList'; 
		}	
        peQuery = Database.getQueryLocator(query); 
        return peQuery;    
    }

    public void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> scope) {
        Map<Id, List<String>> pePIHCPMap = new Map<Id, List<String>>(); 
		Map<Id, List<String>> ssStaffMap = new Map<Id, List<String>>();
		Map<Id, Set<String>> peStaffUserMap = new Map<Id, Set<String>>();
		Map<Id, List<String>> pEStaffMap = new Map<Id, List<String>>();	
		Set<String> ssSets = new Set<String>();
		Set<String> cntSet = new Set<String>();
		
        for(Participant_Enrollment__c pe: scope){
			ssSets.add(pe.Study_Site__c);
			if(pePIHCPMap.containsKey(pe.Id)){
				List<String> pIHcpCntList = pePIHCPMap.get(pe.Id);
                if(pe.PI_Contact__c != null){
					pIHcpCntList.add(pe.PI_Contact__r.Id);
                }
                if(pe.HCP_Contact_HCPEnroll__c != null){
					pIHcpCntList.add(pe.HCP_Contact_HCPEnroll__r.Id);
                }    
                cntSet.addAll(pIHcpCntList);
                pePIHCPMap.put(pe.Id, pIHcpCntList); 
                System.debug('pePIHCPMap-->' + pePIHCPMap);
		
			}else{
				List<String> pIHcpCntList = new List<String>();
				if(pe.PI_Contact__c != null){
					pIHcpCntList.add(pe.PI_Contact__r.Id);
                }
                if(pe.HCP_Contact_HCPEnroll__c != null){
					pIHcpCntList.add(pe.HCP_Contact_HCPEnroll__r.Id);
                }
				cntSet.addAll(pIHcpCntList);
				pePIHCPMap.put(pe.Id, pIHcpCntList);
			}
		}
		
        if(!ssSets.isEmpty()){ 
            for(Study_Site__c site : [Select Id, Principal_Investigator__r.Id, 
									  (Select Id, Site_Contact__r.Id, Study_Site__c From Site_Staff__r) 
									  From Study_Site__c			
                                      WHERE Id IN : ssSets]){
				List<String> cntIds =  new List<String>();
                for(Site_Staff__c sstaff : site.Site_Staff__r){
                    if(sstaff.Site_Contact__c != null){
                    	cntIds.add(sstaff.Site_Contact__r.Id);
                    }
				}	
                if(site.Principal_Investigator__c != null){
					cntIds.add(site.Principal_Investigator__r.Id);
                }    
				ssStaffMap.put(site.Id, cntIds);	
				cntSet.addAll(cntIds);
                //cntIds.clear();
        	}
		}
		
        //NYBC
        Map<String, String> nonPeNYBCMap = new Map<String, String>();
		for(Participant_Enrollment__c pe: scope)
		{
			pEStaffMap.put(pe.Id, ssStaffMap.get(pe.Study_Site__c));
            if(pe.Clinical_Trial_Profile__r.Protocol_ID__c != 'C19NYBC'){
                nonPeNYBCMap.put(pe.Id, pe.CreatedBy.Name);
            }
		}

		Map<String, String> cntUserMap = new Map<String, String>();
		
		for(User usr : [Select Id, Name, ContactId From User Where ContactId IN :  cntSet])
		{
			cntUserMap.put(usr.ContactId, usr.Id);
		}	
		
		for(String key : pePIHCPMap.keySet()){ 
			if(pEStaffMap.keySet().contains(key))
			{
				if(!pePIHCPMap.get(key).isEmpty())
				{	
					pEStaffMap.get(key).addAll(pePIHCPMap.get(key));
				}	
			}else{
				pEStaffMap.put(key, pePIHCPMap.get(key));
			}	
		}
		
		
        for(String peId : pEStaffMap.keySet())
		{
			Set<String> cntUserIds =  new Set<String>();
            for(String cntId : pEStaffMap.get(peId))
			{
				if(cntUserMap.get(cntId) != null){
                	cntUserIds.add(cntUserMap.get(cntId)); 
                }
			}
			peStaffUserMap.put(peId, cntUserIds);
            //cntUserIds.clear();
		}		
		
        List<Participant_Enrollment__History> pehList = new List<Participant_Enrollment__History>();
        
        if(!docList.isEmpty()){
            pehList = [SELECT Id, 
                       ParentId,
                       Parent.Name, 
                       Field, DataType, OldValue, 
                       CreatedBy.Name, CreatedDate, NewValue 
                       FROM Participant_Enrollment__History 
                       WHERE (ParentId IN : peStaffUserMap.keySet()) AND CreatedDate >= : cdate
                       AND (CreatedBy.Name NOT IN : rhUsersList OR (CreatedBy.Name = 'Covid-19 Site Guest User' AND Field = 'created'))]; // 
        }else
        {
         	pehList = [SELECT Id, 
                       ParentId,
                       Parent.Name, 
                       Field, DataType, OldValue, 
                       CreatedBy.Name, CreatedDate, NewValue 
                       FROM Participant_Enrollment__History 
                       WHERE (ParentId IN : peStaffUserMap.keySet())
                       AND (CreatedBy.Name NOT IN : rhUsersList OR (CreatedBy.Name = 'Covid-19 Site Guest User' AND Field = 'created'))];
        }
    
        if(!pehList.isEmpty()){
			for(Participant_Enrollment__History peh: pehList)
            { 
                if(!peStaffUserMap.get(peh.ParentId).isEmpty() && peh.CreatedBy.Name !='Covid-19 Site Guest User' && !peStaffUserMap.get(peh.ParentId).contains(peh.CreatedById))
                {
                    pehMap.put(peh.Parent.Name, peh);
                } 
                
				if(nonPeNYBCMap.get(peh.ParentId) !=null && nonPeNYBCMap.get(peh.ParentId) == 'Covid-19 Site Guest User')
                {
                    pehMap.put(peh.Parent.Name, peh);
                }
            }
        }
        
        //NYBC
		/*
        List<Participant_Enrollment__History> nonNYBCpehList = new List<Participant_Enrollment__History>();
        
        if(!docList.isEmpty()){
            nonNYBCpehList = [SELECT Id, 
                       ParentId, 
                       Field, DataType, OldValue, 
                       CreatedBy.Name, CreatedDate, NewValue 
                       FROM Participant_Enrollment__History 
                       WHERE (ParentId IN : peStaffUserMap.keySet()) AND CreatedDate >= : cdate
                       AND CreatedBy.Name = 'Covid-19 Site Guest User' AND Field = 'created'];  
        }else
        {
         	nonNYBCpehList = [SELECT Id, 
                       ParentId, 
                       Field, DataType, OldValue, 
                       CreatedBy.Name, CreatedDate, NewValue 
                       FROM Participant_Enrollment__History 
                       WHERE (ParentId IN : peStaffUserMap.keySet())
                       AND CreatedBy.Name = 'Covid-19 Site Guest User' AND Field = 'created' ];
        }
    
        if(!nonNYBCpehList.isEmpty()){
			for(Participant_Enrollment__History peh: nonNYBCpehList)
            { 
				if(nonPeNYBCMap.keySet().contains(peh.ParentId))
                {
                    suspectedPE.add(peh.Id);
                } 	
            }
        }
        */
		/*
        if(!pehMap.keySet().isEmpty())
		{
			
            for (Participant_Enrollment__History peh : suspectedPE)
            {
                pehMap.put(peh.ParentId, peh);
            }
            
			
            for (Participant_Enrollment__c pe : scope)
            {
                if(pehMap.keySet().contains(pe.Id)){
                	peMap.put(pe.Id, pe);
                }    
            }
        }*/
    }
	
	public override virtual void finalAction() {
	
		List<String> csvRowValues = new List<String>();
        String formatted  = DateTime.now().formatGMT('MMM_d_yyyy_HH_mm');
        String documentName = 'PE_Report_'+ formatted;
            
        String CSV_COLUMN_HEADER;

        if(!pehMap.isEmpty())
		{
            for(String peName : pehMap.keySet())
            {
                String refId = peName;
                //String firstName = peMap.get(peId).Participant_Name__c;
                //String lastName = peMap.get(peId).Participant_Surname__c;
                String field = pehMap.get(peName).Field;
                //String dataType = pehMap.get(peId).DataType;
                String oldValue = String.valueOf(pehMap.get(peName).OldValue);
                String newValue = String.valueOf(pehMap.get(peName).NewValue);
                String createdDate = pehMap.get(peName).CreatedDate.formatGMT('MM_dd_yyyy');
                String createdBy = pehMap.get(peName).CreatedBy.Name;
    
                String rowStr = refId + ',' + field + ',' + oldValue + ',' + newValue + ','
                + createdDate + ',' + createdBy;
                csvRowValues.add(rowStr);
            }
    
            CSV_COLUMN_HEADER = 'Participant Profile Name, Field, Old Value, New Value, Created/Modified Date, Created By \n';
    		
            String csvFile = CSV_COLUMN_HEADER + String.join(csvRowValues,'\n');
            Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = folder.Id, Type = 'csv', ContentType='application/vnd.ms-excel');
            insert doc;

            //send email
            	
			String docUrl = '<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.FileDownload?file='+doc.Id+'">'+ ' ' + 'Click here to download Report'+'</a></html>';			
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //String[] toAddresses = new String[] {'sumit.surve@iqvia.com', 'gulamsabir.khan@iqvia.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject(System.Label.Suspicious_Activity);
            mail.setHtmlBody(System.Label.PES_Email_Body + ' ' + docUrl);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });             
		}
	}

    public override Type getType() {
        return Batch_prepareSuspeciousPEReport.class;
    }
    
    public override virtual String getBatchDescription() {
        return 'Extract RH suspecious participant enrollment history and generate report';
    }
}