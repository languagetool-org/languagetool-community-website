/* LanguageTool Community Website 
 * Copyright (C) 2014 Daniel Naber (http://www.danielnaber.de)
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
 * USA
 */
'use strict';

/* POS tag auto-completion service */

var autocompleterService = angular.module('ruleEditor.autocompleterServices', []);

autocompleterService.factory('Autocompleter',
  function() {
    return {

      // Note: this mapping comes from attributes-en.xsd:
      tagMapping: {
        en: {
          pos: [
            'SENT_START',
            'SENT_END',
            'symbol',
            'conjunction',
            'number',
            'determiner',
            'existential_there',
            'adjective',
            'verb',
            'noun',
            'determiner',
            'pronoun',
            'adverb',
            'particle',
            'to',
            'interjection',
            'unknown'],
          tense: ['baseform', 'simple_past', 'progressive', 'past_participle', 'present'],
          person: ['1', '2', '3'],
          number: ['singular', 'plural']
        }
      },

      search: function (textValue, cursorPosition, language) {
        var status = this.getCompletionStatus(textValue, cursorPosition);
        var langTagMapping = this.tagMapping[language];
        if (!langTagMapping) {
          console.log("Could not find completion mapping for language '" + language + "'");
          return null;
        }
        var relevantTags = Object.keys(langTagMapping);
        if (status === 'value') {
          var currentKey = this.getCurrentKey(textValue, cursorPosition, status);
          relevantTags = langTagMapping[currentKey];
        }
        var filteredTags = [];
        if (relevantTags) {
          var filter = this.extractLast(textValue);
          relevantTags.forEach(function(e) {
            if (e.indexOf(filter) !== -1) {
              filteredTags.push(e);
            }
          });
        }
        return filteredTags;
      },

      select: function (event, ui, elem) {
        var field = event.target;
        var fieldValue = field.value;
        var status = this.getCompletionStatus(fieldValue, field.selectionStart);
        var selectedTerm = ui.item.label;
        var terms;
        var newValue;
        if (status === 'key') {
          terms = this.split(fieldValue);
          terms.pop();
          var val = terms.join(" ") + " " + selectedTerm + "=";
          newValue = val.trim();
          setTimeout(function() {elem.autocomplete("search")}, 10);
        } else {
          terms = fieldValue.split(/([=\|])/);
          terms.pop();
          newValue = terms.join("") + selectedTerm + " ";
        }
        field.value = newValue;
        return newValue;
      },

      split: function (val) {
        return val.split(/\s+/);
      },
  
      extractLast: function(term) {
        return term.split(/[\s\|=]/).pop();
      },

      getCompletionStatus: function(term, position) {
        for (var i = position; i >= 0; i--) {
          var ch = term[i];
          if (ch === ' ') {
            return 'key';
          } else if (ch === '=') {
            return 'value';
          }
        }
        return 'key';
      },

      getCurrentKey: function(term, position, status) {
        if (status === 'key') {
          console.warn("getCurrentKey() called when not in status 'value'");
          return null;
        }
        var key = '';
        var collectKey = false;
        for (var i = position; i >= 0; i--) {
          var ch = term[i];
          if (collectKey) {
            key = ch + key;
          }
          if (ch === ' ') {
            collectKey = false;
            break;
          } else if (ch === '=') {
            collectKey = true;
          }
        }
        return key.trim();
      }

  };
});
