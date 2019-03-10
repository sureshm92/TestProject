/**
 * Created by AlexKetch on 3/5/2019.
 */

public with sharing class ResourceTriggerHandler extends TriggerHandler {

    public override void beforeInsert(List<SObject> newList) {
        ArticleService.calculateExpirationDate(newList);
    }
}