/**
 * Created by User on 08.01.2020.
 */

@IsTest
private class FilmTriggerTest {

    @testSetup
    static void testSetup() {
        List<Film__c> films = new List<Film__c>();

        for (Integer i = 0; i < 10; i++) {
            Film__c newFilm = new Film__c(Name = 'TestName_' + i);
            films.add(newFilm);
        }
        insert films;
    }

    @isTest
    static void testUndeleteBehavior() {
        List<Film__c> films = new List<Film__c>();

        List<Film__c> existingFilms = [
                SELECT Name
                FROM Film__c
        ];
        for (Integer i = 0; i < 10; i++) {
            Film__c newFilm = new Film__c(Name = 'TestName_' + i);
            films.add(newFilm);
        }
        Test.startTest();
        delete existingFilms;
        insert films;
        undelete existingFilms;
        Test.stopTest();

        System.assertEquals([SELECT Name FROM Film__c WHERE Name LIKE '%(restored)'].size(),
                existingFilms.size());
    }

}