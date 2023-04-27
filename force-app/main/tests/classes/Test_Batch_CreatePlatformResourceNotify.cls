/**
 * Created by Sandeep on 21.04.2023.
 */
@IsTest
public with sharing class Test_Batch_CreatePlatformResourceNotify {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void testBehavior() {
        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContentDocumentLinkTriggerHandler.class,
            TriggerOperation.AFTER_INSERT
        );

        Resource__c resource = new Resource__c(
            Content_Type__c = 'Study_Document',
            Description__c = 'testBehavior',
            document_type__c = 'Document',
            Title__c = 'TestRes'
        );
        insert resource;
        Resource__c linkResource = new Resource__c(
            Content_Type__c = 'Relevant_Link',
            Description__c = 'testBehavior',
            Title__c = 'TestRes',
            Languages__c = 'en_US',
            Type__c = 'Helpful Links',
            URL__c = 'rlev.com'
        );
        insert linkResource;
        Resource__c videoResource = new Resource__c(
            Content_Type__c = 'Video',
            Description__c = 'testBehavior',
            Title__c = 'TestRes',
            Content_Class__c = 'Study-Specific',
            Resource_Type__c = 'Study Document'
        );
        insert videoResource;

        Resource__c newResource = new Resource__c(
            article_external_link__c = 'https://www.clinicalresearch.com/potential-participants/articles/HealthDayArticle?actid=739845',
            ArticleID__c = '739845',
            Content_Class__c = '3rd Party',
            Content_Type__c = 'Article',
            Title__c = 'Health Highlights: Nov. 20, 2018',
            Body__c = '<p>Here are some of the latest health and medical news developments, compiled by the editors of HealthDay:</p><p><span class="subhead"><b>Vaccine-Exempt Students Behind N.C. Chickenpox Outbreak</b></span></p><p>North Carolina\'s largest chickenpox outbreak in decades is centered in a primary school with a large number of vaccine-exempt students, according to health officials.</p><p>Thirty-six students at Asheville Waldorf School were diagnosed with the disease last Friday, <i>BBC News</i> reported.</p><p>The school has one of the state\'s highest rates of religious-based vaccine exemptions for students.</p><p>Of the school\'s 152 students, 110 have not received the vaccine against the virus that causes chickenpox, according to <i>BBC News</i>.</p><p>In 2017/18, nearly 68 percent of the school\'s kindergarten students had religious immunization exemptions on file.</p><p>"This is the biggest chickenpox outbreak state health officials are aware of since the vaccine became available," a state health department spokesman told <i>BBC News</i>.</p><p>The school is co-operating with local health officials and is compliant with all state laws, a school spokesperson said.</p><p>-----</p><p><span class="subhead"><b>CDC Creates   Task Force to Track Polio-Like Disease</b></span></p><p>A task force to investigate a rising number of cases of a rare polio-like disease among children in the United States has been created by the U.S. Centers for Disease Control and Prevention.</p><p>The task force on acute flaccid myelitis (AFM) will include scientific, medical and public health experts who will attempt to identify the cause of the disease and improve patient treatment and outcomes.</p><p>AFM affects the spinal cord, causing weakness in one or more limbs. The United States has seen an increased number of AFM cases since 2014, mostly in children. There have been 106 confirmed cases of AFM in 29 states in 2018. All but five have been in children aged 18 or younger, according to the CDC.</p><p>"This task force will ensure that the full capacity of the scientific community is engaged and working together to provide important answers and solutions to actively detect, more effectively treat, and ultimately prevent AFM and its consequences," CDC Director Dr. Robert Redfield said in an agency news release.</p><p>The task force will make key recommendations  on how to respond to the rising number of AFM cases.</p><p>The task force plans to submit its first report at a Dec. 6 public meeting in Atlanta, the CDC said.</p><p>-----</p><p><span class="subhead"><b>Cap\'n Crunch Cereal Recalled Due to Salmonella Scare</b></span></p><p>A small number of boxes of Cap\'n Crunch\'s Peanut Butter Crunch are being recalled due to potential salmonella contamination, Quaker Oats says.</p><p>The recall is for 21 boxes bought after Nov. 5 at Super Target Stores in Omaha and Lincoln. Neb., and in Wichita, Kansas, and at P-Fresh stores in St. Louis and Blue Springs, Missouri.</p><p>The 17.1 ounce boxes have the UPC code 0 30000 6211 1 and Best Before Dates of JUL 30 19 or JUL 31 19.</p><p>No illnesses related to the products have been reported, according to the company.</p><p>The recalled cereal should be thrown away or returned to the store for a refund. For more information, consumers can call 1-800-234-6281.</p><p>Salmonella can cause serious and sometimes fatal infections in young children, frail or elderly people, and others with weakened immune systems. In healthy people, salmonella typically causes fever, diarrhea (which may be bloody), nausea, vomiting and abdominal pain.</p>'
        );
        insert newResource;

        Resource__c newLinkResource = new Resource__c(
            article_external_link__c = 'https://www.clinicalresearch.com/potential-participants/articles/HealthDayArticle?actid=739845',
            Content_Type__c = 'Relevant_Link',
            URL__c = 'google.com',
            Title__c = 'Health Highlights: Nov. 20, 2018',
            Body__c = '<p>Here are some of the latest health and medical news developments, compiled by the editors of HealthDay:</p><p><span class="subhead"><b>Vaccine-Exempt Students Behind N.C. Chickenpox Outbreak</b></span></p><p>North Carolina\'s largest chickenpox outbreak in decades is centered in a primary school with a large number of vaccine-exempt students, according to health officials.</p><p>Thirty-six students at Asheville Waldorf School were diagnosed with the disease last Friday, <i>BBC News</i> reported.</p><p>The school has one of the state\'s highest rates of religious-based vaccine exemptions for students.</p><p>Of the school\'s 152 students, 110 have not received the vaccine against the virus that causes chickenpox, according to <i>BBC News</i>.</p><p>In 2017/18, nearly 68 percent of the school\'s kindergarten students had religious immunization exemptions on file.</p><p>"This is the biggest chickenpox outbreak state health officials are aware of since the vaccine became available," a state health department spokesman told <i>BBC News</i>.</p><p>The school is co-operating with local health officials and is compliant with all state laws, a school spokesperson said.</p><p>-----</p><p><span class="subhead"><b>CDC Creates   Task Force to Track Polio-Like Disease</b></span></p><p>A task force to investigate a rising number of cases of a rare polio-like disease among children in the United States has been created by the U.S. Centers for Disease Control and Prevention.</p><p>The task force on acute flaccid myelitis (AFM) will include scientific, medical and public health experts who will attempt to identify the cause of the disease and improve patient treatment and outcomes.</p><p>AFM affects the spinal cord, causing weakness in one or more limbs. The United States has seen an increased number of AFM cases since 2014, mostly in children. There have been 106 confirmed cases of AFM in 29 states in 2018. All but five have been in children aged 18 or younger, according to the CDC.</p><p>"This task force will ensure that the full capacity of the scientific community is engaged and working together to provide important answers and solutions to actively detect, more effectively treat, and ultimately prevent AFM and its consequences," CDC Director Dr. Robert Redfield said in an agency news release.</p><p>The task force will make key recommendations  on how to respond to the rising number of AFM cases.</p><p>The task force plans to submit its first report at a Dec. 6 public meeting in Atlanta, the CDC said.</p><p>-----</p><p><span class="subhead"><b>Cap\'n Crunch Cereal Recalled Due to Salmonella Scare</b></span></p><p>A small number of boxes of Cap\'n Crunch\'s Peanut Butter Crunch are being recalled due to potential salmonella contamination, Quaker Oats says.</p><p>The recall is for 21 boxes bought after Nov. 5 at Super Target Stores in Omaha and Lincoln. Neb., and in Wichita, Kansas, and at P-Fresh stores in St. Louis and Blue Springs, Missouri.</p><p>The 17.1 ounce boxes have the UPC code 0 30000 6211 1 and Best Before Dates of JUL 30 19 or JUL 31 19.</p><p>No illnesses related to the products have been reported, according to the company.</p><p>The recalled cereal should be thrown away or returned to the store for a refund. For more information, consumers can call 1-800-234-6281.</p><p>Salmonella can cause serious and sometimes fatal infections in young children, frail or elderly people, and others with weakened immune systems. In healthy people, salmonella typically causes fever, diarrhea (which may be bloody), nausea, vomiting and abdominal pain.</p>'
        );
        insert newLinkResource;

        Therapeutic_Area__c newTA = new Therapeutic_Area__c(Name = 'Cancer');
        insert newTA;

        Therapeutic_Area_Assignment__c taaObj = new Therapeutic_Area_Assignment__c();
        taaObj.Resource__c = newResource.Id;
        taaObj.Therapeutic_Area__c = newTA.Id;

        insert taaObj;

        Therapeutic_Area_Assignment__c taaLinkObj = new Therapeutic_Area_Assignment__c();
        taaLinkObj.Resource__c = newLinkResource.Id;
        taaLinkObj.Therapeutic_Area__c = newTA.Id;

        insert taaLinkObj;

        Therapeutic_Area_Assignment__c taaLinkObj2 = new Therapeutic_Area_Assignment__c();
        taaLinkObj2.Resource__c = newResource.Id;
        taaLinkObj2.Therapeutic_Area__c = newTA.Id;

        insert taaLinkObj2;

        Therapeutic_Area_Assignment__c taaLinkObj3 = new Therapeutic_Area_Assignment__c();
        taaLinkObj3.Resource__c = newLinkResource.Id;
        taaLinkObj3.Therapeutic_Area__c = newTA.Id;

        insert taaLinkObj3;

        TestData testData = new TestData();
        Therapeutic_Area_Patient__c tap = new Therapeutic_Area_Patient__c();
        tap.Therapeutic_Area__c = newTA.Id;
        tap.Participant__c = testData.participant.Id;
        tap.Condition_Of_Interest_Order__c = 0;
        insert tap;

        Test.startTest();

        Batch_CreatePlatformResourceNotification batchInstance = new Batch_CreatePlatformResourceNotification();
        Database.executeBatch(batchInstance);
        batchInstance.getBatchDescription();
        batchInstance.getRecommendedIntervalMode();
        batchInstance.getRecommendedRelaunchInterval();
        Test.stopTest();
    }
}
