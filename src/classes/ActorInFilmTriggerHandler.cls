/**
 * Created by User on 10.01.2020.
 */

public with sharing class ActorInFilmTriggerHandler {
    public void updateCountFilmsOnActor(List<ActorInFilm__c> actorsInFilms) {
        Map<Id, Integer> actorCounter = new Map<Id, Integer>();
        List<Id> actorsIds = new List<Id>();
        List<Actor__c> actors = new List<Actor__c>();

        for (ActorInFilm__c actorInFilm : actorsInFilms) {
            actorsIds.add(actorInFilm.Actor__c);
            if (actorCounter.get(actorInFilm.Actor__c) == null) {
                actorCounter.put(actorInFilm.Actor__c,1);
            } else {
                actorCounter.put(actorInFilm.Actor__c, actorCounter.get(actorInFilm.Actor__c)+1);
            }
        }
        actors = [
                SELECT Name, CountFilms__c
                FROM Actor__c
                WHERE Id IN :actorsIds
        ];
        if (Trigger.isDelete && Trigger.isAfter) {
            for (Actor__c actor : actors) {
                if (actor.CountFilms__c != null && actor.CountFilms__c > 0) {
                    actor.CountFilms__c -= actorCounter.get(actor.Id);
                }
            }
        } else if (Trigger.isInsert && Trigger.isAfter) {
            for (Actor__c actor : actors) {
                if (actor.CountFilms__c == null) {
                    actor.CountFilms__c = actorCounter.get(actor.Id);
                } else {
                    actor.CountFilms__c += actorCounter.get(actor.Id);
                }
            }
        }
        update actors;
    }
}