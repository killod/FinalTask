/**
 * Created by imasukov on 1/3/2020.
 */
({
    doInit: function(component){
        component.set('v.columns', [
            {label: 'Film', fieldName: 'filmName', type: 'text'},
            {label: 'Actors', fieldName: 'actorsInFilm', type: 'text'}
        ]);
    },
    onFilmsLoaded: function (component, event) {
        component.set('v.films', event.getParam('films'));
    }
})