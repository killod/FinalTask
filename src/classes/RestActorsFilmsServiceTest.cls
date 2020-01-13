/**
 * Created by User on 09.01.2020.
 */

@isTest
private class RestActorsFilmsServiceTest {
    @testSetup
    static void testSetup() {
        RestRequest request = new RestRequest();
        request.requestURI = 'https://yourInstance.salesforce.com/services/apexrest/actorsFilmsService/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('[{"filmName":"King of Thieves","actors":[{"actorName":"Bob"}]},' +
                '{"filmName":"Dunkirk","actors":[{"actorName":"Michael Caine"},{"actorName":"Fionn Whitehead"}]},' +
                '{"filmName":"Ronin","actors":[{"actorName":"Robert De Niro"},{"actorName":"Jean Reno"}]}]');
        RestContext.request = request;
        RestActorsFilmsService.upsertActorsInFilms();
    }

    @isTest
    static void testPostMethodPositive() {
        Set<String> actorNames = new Set<String>();

        RestRequest request = new RestRequest();
        request.requestURI = 'https://yourInstance.salesforce.com/services/apexrest/actorsFilmsService/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('[{"filmName":"King of Thieves","actors":[{"actorName":"Bob"}]},' +
                '{"filmName":"Dunkirk","actors":[{"actorName":"Michael Caine"},{"actorName":"Fionn Whitehead"}]},' +
                '{"filmName":"Ronin","actors":[{"actorName":"Robert De Niro"},{"actorName":"Jean Reno"}]}]');
        RestContext.request = request;
        List<RestActorsFilmsService.FilmWrapper> films = (List<RestActorsFilmsService.FilmWrapper>)
                JSON.deserialize(RestContext.request.requestBody.toString(), List<RestActorsFilmsService.FilmWrapper>.class);
        Integer numberOfFilmsToCreate = films.size();
        Integer numberOfActorsInFilms = 0;
        for (RestActorsFilmsService.FilmWrapper filmWrapper : films) {
            for (RestActorsFilmsService.ActorWrapper actorWrapper : filmWrapper.actors) {
                actorNames.add(actorWrapper.actorName);
                numberOfActorsInFilms++;
            }
        }
        Integer numberOfActorsToCreate = actorNames.size();

        Test.startTest();
        RestActorsFilmsService.upsertActorsInFilms();
        Test.stopTest();

        System.assertEquals(numberOfFilmsToCreate, [
                SELECT COUNT()
                FROM Film__c
        ]);
        System.assertEquals(numberOfActorsToCreate, [
                SELECT COUNT()
                FROM Actor__c
                WHERE Name IN :actorNames
        ]);
        System.assertEquals(numberOfActorsInFilms, [
                SELECT COUNT()
                FROM ActorInFilm__c
        ]);
    }

    @isTest
    static void testDeleteMethodPositive() {
        Set<String> actorNames = new Set<String>();

        RestRequest requestPost = new RestRequest();
        requestPost.requestURI = 'https://yourInstance.salesforce.com/services/apexrest/actorsFilmsService/';
        requestPost.httpMethod = 'DELETE';
        requestPost.requestBody = Blob.valueOf('[{"filmName":"King of Thieves","actors":[{"actorName":"Bob"}]},' +
                '{"filmName":"Dunkirk","actors":[{"actorName":"Michael Caine"},{"actorName":"Fionn Whitehead"}]},' +
                '{"filmName":"Ronin","actors":[{"actorName":"Robert De Niro"},{"actorName":"Jean Reno"}]}]');
        RestContext.request = requestPost;
        List<RestActorsFilmsService.FilmWrapper> films = (List<RestActorsFilmsService.FilmWrapper>)
                JSON.deserialize(RestContext.request.requestBody.toString(), List<RestActorsFilmsService.FilmWrapper>.class);
        Integer numberOfFilmsToCreate = films.size();
        Integer numberOfActorsInFilms = 0;
        for (RestActorsFilmsService.FilmWrapper filmWrapper : films) {
            for (RestActorsFilmsService.ActorWrapper actorWrapper : filmWrapper.actors) {
                actorNames.add(actorWrapper.actorName);
            }
        }
        Integer numberOfActorsToCreate = actorNames.size();

        Test.startTest();
        RestActorsFilmsService.deleteActorsInFilms();
        Test.stopTest();

        System.assertEquals(numberOfFilmsToCreate, [
                SELECT COUNT()
                FROM Film__c
        ]);
        System.assertEquals(numberOfActorsToCreate, [
                SELECT COUNT()
                FROM Actor__c
                WHERE Name IN :actorNames
        ]);
        System.assertEquals(numberOfActorsInFilms, [
                SELECT COUNT()
                FROM ActorInFilm__c
        ]);
    }
}