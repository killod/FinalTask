/**
 * Created by imasukov on 1/3/2020.
 */
({
    doInit: function (component, event, helper) {
        helper.doInit(component);
    },
    onSearchStringChange: function (component, event, helper) {
        helper.onSearchStringChange(component, event, helper);
    },
    optionClickHandler: function (component, event, helper) {
        helper.optionClickHandler(component, event, helper);
    },
    onBlurInput: function (component, event, helper) {
        component.set('v.showDropDown', false);
    },
    onFocusInput: function (component, event, helper) {
        component.set('v.showDropDown', !component.get('v.showDropDown'));
    }
})