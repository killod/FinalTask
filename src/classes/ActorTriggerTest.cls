/**
 * Created by User on 09.01.2020.
 */

@IsTest
private class ActorTriggerTest {

    @testSetup
    static void testSetup() {
        List<Actor__c> actors = new List<Actor__c>();
        for (Integer i = 0; i < 10; i++) {
            Actor__c newActor = new Actor__c(Name = 'TestName_' + i);
            actors.add(newActor);
        }
        insert actors;
    }

    @isTest
    static void testUndeleteBehavior() {
        List<Actor__c> existingActors = [
                SELECT Name
                FROM Actor__c
        ];
        List<Actor__c> actors = new List<Actor__c>();
        for (Integer i = 0; i < 10; i++) {
            Actor__c newActor = new Actor__c(Name = 'TestName_' + i);
            actors.add(newActor);
        }

        Test.startTest();
        delete existingActors;
        insert actors;
        undelete existingActors;
        Test.stopTest();

        System.assertEquals([SELECT Name FROM Actor__c WHERE Name LIKE '%(restored)'].size(),
                existingActors.size());
    }
}