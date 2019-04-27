/**
 * Created by AlexKetch on 4/19/2019.
 */

public with sharing class DeploymentContext {

    public static void onInstall() {
        List<PostInstallDX> handlers = getHandlers();
        for (PostInstallDX h : handlers) {
            h.onInstall();
        }
    }
    public static List<PostInstallDX> getHandlers() {
        List<PostInstallDX> dxhandlers = new List<PostInstallDX>();
        List<Post_Install__mdt> isntallInstances = [SELECT HandlerName__c FROM Post_Install__mdt];
        for (Post_Install__mdt m : isntallInstances) {
            PostInstallDX p = (PostInstallDX) Type.forName(m.HandlerName__c).newInstance();
            dxhandlers.add(p);
        }
        return dxhandlers;
    }
}