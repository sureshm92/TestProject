public class ECOADiariesController {
    @AuraEnabled
    public static String getToken() {
        try {
            ECOAService.getJWTToken();
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
