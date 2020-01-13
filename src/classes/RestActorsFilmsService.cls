/**
 * Created by imasukov on 12/26/2019.
 */

@RestResource(UrlMapping = '/actorsFilmsService/*')
global with sharing class RestActorsFilmsService {

    @HttpPost
    global static void upsertActorsInFilms() {
        List<FilmWrapper> receivedFilms = (List<FilmWrapper>)
                JSON.deserialize(RestContext.request.requestBody.toString(), List<FilmWrapper>.class);
        if (receivedFilms.isEmpty()) {
            return;
        }

        List<String> receivedFilmNames = getReceivedFilmNames(receivedFilms);
        List<String> receivedActorNames = getReceivedActorNames(receivedFilms);
        Map<String, Id> filmNameFilmId = getExistingFilms(receivedFilmNames);
        Map<String, Id> actorNameActorId = getExistingActors(receivedActorNames);

        createFilms(receivedFilmNames, filmNameFilmId);
        createActors(receivedActorNames, actorNameActorId);
        createActorsInFilms(receivedFilms, filmNameFilmId, actorNameActorId);
    }

    @HttpDelete
    global static void deleteActorsInFilms() {
        List<FilmWrapper> receivedFilms = (List<FilmWrapper>)
                JSON.deserialize(RestContext.request.requestBody.toString(), List<FilmWrapper>.class);
        if (receivedFilms.isEmpty() || receivedFilms == null) {
            return;
        }
        deleteActorsFromFilms(receivedFilms);
    }

    private static Map<String, Set<String>> getExistingFilmActorSet(List<FilmWrapper> receivedFilms) {
        Map<String, Set<String>> existingFilmNameSetActors = new Map<String, Set<String>>();
        List<ActorInFilm__c> existingActorsInFilms = getExistingActorsInFilms(receivedFilms);
        if (!existingActorsInFilms.isEmpty()) {
            for (ActorInFilm__c actorInFilm : existingActorsInFilms) {
                Set<String> temp = existingFilmNameSetActors.get(actorInFilm.Film__r.Name);
                if (temp == null) {
                    existingFilmNameSetActors.put(actorInFilm.Film__r.Name, new Set<String>{
                            actorInFilm.Actor__r.Name
                    });
                } else {
                    temp.add(actorInFilm.Actor__r.Name);
                }
            }
        }
        return existingFilmNameSetActors;
    }

    private static List<ActorInFilm__c> getExistingActorsInFilms(List<FilmWrapper> receivedFilms) {
        Set<String> existingFilmsWithActorsNames = new Set<String>();
        Set<String> existingActorsOnFilmsNames = new Set<String>();
        for (FilmWrapper filmWrapper : receivedFilms) {
            existingFilmsWithActorsNames.add(filmWrapper.filmName);
            for (ActorWrapper actorWrapper : filmWrapper.actors) {
                existingActorsOnFilmsNames.add(actorWrapper.actorName);
            }
        }
        List<ActorInFilm__c> existingActorsInFilms = [
                SELECT Film__c, Actor__c, Film__r.Name, Actor__r.Name
                FROM ActorInFilm__c
                WHERE Film__r.Name IN :existingFilmsWithActorsNames
                AND Actor__r.Name IN :existingActorsOnFilmsNames
        ];
        return existingActorsInFilms;
    }

    private static void deleteActorsFromFilms(List<FilmWrapper> receivedFilms) {
        List<ActorInFilm__c> actorInFilmToDelete = new List<ActorInFilm__c>();

        Map<String, Set<String>> existingFilmNameSetActors = getExistingFilmActorSet(receivedFilms);
        List<ActorInFilm__c> existingActorsInFilms = getExistingActorsInFilms(receivedFilms);

        for (String filmName : existingFilmNameSetActors.keySet()) {
            for (ActorInFilm__c actorInFilm : existingActorsInFilms) {
                if (existingFilmNameSetActors.get(filmName).contains(actorInFilm.Actor__r.Name)) {
                    if (!actorInFilmToDelete.contains(actorInFilm)) {
                        actorInFilmToDelete.add(actorInFilm);
                    }
                }
            }
        }
        if (!actorInFilmToDelete.isEmpty()) {
            delete actorInFilmToDelete;
        }
    }

    private static void createFilms(List<String> receivedFilmNames, Map<String, Id> filmNameFilmId) {
        List<Film__c> filmsToCreate = new List<Film__c>();

        for (String receivedFilmName : receivedFilmNames) {
            if (receivedFilmName != null && receivedFilmName != '') {
                if (!filmNameFilmId.containsKey(receivedFilmName)) {
                    filmsToCreate.add(new Film__c(Name = receivedFilmName));
                    filmNameFilmId.put(receivedFilmName, null);
                }
            }
        }
        if (!filmsToCreate.isEmpty()) {
            Database.insert(filmsToCreate, false);
            for (Film__c newFilm : filmsToCreate) {
                filmNameFilmId.put(newFilm.Name, newFilm.Id);
            }
        }
    }

    private static void createActors(List<String> receivedActorNames, Map<String, Id> actorNameActorId) {
        List<Actor__c> actorsToCreate = new List<Actor__c>();

        for (String receivedActorName : receivedActorNames) {
            if (receivedActorName != null && receivedActorName != '') {
                if (!actorNameActorId.containsKey(receivedActorName)) {
                    actorsToCreate.add(new Actor__c(Name = receivedActorName));
                    actorNameActorId.put(receivedActorName, null);
                }
            }
        }
        if (!actorsToCreate.isEmpty()) {
            Database.insert(actorsToCreate, false);
            for (Actor__c newActor : actorsToCreate) {
                actorNameActorId.put(newActor.Name, newActor.Id);
            }
        }
    }

    private static void createActorsInFilms(
            List<FilmWrapper> receivedFilms, Map<String, Id> filmNameFilmId, Map<String, Id> actorNameActorId) {
        List<ActorInFilm__c> newActorInFilms = new List<ActorInFilm__c>();
        List<ActorInFilm__c> actorsInFilmsToInsert = new List<ActorInFilm__c>();
        Map<String, Set<String>> filmNameActorInFilm = getExistingFilmActorSet(receivedFilms);
        for (FilmWrapper filmWrapper : receivedFilms) {
            for (ActorWrapper actorWrapper : filmWrapper.actors) {
                if (!filmNameActorInFilm.containsKey(filmWrapper.filmName) ||
                        !filmNameActorInFilm.get(filmWrapper.filmName).contains(actorWrapper.actorName)) {
                    ActorInFilm__c newActorInFilm = new ActorInFilm__c(
                            Film__c = filmNameFilmId.get(filmWrapper.filmName),
                            Actor__c = actorNameActorId.get(actorWrapper.actorName)
                    );
                    newActorInFilms.add(newActorInFilm);
                    Set<String> temp = filmNameActorInFilm.get(filmWrapper.filmName);
                    if (temp == null) {
                        filmNameActorInFilm.put(filmWrapper.filmName, new Set<String>{
                                actorWrapper.actorName
                        });
                    } else {
                        temp.add(actorWrapper.actorName);
                    }
                }
            }
        }
        for (ActorInFilm__c actorInFilm : newActorInFilms) {
            if (actorInFilm.Actor__c != null && actorInFilm.Film__c != null) {
                actorsInFilmsToInsert.add(actorInFilm);
            }
        }
        if (!actorsInFilmsToInsert.isEmpty()) {
            Database.insert(actorsInFilmsToInsert, false);
        }
        if (actorsInFilmsToInsert.size() != newActorInFilms.size()) {
            RestContext.response.statusCode = 206;
        }
    }

    private static List<String> getReceivedFilmNames(List<FilmWrapper> receivedFilms) {
        List<String> receivedFilmNames = new List<String>();

        for (FilmWrapper filmWrapper : receivedFilms) {
            receivedFilmNames.add(filmWrapper.filmName);
        }
        return receivedFilmNames;
    }

    private static List<String> getReceivedActorNames(List<FilmWrapper> receivedFilms) {
        List<String> receivedActorNames = new List<String>();

        for (FilmWrapper filmWrapper : receivedFilms) {
            for (ActorWrapper actorWrapper : filmWrapper.actors) {
                receivedActorNames.add(actorWrapper.actorName);
            }
        }
        return receivedActorNames;
    }

    private static Map<String, Id> getExistingFilms(List<String> receivedFilmNames) {
        Map<String, Id> filmNameFilmId = new Map<String, Id>();

        Map<Id, Film__c> existingFilms = new Map<Id, Film__c>([
                SELECT Name
                FROM Film__c
                WHERE Name IN :receivedFilmNames
        ]);
        if (!existingFilms.isEmpty()) {
            for (Id id : existingFilms.keySet()) {
                filmNameFilmId.put(existingFilms.get(id).Name, id);
            }
        }
        return filmNameFilmId;
    }

    private static Map<String, Id> getExistingActors(List<String> receivedActorNames) {
        Map<String, Id> actorNameActorId = new Map<String, Id>();

        Map<Id, Actor__c> existingActors = new Map<Id, Actor__c>([
                SELECT Name
                FROM Actor__c
                WHERE Name IN :receivedActorNames
        ]);
        if (!existingActors.isEmpty()) {
            for (Id id : existingActors.keySet()) {
                actorNameActorId.put(existingActors.get(id).Name, id);
            }
        }
        return actorNameActorId;
    }

    public with sharing class ActorWrapper {
        public String actorName;
        public ActorWrapper(String actorName) {
            this.actorName = actorName;
        }
    }

    public with sharing class FilmWrapper {
        public String filmName;
        public List<ActorWrapper> actors;
        public FilmWrapper(String filmName, List<ActorWrapper> actors) {
            this.filmName = filmName;
            this.actors = actors;
        }
    }
}