var nplcadModule = angular.module('NPLCAD_App', ['ngStorage', 'ngAnimate', 'ui.bootstrap']);
function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};
function decode_npl(s) {
    if (s) {
        s = s.replace(/\+/g, " ");
    }
    return s;
}

