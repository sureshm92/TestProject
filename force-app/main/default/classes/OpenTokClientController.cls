// Class does not enforce sharing rules in order to allow external site usage.
public without sharing class OpenTokClientController {
    // this class is connected to televisit.page to run a session for a participant

    public String apiKey {
        get {
            return TokboxSettings.API_KEY;
        }
        set;
    }
    public String sessionId { get; set; }
    public String sessionName {
        get {
            return session?.Title__c;
        }
        set;
    }
    public String shortName { get; set; }
    public String token { get; set; }
    public String userName { get; set; }
    public String sharingUserName { get; set; }
    public Boolean isSessionJoinable { get; set; }
    public Boolean isExternalUser { get; set; }
    public String attendeeType { get; set; }
    //public TV_Session__c session           { get; set; }
    public Televisit__c session { get; set; }
    public String attendeeEmailAddress { get; set; }
    public Boolean isAttendeeEmailValid { get; set; }
    public String attendeesJson { get; set; }
    public List<Attendee> attendees { get; private set; }
    public static final String SESSION_ID_PARAMETER = 'sessionId';
    public String commTemplate { get; set; }
    public String headerbg { get; set; }

    public static final String[] HTML_DECODED = new List<String>{ '&', '<', '>', '"', '\'' };
    public static final String[] HTML_ENCODED = new List<String>{
        '&amp;',
        '&lt;',
        '&gt;',
        '&quot;',
        '&#39;'
    };
    public String meetingInterval { get; set; }

    //OMSF-5206
    public String appNamestr { get; set; } //Indicates Meeting title Raviteja
    public String bannerEndTime { get; set; }
    public String autoDisconnectMeetingTime { get; set; }
    public String visitDate {get;set;}
    public String userTimeZone {get;set;}
    public List<Televisit__c>  lstTelevisit{get;set;}
    TokBoxSettings2__c settings;
    public Integer endMinutes;

    public OpenTokClientController() {
        //OMSF-5206 Starts
        //OMSF-5611 starts- Bug Fix
        //Commented by Raviteja
        /*Televisit_Page_Configuration__mdt teleVisitPageTitle = Televisit_Page_Configuration__mdt.getInstance('TelevisitPageHeaderTitle');
        if(teleVisitPageTitle!= null) {
            appNamestr = teleVisitPageTitle.Label;
        } else {
            appNamestr = 'IQVIA';
        }*/
        appNamestr = 'IQVIA Referral Hub'; //Added by RAviteja
        headerbg = 'headerbg-rh';
        meetingInterval = '';
        //OMSF-5206 Ends

        this.sessionId = SFDC_HTMLENCODE(getSessionIdFromURL());
        this.isExternalUser = Auth.CommunitiesUtil.isGuestUser();

        Id currentUserId = UserInfo.getUserId();
        /* Commented By Ranjith
        List<TV_Session__c> sessions = Database.query(
            'SELECT Name, Start_Date__c, End_Date__c, Canceled_Date__c, ' +
                    '(SELECT Name, First_Name__c, Last_Name__c FROM Session_Attendees__r '
                        + (!this.isExternalUser ? 'WHERE User__c = :currentUserId' : 'WHERE User__c = null') + ' and IsActive__c=true) ' +
            'FROM TV_Session__c ' +
            'WHERE Session_Id__c = :sessionId ' +
            'ORDER BY CreatedDate DESC ' +
            'LIMIT 1'
        );*/

        lstTelevisit = new List<Televisit__c>();
        lstTelevisit = [
            SELECT
                Id,
                Name,
                Title__c,
                Visit_Date_Time__c,
                Visit_End_Date_Time__c,
                Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                Duration__c,
                (
                    SELECT
                        Id,
                        name,
                        Firstname__c,
                        Lastname__c,
                        Attendee_Type__c,
                        User__r.Contact.Salutation,
                        Contact__c,
                        Televisit__r.Participant_Enrollment__r.Participant__r.Salutation__c
                    FROM Televisit_Attendee__r
                    WHERE User__c = :currentUserId
                )
            FROM Televisit__c
            WHERE Session_Id__c = :sessionId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (!lstTelevisit.isEmpty()) {
            this.session = lstTelevisit.get(0);

            endMinutes = -Integer.valueOf(System.Label.RH_TelevisitWindowBannerStartTime);

            bannerEndTime = String.valueOf(
                    lstTelevisit[0].Visit_End_Date_Time__c.addMinutes(endMinutes).timeGmt()
                )
                .remove('.000Z');
            autoDisconnectMeetingTime = String.valueOf(
                    lstTelevisit[0].Visit_End_Date_Time__c.addMinutes(0).timeGmt()
                )
                .remove('.000Z');
            visitDate = String.valueOf(lstTelevisit[0].Visit_End_Date_Time__c.date());
            userTimeZone = UserInfo.getTimeZone().getID();
            system.debug('this.session.Televisit_Attendee__r :'+this.session.Televisit_Attendee__r);
            if(!this.session.Televisit_Attendee__r.isEmpty()){
                this.isSessionJoinable = getIsSessionJoinable();
                //attendeeType = getAttendeeType(matchingAttendees[0]);
                if (
                    this.session.Televisit_Attendee__r[0].Attendee_Type__c == 'Participant' ||
                    this.session.Televisit_Attendee__r[0].Attendee_Type__c == 'Participant Delegate'
                ) {
                    appNamestr = 'IQVIA Patient Portal';
                    attendeeType = 'PP';

                    commTemplate = this.session.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
                    if (commTemplate == CommunityTemplateService.TEMPLATE_DEFAULT)
                        headerbg = 'headerbg-pp';
                    if (commTemplate == CommunityTemplateService.TEMPLATE_GSK)
                        headerbg = 'headerbg-gsk';
                    if (commTemplate == CommunityTemplateService.TEMPLATE_PP)
                        headerbg = 'headerbg-pp2';
                } else {
                    appNamestr = 'IQVIA Referral Hub';
                    attendeeType = 'RH';
                    headerbg = 'headerbg-rh';
                }
            } else {
                this.isSessionJoinable = false;
            }
        }

        //this.isSessionJoinable = getIsSessionJoinable();
    }

    public PageReference extendedMeetingInterval() {
        system.debug('meetingInterval:' + meetingInterval);
        system.debug('bannerEndTime' + bannerEndTime);
        List<Televisit__c> updatedTelevisit = new List<Televisit__c>();
        updatedTelevisit = [
            SELECT Id, Name, Title__c, Visit_Date_Time__c, Visit_End_Date_Time__c, Duration__c
            FROM Televisit__c
            WHERE Id = :lstTelevisit[0].Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        //system.debug(meetingInterval);
        Televisit__c tvUpdate = new Televisit__c();
        tvUpdate.id = lstTelevisit[0].Id;
        //tvUpdate.Visit_Date_Time__c = updatedTelevisit[0].Visit_Date_Time__c.addMinutes(Integer.valueOf(meetingInterval));
        tvUpdate.Visit_End_Date_Time__c = updatedTelevisit[0].Visit_End_Date_Time__c.addMinutes(Integer.valueOf(meetingInterval));
        update tvUpdate;

        updatedTelevisit = [
            SELECT Id, Name, Title__c, Visit_Date_Time__c, Visit_End_Date_Time__c, Duration__c
            FROM Televisit__c
            WHERE Id = :lstTelevisit[0].Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        bannerEndTime = String.valueOf(
                updatedTelevisit[0].Visit_End_Date_Time__c.addMinutes(endMinutes).timeGmt()
            )
            .remove('.000Z');
        autoDisconnectMeetingTime = String.valueOf(
                updatedTelevisit[0].Visit_End_Date_Time__c.addMinutes(0).timeGmt()
            )
            .remove('.000Z');
        system.debug('bannerEndTime' + bannerEndTime);
        return null;
    }

    /* ESAPI Encoding within Apex Recomended by Salesforce*/
    public String SFDC_HTMLENCODE(String input) {
        return ENCODE(input, HTML_DECODED, HTML_ENCODED);
    }

    public String ENCODE(String input, String[] fromArr, String[] toArr) {
        if (input == null || input.length() == 0)
            return input;

        for (Integer i = 0; i < fromArr.size(); ++i) {
            input = input.replace(fromArr[i], toArr[i]);
        }

        return input;
    }

    // This method exists solely to trigger a Visualforce re-render.
    public void rerenderControllerValues() {
    }

    // This method exists solely to trigger a Visualforce re-render.
    public void updateSharingUserName() {
    }

    // This method exists solely to maintain the active salesforce session during a call
    public void maintainSession() {
    }

    /**
     * Validates that a given email address is associated with an attendee of the current session.
     */
    public void validateAttendeeEmail() {
        if (this.attendeeEmailAddress != null && this.session?.Id != null) {
            Id currentUserId = UserInfo.getUserId();
            String sessionRecordId = this.session?.Id;
            String attendeeEmailAddress = this.attendeeEmailAddress;
            /*Commented By Ranjith
            List<TV_Attendee__c> matchingAttendees = Database.query(
                'SELECT Id, Name, First_Name__c, Last_Name__c ' +
                'FROM TV_Attendee__c ' +
                'WHERE IsActive__c=true' +
                    ' And TV_Session__c = :sessionRecordId ' +
                    (!Auth.CommunitiesUtil.isGuestUser() ? 'AND User__c = :currentUserId ' : 'AND User__c = null ') +
                    'AND Email__c = :attendeeEmailAddress ' +
                'WITH SECURITY_ENFORCED ' +
                'LIMIT 1'
            );
            */
            List<Televisit_Attendee__c> matchingAttendees = new List<Televisit_Attendee__c>();
            //HAve to add more filters
            matchingAttendees = [
                SELECT
                    Id,
                    Name,
                    FirstName__c,
                    LastName__c,
                    Attendee_Type__c,
                    User__r.Contact.Salutation,
                    Contact__c,
                    Televisit__r.Participant_Enrollment__r.Participant__r.Salutation__c
                FROM Televisit_Attendee__c
                WHERE User__c = :currentUserId
                LIMIT 1
            ];

            if (!matchingAttendees.isEmpty()) {
                Id attendeeId = matchingAttendees[0].Id;
                this.userName = getFirstName(matchingAttendees[0]);
                this.token = generateToken(this.sessionId, attendeeId);
                this.isAttendeeEmailValid = true;
                return;
            }
        }

        this.isAttendeeEmailValid = false;
    }

    public void updateAttendees() {
        attendees = (List<Attendee>) JSON.deserialize(attendeesJson, List<Attendee>.class);
        system.debug('========attendees' + attendees);
        Set<Id> attendeeIds = new Set<Id>();
        Map<String, TV_Connection__c> connectionMap = new Map<String, TV_Connection__c>();

        for (Attendee attendee : attendees) {
            attendeeIds.add(attendee.id);
            connectionMap.put(
                attendee.connectionId,
                new TV_Connection__c(
                    Connection_Id__c = attendee.connectionId,
                    Televisit_Attendee__c = attendee.id
                )
            );
        }

        Map<Id, Televisit_Attendee__c> attendeeRecords = new Map<Id, Televisit_Attendee__c>(
            [
                SELECT
                    Name,
                    FirstName__c,
                    LastName__c,
                    Attendee_Type__c,
                    User__r.Contact.Salutation,
                    Contact__c,
                    Televisit__r.Participant_Enrollment__r.Participant__r.Salutation__c,
                    (SELECT Id, Connection_Id__c FROM Connections__r)
                FROM Televisit_Attendee__c
                WHERE Id IN :attendeeIds
            ]
        );

        for (Attendee attendee : attendees) {
            Televisit_Attendee__c attendeeRecord = attendeeRecords.get(attendee.id);
            if (attendeeRecord != null) {
                attendee.name = getName(attendeeRecord);
                for (TV_Connection__c connection : attendeeRecord.Connections__r) {
                    connectionMap.remove(connection.Connection_Id__c);
                }
            }
        }
        system.debug('============>' + connectionMap.values());
        if (!connectionMap.isEmpty()) {
            insert connectionMap.values();
            //Data.create(connectionMap.values(), false, false, false); commented by Raviteja
        }
    }

    @RemoteAction
    public static String getAttendeeName(Id attendeeId) {
        Televisit_Attendee__c attendee = [
            SELECT
                Name,
                FirstName__c,
                LastName__c,
                Attendee_Type__c,
                User__r.Contact.Salutation,
                Contact__c,
                Televisit__r.Participant_Enrollment__r.Participant__r.Salutation__c
            FROM Televisit_Attendee__c
            WHERE Id = :attendeeId
        ];

        return getFirstName(attendee);
    }
    private static String getName(Televisit_Attendee__c attendee) {
        List<String> nameParts = new List<String>();

        if (
            (attendee.Attendee_Type__c == 'PI' || attendee.Attendee_Type__c == 'Site Staff') &&
            (String.isNotBlank(attendee.User__r.Contact.Salutation))
        ) {
            nameParts.add(attendee.User__r.Contact.Salutation);
        } else if (
            (attendee.Attendee_Type__c == 'Participant') &&
            (String.isNotBlank(
                attendee.Televisit__r.Participant_Enrollment__r.Participant__r.Salutation__c
            ))
        ) {
            nameParts.add(
                attendee.Televisit__r.Participant_Enrollment__r.Participant__r.Salutation__c
            );
        } else if (attendee.Attendee_Type__c == 'Participant Delegate') {
            List<Participant__c> participantList = [
                SELECT Id, Contact__c, Salutation__c
                FROM Participant__c
                WHERE Contact__c = :attendee.Contact__c
            ];
            if (participantList != null && !participantList.isEmpty()) {
                if (String.isNotBlank(participantList[0].Salutation__c)) {
                    nameParts.add(participantList[0].Salutation__c);
                }
            }
        }

        if (String.isNotBlank(attendee.FirstName__c)) {
            nameParts.add(attendee.FirstName__c);
        }

        if (String.isNotBlank(attendee.LastName__c)) {
            nameParts.add(attendee.LastName__c);
        }

        String name = (nameParts.isEmpty() ? attendee.Name : String.join(nameParts, ' '));
        return name;
    }

    public static String getFirstName(Televisit_Attendee__c attendee) {
        if (String.isNotBlank(attendee.FirstName__c)) {
            return attendee.FirstName__c;
        } else {
            return attendee.LastName__c;
        }
    }

    /**
     * Helper function to getting the session id parameter from the page.
     */
    private String getSessionIdFromURL() {
        return ApexPages.currentPage().getParameters().get(SESSION_ID_PARAMETER);
    }

    private String generateToken(String sessionId, String attendeeId) {
        OpenTokSession session = new OpenTokSession(
            sessionId,
            TokboxSettings.API_KEY,
            TokboxSettings.API_SECRET
        );
        return session.generateToken(
            new OpenTokTokenOption(OpenTokRoles.PUBLISHER, 30, attendeeId)
        );
    }

    /**
     * Helper function to get whether the session is joinable or not depending
     * on the buffer setting and the start/end date of the session.
     */
    @TestVisible
    private Boolean getIsSessionJoinable() {
        system.debug('++++++++++++++Token' + this.session);
        Id attendeeId = this.session.Televisit_Attendee__r[0].Id;
        this.userName = getFirstName(this.session.Televisit_Attendee__r[0]);
        this.token = generateToken(this.sessionId, attendeeId);
        system.debug('++++++++++++++Token' + this.token);
        return true;
    }

    public class Attendee {
        public Id id { get; set; }
        public String streamId { get; set; }
        public String name { get; set; }
        public String connectionId { get; set; }
    }

    public String[] getExtendMeetingOptions() {
        String[] extendMeetingOptions = System.Label.RH_TelevisitExtendMeetingOptions.split(',');
        return extendMeetingOptions;
    }

    public void fetchUpdatedTelevisitDetails() {
        List<Televisit__c> updatedTelevisit = new List<Televisit__c>();

        updatedTelevisit = [
            SELECT Id, Name, Title__c, Visit_Date_Time__c, Visit_End_Date_Time__c, Duration__c
            FROM Televisit__c
            WHERE Id = :lstTelevisit[0].Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        bannerEndTime = String.valueOf(
                updatedTelevisit[0].Visit_End_Date_Time__c.addMinutes(endMinutes).timeGmt()
            )
            .remove('.000Z');
        autoDisconnectMeetingTime = String.valueOf(
                updatedTelevisit[0].Visit_End_Date_Time__c.addMinutes(0).timeGmt()
            )
            .remove('.000Z');
        //turn null;
    }
}