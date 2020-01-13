/**
 * Created by imasukov on 12/24/2019.
 */

public with sharing class FilmTriggerHandler implements UniquenessChecker {

    public void onAfterUndeleteUniqueCheck(Map<Id, SObject> newTriggerMap) {
        List<String> filmNamesToUndelete = new List<String>();
        Map<Id, Film__c> newMap = (Map<Id, Film__c>) newTriggerMap;

        for (Id id : newMap.keySet()) {
            filmNamesToUndelete.add(newMap.get(id).Name);
        }
        Map<Id, Film__c> filmsWithSameName = new Map<Id, Film__c>([
                SELECT Name
                FROM Film__c
                WHERE Name IN :filmNamesToUndelete
        ]);
        if (!filmsWithSameName.isEmpty()) {
            List<Film__c> restoredFilms = new List<Film__c>();

            for (Id id : filmsWithSameName.keySet()) {
                if (newMap.keySet().contains(id)) {
                    filmsWithSameName.get(id).Name += '(' + Label.RestoredMessageLabel + ')';
                    restoredFilms.add(filmsWithSameName.get(id));
                }
            }
            update restoredFilms;
        }
    }
}