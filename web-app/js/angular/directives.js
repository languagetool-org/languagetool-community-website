'use strict';

/* Directives */

angular.module('ruleEditor.directives', [])
  .directive('ngEnter', function () {
    return function (scope, element, attrs) {
      element.bind("keydown keypress", function (event) {
        if (event.which === 13) {  // Return key
          scope.$apply(function (){
            scope.$eval(attrs.ngEnter);
          });
          event.preventDefault();
        }
      });
    };
  })
  .directive('focusMe', function() {
    return {
      link: function(scope, element, attrs) {
        scope.$watch(attrs.focusMe, function(value) {
          if (value === true) {
            element[0].focus();
            scope[attrs.focusMe] = false;
          }
        });
      }
    };
  });

