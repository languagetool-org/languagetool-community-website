
var ltRuleEditorTextField = null;

function ltRuleEditorEnterTextField(val) {
  ltRuleEditorTextField = val;
  return false;
}

function ltRuleEditorLeaveTextField(val) {
  ltRuleEditorTextField = null;
  return false;
}

$(function() {

  // Note: this mapping comes from attributes-en.xsd:
  var tagMapping = {
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
  };
  
  function split(val) {
    return val.split(/\s+/);
  }
  
  function extractLast(term) {
    return term.split(/[\s=]/).pop();
  }
  
  function getCompletionStatus(term, position) {
    for (var i = position; i >= 0; i--) {
      var ch = term[i];
      if (ch === ' ') {
        return 'key';
      } else if (ch === '=') {
        return 'value';
      }
    }
    return 'key';
  }
  
  function getCurrentKey(term, position, status) {
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
  
  $(".posTagCompletion")
    // don't navigate away from the field on tab when selecting an item
    .bind( "keydown", function( event ) {
      if (event.keyCode === $.ui.keyCode.TAB && $(this).data("ui-autocomplete").menu.active) {
        event.preventDefault();
      }
    })
    .autocomplete({
      minLength: 0,
      source: function(request, response) {
        var val = ltRuleEditorTextField.value;
        var selectionStart = ltRuleEditorTextField.selectionStart;
        var status = getCompletionStatus(val, selectionStart);
        var language = 'en';  // TODO: use current language
        var langTagMapping = tagMapping[language];
        if (!langTagMapping) {
          console.log("Could not find completion mapping for language '" + language + "'");
          response();
          return;
        }
        var relevantTags = Object.keys(langTagMapping);
        if (status === 'value') {
          var currentKey = getCurrentKey(val, selectionStart, status);
          relevantTags = langTagMapping[currentKey];
        }
        if (relevantTags) {
          response($.ui.autocomplete.filter(relevantTags, extractLast(request.term)));
        }
      },
      focus: function() {
        // prevent value inserted on focus
        return false;
      },
      select: function(event, ui) {
        var status = getCompletionStatus(this.value, this.selectionStart);
        if (status === 'key') {
          var terms = split(this.value);
          terms.pop();
          var val = terms.join(" ") + " " + ui.item.value + "=";
          this.value = val.trim();
          //setTimeout(function() {$('#tags').autocomplete("search")}, 10);   //TODO: use the current field
        } else {
          terms = this.value.split("=");
          terms.pop();
          this.value = terms.join("=") + "=" + ui.item.value + " ";
        }
        return false;
      }
    });
});
