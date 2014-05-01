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
  })

  .directive('postagHelp', ['$parse', 'PostagHelper', function($parse, postagHelper) {
    var updateHelpView =  function(scope, value) {
      var languageConfig = postagHelper.tagMapping[scope.language.code];
      var map = languageConfig.tags;
      var matcher = new RegExp("[^" + languageConfig.posTagChars + "]+", "g");
      var highlightTags = value.split(matcher);
      var result = [];
      for (var idx in map) {
        if (map.hasOwnProperty(idx)) {
          var title = map[idx].replace(/.*\((.*)\)/, "$1");
          result.push(
            {
              tag: idx,
              name: map[idx].replace(/\(.*\)/, ""),
              title: title ? title : null,
              highlight: highlightTags.indexOf(idx) !== -1
            });
        }
      }
      var changed = !angular.equals(result, scope.gui.posTagHelp);
      if (changed) {  // needed optimization so typing doesn't slow down
        scope.gui.posTagHelp = result;
        scope.gui.posTagHelpText = languageConfig.text;
      }
    };
    return {
      link: function(scope, element, attrs) {
        var model = $parse(attrs.postagHelp);
        scope.$watch(model, function(value) {
          updateHelpView(scope, value);
        });
        element.bind('focus', function(event) {  // also update view when switching between different POS tag fields
          updateHelpView(scope, event.target.value);
        });
      }
    }
  }])

  .directive('autocomplete', ['Autocompleter', function (autocompleter) {
    
    // See http://stackoverflow.com/questions/12959516/problems-with-jquery-autocomplete-angularjs?rq=1
    // and http://jqueryui.com/resources/demos/autocomplete/multiple.html 
    
    return {
      restrict: "A",
      require: '?ngModel',
      link: function (scope, elem, attr, ngModel) {
        elem.autocomplete({

          minLength: 0,

          source: function (searchTerm, response) {
            var cursorPosition = elem[0].selectionStart;
            var autocompleteResults = autocompleter.search(searchTerm.term, cursorPosition, scope.language.code);
            if (autocompleteResults === null) {
              response();
            } else {
              response($.map(autocompleteResults, function (autocompleteResult) {
                return {
                  value: autocompleteResult
                }
              }));
            }
          },
          
          select: function (event, selectedItem) {
            var newValue = autocompleter.select(event, selectedItem, elem);
            // this doesn't work because it sets the same 'new' value again and again:
            /*elem.on('blur keyup change', function() {
              // see http://docs.angularjs.org/api/ng/type/ngModel.NgModelController
              scope.$apply(function() {
                console.log("SET");
                ngModel.$setViewValue(newValue);
              });
            });*/
            scope.$eval(attr.ngModel + " = '" + newValue + "'");
            scope.$apply();
            event.preventDefault();
            return false;
          },

          focus: function() {
            // prevent value inserted on focus
            return false;
          }
          
        });
      }
    };
  }
  
]);
