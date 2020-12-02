global class CreateTACOIAssignmentHandler {
    @InvocableMethod(Label='Create Assignment Records')
    public static void createTAAsignmentRecords(List<COIWrapper> coiWrapperList) {
        if (!coiWrapperList.isEmpty()) {
            if (
                !coiWrapperList[0].chosenConditions.equals('none') &&
                !String.isBlank(coiWrapperList[0].chosenConditions)
            ) {
                List<String> conditionIds = coiWrapperList[0].chosenConditions.split(';');
                List<Therapeutic_Area_Assignment__c> conditionAssignmentsToAdd = new List<Therapeutic_Area_Assignment__c>();
                for (String c : conditionIds) {
                    conditionAssignmentsToAdd.add(
                        new Therapeutic_Area_Assignment__c(
                            Therapeutic_Area__c = Id.valueof(c),
                            Resource__c = Id.valueof(coiWrapperList[0].resourceId)
                        )
                    );
                }
                insert conditionAssignmentsToAdd;
            }
            if (!String.isBlank(coiWrapperList[0].docIds)) {
                List<String> docIdList = coiWrapperList[0].docIds.split(',');
                List<ContentDocumentLink> conDocLinkList = new List<ContentDocumentLink>();
                for (String strDocId : docIdList) {
                    ContentDocumentLink objConDocLink = new ContentDocumentLink(
                        ContentDocumentId = Id.valueof(strDocId),
                        LinkedEntityId = Id.valueof(coiWrapperList[0].resourceId)
                    );
                    conDocLinkList.add(objConDocLink);
                }
                insert conDocLinkList;
            }
        }
    }
    global class COIWrapper {
        @InvocableVariable(required=false)
        global String chosenConditions;

        @InvocableVariable(required=true)
        global String resourceId;

        @InvocableVariable(required=false)
        global String docIds;
    }
}
