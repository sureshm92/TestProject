/**
 * Created by Leonid Bartenev
 */

public class HomePageParticipantRemote {
    
    @AuraEnabled
    public static String getInitData(){
        try{
            return JSON.serialize(ParticipantService.getInstance().getState());
        }catch (Exception e){
             return (String) AuraHelper.throwException(e);
        }
    }
}