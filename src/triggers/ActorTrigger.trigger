/**
 * Created by imasukov on 12/26/2019.
 */

trigger ActorTrigger on Actor__c (after undelete) {

    ActorTriggerHandler handler = new ActorTriggerHandler();

    if (Trigger.isUndelete && Trigger.isAfter) {
        handler.onAfterUndeleteUniqueCheck(Trigger.newMap);
    }
}