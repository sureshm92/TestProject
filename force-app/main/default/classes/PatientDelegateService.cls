/**
 * Created by Leonid Bartenev
 */

public without sharing class PatientDelegateService {
    
    public class PatientDelegateServiceException extends Exception {}
    
    private List<Contact> delegates = new List<Contact>();
    private Boolean isDelegate;
    private Participant__c participant;
    
    private static PatientDelegateService instance;
    
    public static PatientDelegateService getInstance(){
        if(instance == null) instance = new PatientDelegateService();
        return instance;
    }
    
    public static void setMock(StubProvider stubProvider){
        instance = (PatientDelegateService) Test.createStub(PatientDelegateService.class, stubProvider);
    }
    
    public PatientDelegateService(){
        List<Patient_Delegate__c> participantsPDList = DatabaseService.query(
                new List<String>{
                        'Id',
                        'Participant__r.Full_Name__c',
                        'Participant__r.Contact__c',
                        'Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c',
                        'Participant__r.First_Name__c',
                        'Participant__r.Last_Name__c',
                        'Contact__c'
                },
                Patient_Delegate__c.getSObjectType(),
                DatabaseService.fieldEqual('Contact__c', CommunityService.getInstance().getCurrentContactId())
        );
        isDelegate = participantsPDList.size() > 0;
        if (isDelegate) {
            participant = participantsPDList[0].Participant__r;
        } else {
            List<Participant__c> participants = DatabaseService.query(
                    new List<String>{
                            'Id',
                            'First_Name__c',
                            'Last_Name__c',
                            'Full_Name__c',
                            'Contact__c',
                            'Contact__r.Participant_Opt_In_Status_Emails__c'
                    },
                    Participant__c.getSObjectType(),
                    DatabaseService.fieldEqual('Contact__c', CommunityService.getInstance().getCurrentContactId())
            );
            if(participants.size() > 0) participant = participants[0];
        }
        if(participant != null){
            List<Patient_Delegate__c> delegatesPDList = getPDelegates(participant.Contact__c);
            for (Patient_Delegate__c pd : delegatesPDList) delegates.add(pd.Contact__r);
        }
    }
    
    public List<Contact> getDelegates(){
        return delegates;
    }

    public Contact getDelegateContact(Id contactId) {
        Contact delegate;
        for(Contact con : getDelegates()) {
            if(con.Id == contactId) delegate = con;
        }
        if(delegate == null) throw new PatientDelegateServiceException('Wrong id');

        return delegate;
    }
    
    public Participant__c getParticipant(){
        return participant;
    }
    
    public Boolean isDelegate(){
        return isDelegate;
    }
    
    public Id getParticipantUserId(){
        List<User> users = DatabaseService.query(
                'SELECT Id FROM User WHERE ' + DatabaseService.fieldEqual('ContactId', participant.Contact__c) + ' LIMIT 1'
        );
        if (users.isEmpty()) {
            throw new PatientDelegateServiceException('No user found for participant: '
                    + participant.First_Name__c + ' ' + participant.Last_Name__c);
        }
        return users[0].Id;
    }
    
    public List<Patient_Delegate__c> getPDelegates(){
        return getPDelegates(CommunityService.getInstance().getCurrentContactId());
    }
    
    public List<Patient_Delegate__c> getPDelegates(Id participantContactId){
        return DatabaseService.query(
                new List<String>{
                        'Id',
                        'Participant__c',
                        'Participant__r.Contact__c',
                        'Participant__r.Contact__r.Name',
                        'Contact__c',
                        'Contact__r.Name',
                        'Contact__r.FirstName',
                        'Contact__r.LastName',
                        'Contact__r.Email',
                        'Contact__r.Participant_Opt_In_Status_Emails__c',
                        'Contact__r.HCP_Opt_In_Patient_Status_Emails__c',
                        'Contact__r.HCP_Opt_In_Study_Emails__c',
                        'Contact__r.HCP_Opt_In_Referral_Status_Emails__c'
                },
                Patient_Delegate__c.getSObjectType(),
                DatabaseService.fieldEqual('Participant__r.Contact__c', participantContactId)
        );
    }
    
    public List<Id> getDelegatedUsersIds() {
        Map<Id, SObject> usersMap = new Map<Id, SObject>(
                DatabaseService.query('SELECT Id FROM User WHERE ' + DatabaseService.fieldIn('ContactId', delegates))
        );
        return new List<Id>(usersMap.keySet());
    }
    
    public List<Contact> getDelegateContacts(Id participantContactId) {
        List<Contact> contacts = new List<Contact>();
        for (Patient_Delegate__c pd : getPDelegates(participantContactId)) contacts.add(pd.Contact__r);
        return contacts;
    }
    
    public List<Id> getDelegatedContactIds() {
        return SObjectHelper.toIdsList(delegates);
    }
    
    public List<Id> getDelegatedContactIds(Id participantContactId) {
        return SObjectHelper.toIdsList(getDelegateContacts(participantContactId));
    }

    public void createPatientDelegate(Contact newDelegate) {
        if (getDelegatedContactIds().contains(newDelegate.Id)) {
            throw new PatientDelegateServiceException(Label.PG_PST_L_Delegates_WrongAdd);
        }
        List<Participant__c> participant = DatabaseService.getInstance().queryImpl(
                new List<String>{'Id'},
                Participant__c.getSObjectType(),
                DatabaseService.fieldEqual('Contact__c', CommunityService.getUserContact().Id)
        );
        
        if (participant.size() == 0) {
            throw new PatientDelegateServiceException('Wrong contact: ' + CommunityService.getUserContact().Id);
        }

        Patient_Delegate__c delegate = new Patient_Delegate__c(
                Contact__c = newDelegate.Id,
                Participant__c = participant.get(0).Id
        );
        insert delegate;
    }
    
    public void resetDelegate(Id contactId) {
        Contact delegateContact = new Contact(
                Id = contactId,
                userCommunityMode__c = null,
                userCommunytyType__c = null
        );
        update delegateContact;

        List<Patient_Delegate__c> patientDelegate = [
                SELECT Id
                FROM Patient_Delegate__c
                WHERE Contact__c =: contactId
        ];
        delete patientDelegate;
    }
}

