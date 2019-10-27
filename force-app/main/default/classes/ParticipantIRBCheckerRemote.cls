/**
 * Created by Igor Malyuta on 02.09.2019.
 */

public without sharing class ParticipantIRBCheckerRemote {

    @AuraEnabled
    public static IRBParticipantService.IRBModeWrapper checkLanguagePermissions(Id peId) {
        try {
            return IRBParticipantService.getIRBLanguageMode(peId);
        } catch (Exception e) {
            return (IRBParticipantService.IRBModeWrapper) AuraHelper.throwException(e);
        }
    }
}