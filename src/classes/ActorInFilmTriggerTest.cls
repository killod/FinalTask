/**
 * Created by User on 11.01.2020.
 */

@IsTest
private class ActorInFilmTriggerTest {

    @testSetup
    static void testSetup() {
        List<Film__c> films = new List<Film__c>();
        List<Actor__c> actors = new List<Actor__c>();

        for (Integer i = 0; i < 10; i++) {
            films.add(new Film__c(Name = 'TestFilm_' + i));
        }
        for (Integer i = 0; i < 10; i++) {
            actors.add(new Actor__c(Name = 'TestActorName_' + i));
        }
        insert films;
        insert actors;
    }

    @isTest
    static void testInsertBehavior() {
        List<ActorInFilm__c> actorInFilms = new List<ActorInFilm__c>();
        List<ActorInFilm__c> newActorInFilms = new List<ActorInFilm__c>();
        List<Film__c> films = new List<Film__c>();
        List<Actor__c> actors = new List<Actor__c>();
        Integer numberOfFilms = 0;
        Integer numberOfNewActorFilms = 0;

        films = [
                SELECT Name
                FROM Film__c
        ];
        actors = [
                SELECT Name
                FROM Actor__c
                ORDER BY Name
        ];
        for (Integer i = 0; i < 10; i++) {
            actorInFilms.add(new ActorInFilm__c(Film__c = films[i].Id, Actor__c = actors[i].Id));
        }
        numberOfFilms++;
        for (Integer i = 0; i < 9; i++) {
            actorInFilms.add(new ActorInFilm__c(Film__c = films[i+1].Id, Actor__c = actors[i].Id));
        }
        numberOfFilms++;
        Actor__c newActor = new Actor__c(Name = 'QQNewActorName');
        insert newActor;
        for (Integer i = 0; i < 5; i++) {
            actorInFilms.add(new ActorInFilm__c(Film__c = films[i].Id, Actor__c = newActor.Id));
            numberOfNewActorFilms++;
        }
        Test.startTest();
        insert actorInFilms;
        for (Integer i = 5; i < 10; i++) {
            newActorInFilms.add(new ActorInFilm__c(Film__c = films[i].Id, Actor__c = newActor.Id));
            numberOfNewActorFilms++;
        }
        insert newActorInFilms;
        Test.stopTest();

        System.assertEquals([
                SELECT Name, CountFilms__c
                FROM Actor__c
                WHERE Name LIKE 'Test%'
                ORDER BY Name ASC
                LIMIT 1
        ].CountFilms__c, numberOfFilms);
        System.assertEquals([
                SELECT Name, CountFilms__c
                FROM Actor__c
                WHERE Name LIKE 'QQNewActorName'
        ].CountFilms__c, numberOfNewActorFilms);
    }

    @isTest
    static void testDeleteBehavior() {
        List<ActorInFilm__c> actorInFilms = new List<ActorInFilm__c>();
        List<Film__c> films = new List<Film__c>();
        List<Actor__c> actors = new List<Actor__c>();
        Integer numberOfFilms = 0;

        films = [
                SELECT Name
                FROM Film__c
        ];
        actors = [
                SELECT Name
                FROM Actor__c
                ORDER BY Name
        ];
        for (Integer i = 0; i < 10; i++) {
            actorInFilms.add(new ActorInFilm__c(Film__c = films[i].Id, Actor__c = actors[i].Id));
        }
        numberOfFilms++;
        insert actorInFilms;

        Test.startTest();
        delete actorInFilms;
        Integer numberOfFilmsAfterDelete = --numberOfFilms;
        Test.stopTest();

        System.assertEquals([
                SELECT Name, CountFilms__c
                FROM Actor__c
                WHERE Name LIKE 'Test%'
                ORDER BY Name ASC
                LIMIT 1
        ].CountFilms__c, numberOfFilmsAfterDelete);

    }
}