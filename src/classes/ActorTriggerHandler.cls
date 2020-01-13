/**
 * Created by imasukov on 12/26/2019.
 */

public with sharing class ActorTriggerHandler implements UniquenessChecker{

    public void onAfterUndeleteUniqueCheck(Map<Id, SObject> newTriggerMap) {
        List<String> actorNamesToUndelete = new List<String>();
        Map<Id, Actor__c> newMap = (Map<Id, Actor__c>) newTriggerMap;

        for (Id id : newMap.keySet()) {
            actorNamesToUndelete.add(newMap.get(id).Name);
        }
        Map<Id, Actor__c> actorsWithSameName = new Map<Id, Actor__c>([
                SELECT Name
                FROM Actor__c
                WHERE Name IN :actorNamesToUndelete
        ]);
        if (!actorsWithSameName.isEmpty()) {
            List<Actor__c> restoredActors = new List<Actor__c>();

            for (Id id : actorsWithSameName.keySet()) {
                if (newMap.keySet().contains(id)) {
                    actorsWithSameName.get(id).Name += '(' + Label.RestoredMessageLabel + ')';
                    restoredActors.add(actorsWithSameName.get(id));
                }
            }
            update restoredActors;
        }
    }
}