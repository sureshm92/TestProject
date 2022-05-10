public class ECOADiariesController {
    @AuraEnabled
    public static String getToken() {
        try {
            return ECOAService.getJWTToken();
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled
    public static String getSubjectGuid() {
        try {
            TaskService.getInstance().completeEcoaTaskForParticipant();
            return ECOAService.getSubjectGuid();
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
