/**
 * Created by imasukov on 1/3/2020.
 */

public with sharing class ActorSearchController {
    @AuraEnabled
    public static String searchActors(String searchString) {
        DataResponse response = new DataResponse();
        List<ActorInFilm__c> actorInFilms = new List<ActorInFilm__c>();
        Set<String> actorsWithFilms = new Set<String>();
        Map<String, Set<String>> filmNameActorInFilm = new Map<String, Set<String>>();
        actorInFilms = [
                SELECT Film__r.Name, Actor__r.Name
                FROM ActorInFilm__c
        ];
        for (ActorInFilm__c actorInFilm : actorInFilms) {
            Set<String> temp = filmNameActorInFilm.get(actorInFilm.Film__r.Name);
            if (temp == null) {
                filmNameActorInFilm.put(actorInFilm.Film__r.Name, new Set<String>{
                        actorInFilm.Actor__r.Name
                });
            } else {
                temp.add(actorInFilm.Actor__r.Name);
            }
        }
        for (String film : filmNameActorInFilm.keySet()) {
            actorsWithFilms.addAll(filmNameActorInFilm.get(film));
            String actorsString = '';
            Integer counter = 0;
            for (String actor : filmNameActorInFilm.get(film)) {
                if (actor.containsIgnoreCase(searchString)) {
                    counter++;
                    response.actors.add(actor);
                }
            }
            if (counter > 0) {
                for (String actor : filmNameActorInFilm.get(film)) {
                    actorsString += actor + ', ';
                }
                actorsString = actorsString.removeEnd(', ');
                response.dataTableResponse.add(new DataTableResponse(film, actorsString));
            }
        }
        return JSON.serialize(response);
    }

    public class DataTableResponse {
        @AuraEnabled
        public String filmName { get; set; }
        @AuraEnabled
        public String actorsInFilm { get; set; }

        public DataTableResponse(String filmName, String actorsInFilm) {
            this.filmName = filmName;
            this.actorsInFilm = actorsInFilm;
        }
    }

    public class DataResponse {
        @AuraEnabled
        public List<DataTableResponse> dataTableResponse { get; set; }
        @AuraEnabled
        public Set<String> actors { get; set; }

        public DataResponse() {
            dataTableResponse = new List<ActorSearchController.DataTableResponse>();
            actors = new Set<String>();
        }
    }

}