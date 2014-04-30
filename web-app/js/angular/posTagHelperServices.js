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

/* Show full names for internal POS tags */

var postagHelperService = angular.module('ruleEditor.postagHelperServices', []);

postagHelperService.factory('PostagHelper',
  function() {
    return {

      tagMapping: {
        en: {
          posTagChars: 'A-Z:$',  // characters used in the POS tags
          tags:
          {
            CC: 'Coordinating conjunction (and, or, either, if, as, since, once, neither, less)',
            CD: 'Cardinal number (one, two, twenty-four)',
            DT: 'Determiner (an, an, all, many, much, any, some, this)',
            //EX: 'Existential there (there)',
            FW: 'Foreign word (infinitum, ipso)',
            IN: 'Preposition/subordinate conjunction (except, inside, across, on, through, beyond, with, without)',
            JJ: 'Adjective (beautiful, large, inspectable)',
            JJR: 'Adjective (comparative: larger, quicker)',
            JJS: 'Adjective (superlative: largest, quickest)',
            MD: 'Modal (should, can, need, must, will, would)',
            NN: 'Noun, singular or mass (bicycle, earthquake, zipper)',
            NNS: 'Noun, plural (bicycles, earthquake, zippers)',
            'NN:U': 'Mass noun (admiration, air, Afrikaans)',
            'NN:UN': 'Noun used as mass (establishment, wax, afternoon)',
            NNP: 'Proper noun, singular (Denver, DORAN, Alexandra)',
            NNPS: 'Proper noun, plural (Buddhists, Englishmen)',
            PDT: 'Predeterminer (all, sure, such, this, many, half, both, quite)',
            POS: 'Possessive ending: s (as in: Peter\'s)',
            PRP: 'Personal pronoun (everyone, I, he, it, myself)',
            'PRP$': 'Possessive pronoun (its, our, their, mine, my, her, his, your)',
            RB: 'Adverb and negation (easily, sunnily, suddenly, specifically, not)',
            RBR: 'Adverb, comparative (better, faster, quicker)',
            RBS: 'Adverb, superlative (best, fastest, quickest)',
            RP: 'Particle (in, into, at, off, over, by, for, under)',
            //TO: 'to: to (no other words)',
            //UH: 'Interjection (aargh, ahem, attention, congrats, help)',
            VB: 'Verb, base form (eat, jump, believe, be, have)',
            VBD: 'Verb, past tense (ate, jumped, believed)',
            VBG: 'Verb, gerund/present participle (eating, jumping, believing)',
            VBN: 'Verb, past participle (eaten, jumped, believed)',
            VBP: 'Verb, non-3rd ps. sing. present (eat, jump, believe, am, are)',
            VBZ: 'Verb, 3rd ps. sing. present (eats, jumps, believes, is, has)',
            WDT: 'wh-determiner (that, whatever, what, whichever, which)',
            WP: 'wh-pronoun (that, whatever, what, whatsoever, whosoever, who, whom, whoever, which)',
            'WP$': 'Possessive wh-pronoun (whose)',
            WRB: 'wh-adverb (however, how, whereever, where, when, why)'
          }
        }
      }

  };
});
