/**
 * Created by user on 01.03.2019.
 */

public with sharing class TestController {

    public static String helloMessage {get; set;}

    @AuraEnabled
    public static String getHelloMessage() {
        return 'Hello world';
    }

    public TestController(){
        helloMessage = '1';
    }

}