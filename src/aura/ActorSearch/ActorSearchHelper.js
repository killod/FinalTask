/**
 * Created by imasukov on 1/3/2020.
 */
({
    doInit: function (component) {
        let searchString = component.get('v.searchString');
        this.getFilms(component, searchString);
    },
    getFilms: function (component, searchString) {
        let action = component.get('c.searchActors');
        action.setParams({
            searchString: searchString
        });
        action.setCallback(this, function (response) {
            let event = $A.get( 'e.c:FilmsLoaded' );
            event.setParams({
                films: JSON.parse(response.getReturnValue()).dataTableResponse
            });
            component.set('v.actors', JSON.parse(response.getReturnValue()).actors);
            event.fire();
        });
        $A.enqueueAction(action);
    },
    onSearchStringChange: function (component, event, helper) {
        let searchString = component.get('v.searchString');
        let delayMillis = 400;
        let timeoutId = component.get('v.searchTimeoutId');
        clearTimeout(timeoutId);
        timeoutId = setTimeout($A.getCallback(function () {
            helper.getFilms(component, searchString);
        }), delayMillis);
        component.set('v.searchTimeoutId', timeoutId);
        component.set('v.showDropDown', true);
    },
    optionClickHandler: function (component, event, helper) {
        const selectedId = event.target.closest('li').dataset.value;
        component.set('v.searchString', selectedId);
        component.set('v.showDropDown', false);
        helper.getFilms(component, selectedId);
    }
})