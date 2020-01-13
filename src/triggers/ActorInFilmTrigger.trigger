/**
 * Created by User on 10.01.2020.
 */

trigger ActorInFilmTrigger on ActorInFilm__c (after insert, after delete) {
    ActorInFilmTriggerHandler handler = new ActorInFilmTriggerHandler();

    if (Trigger.isDelete && Trigger.isAfter) {
        handler.updateCountFilmsOnActor(Trigger.old);
    } else if (Trigger.isInsert && Trigger.isAfter) {
        handler.updateCountFilmsOnActor(Trigger.new);
    }
}