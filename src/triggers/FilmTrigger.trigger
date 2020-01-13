/**
 * Created by imasukov on 12/24/2019.
 */

trigger FilmTrigger on Film__c (after undelete) {
    FilmTriggerHandler handler = new FilmTriggerHandler();

    if (Trigger.isUndelete && Trigger.isAfter) {
        handler.onAfterUndeleteUniqueCheck(Trigger.newMap);
    }
}