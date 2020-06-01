/**
 * Created by Sravani Dasari on 5/21/2019.
 */

@IsTest
private class Test_TrialMatchPageRemote {

    @IsTest
    static void getMatchCTPs_test() {
        TrialMatchPageRemote.TrialMatchContainer container = makeTMContainer();
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TrialMatchHelper.class, StubBuilder.newInstance(TrialMatchHelper.class)
                .when('getInitTrialMatchContainer')
                .then(container)
                .build()
        );
        System.assertEquals(1, TrialMatchPageRemote.getMatchCTPs().trialmatchctps.size());
    }

    @IsTest
    static void getMatchCTPsWithException_test() {
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TrialMatchHelper.class, StubBuilder.newInstance(TrialMatchHelper.class)
                .when('getInitTrialMatchContainer')
                .then(new AuraHandledException(''))
                .build()
        );
        try{
            TrialMatchPageRemote.getMatchCTPs();
        } catch (AuraHandledException e){
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        System.assert(true, isExceptionThrown);
    }


    private static TrialMatchPageRemote.TrialMatchContainer makeTMContainer() {
        TestData.loadTestData();
        TestData testData = new TestData();
        TrialMatchPageRemote.TrialMatchContainer container;
        Trial_Match__c tm = new Trial_Match__c(	
				Clinical_Trial_Profile__c = testData.ctp.id,	
				Is_Eligible__c = true,	
				Matched_Date__c = Datetime.now().dateGmt(),	
				Matching_Details__c = 'Sample Matching Details',	
				Matching_Score__c = 77,	
				Participant_Enrollment__c = testData.pe.id,	
				Passed__c = false,	
				Therapeutic_Area__c = 'Therapeutic Area Sample test data'	
		);	
		insert tm;

        System.runAs(testData.participantUser){
            TrialMatchPageRemote.TrialMatchCTP tmd = new TrialMatchPageRemote.TrialMatchCTP();
            tmd.ctp = testData.ctp;
			tmd.trm = tm;
            tmd.isEnrollingCTP = true;
			tmd.ctpid = testData.ctp.id;
			tmd.TherapeuticArea = tm.Therapeutic_Area__c;
            tmd.StudyCodeName = testData.ctp.Study_Code_Name__c;
			tmd.OfficialTitle = 'OT_Virus_101/R/PNHV/FCY/VPY';
			tmd.matchDate = String.valueOf(tm.Matched_Date__c);
            container = new TrialMatchPageRemote.TrialMatchContainer();
            container.trialmatchctps = new List<TrialMatchPageRemote.TrialMatchCTP>{tmd};
        }
        return container;
    }
}