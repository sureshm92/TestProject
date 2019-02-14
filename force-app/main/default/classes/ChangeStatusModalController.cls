/**
 * Created by D.Yasinskyi on 17.05.2018
 */
public without sharing class ChangeStatusModalController {

    //DEPRECATED TODO:Remove

//    @AuraEnabled
//    public static String getEnrollmentReasonOptions() {
//        return JSON.serialize(HCPEnrollmentService.HCP_CHANGE_STATUS_RESAONS);
//    }
//
//    @AuraEnabled
//    public static void changeHCPEnrollmentStatus(String HCPEnrollmentId, String userMode, String newStatus, String value) {
//        Savepoint sp = Database.setSavepoint();
//        try {
//            HCPEnrollmentService.changeStatus(HCPEnrollmentId, userMode, newStatus, value);
//        } catch (Exception ex) {
//            Database.rollback(sp);
//            throw new AuraHandledException(ex.getMessage() + '/' );
//        }
//    }
}