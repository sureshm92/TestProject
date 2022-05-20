/**
 * Created by Dmitry Ivakhnenko
 */

@IsTest
private class Test_ResourcesDetailRemote {
    @isTest Public Static Void Test_ResourcesDetailRemoteMethod(){
        String resourceId = TestDataFactory.getFakeId(Resource__c.getSObjectType());
        String resourceType = 'Study_Document';
        Boolean exceptionOccurred = false;
        try{
        	ResourcesDetailRemote.getResourcesById(resourceId,resourceType);   
        }catch(Exception e){
             exceptionOccurred = true;
        }
    }
}