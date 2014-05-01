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
          posTagChars: 'A-Z:$',  // characters used in the POS tags, will be used to form a regex
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
            WRB: 'wh-adverb (however, how, wherever, where, when, why)'
          }
        },
        
        de: {
          posTagChars: 'A-Z0-9/Ä',  // characters used in the POS tags
          tags:
          {
            // source: de/tagset.txt
            // POS tags that do not seem to be useful are commented out
            SUB: 'Substantiv',
            EIG: 'Eigenname',
            VER: 'Verb',
            ADJ: 'Adjektiv',
            ART: 'Artikel',
            PRO: 'Pronomen',
            ADV: 'Adverb',
            PRP: 'Präposition',
            NEG: 'Negationspartikel',
            ABK: 'Abkürzung',

            AKK: 'Akkusativ',
            //ATT: 'attributiv(*)',
            AUX: 'Hilfsverb',
            BEG: 'begleitend',
            'B/S': 'begleitend oder stellvertretend',
            CAU: 'kausal',
            //COU: 'Land',
            DAT: 'Dativ',
            DEF: 'bestimmt',
            DEM: 'Demonstrativpronomen',
            EIZ: 'erweiterter Infinitiv mit zu',
            FEM: 'femininum',
            //GEB: 'Gebiet (z.B. Westdeutschland, Württemberg)',
            GEN: 'Genitiv',
            //GEO: 'geographischer Eigenname',
            GRU: 'Grundform',
            IND: 'unbestimmt',
            INF: 'Infinitiv',
            //INJ: 'Interjektion (z.B. aha, bumm)',
            IMP: 'Imperativ',
            INR: 'Interrogativpronomen',
            KJ1: 'Konjunktiv: 1',
            KJ2: 'Konjunktiv: 2',
            //KMP: 'Kompositum(*)',
            KOM: 'Komparativ',
            KON: 'Konjunktion',
            LOK: 'lokal (z.B. vorn, zwischen)',
            MAS: 'maskulinum',
            MOD: 'modal',
            //MOU: 'Gebirge',
            //NAC: 'Nachname',
            NEB: 'nebenordnend',
            NEU: 'neutrum',
            //NIL: 'Wortform nicht gefunden(*)',
            NOA: 'ohne Artikel (nur bei EIG)',
            NOG: 'ohne Genus',
            NOM: 'Nominativ',
            NON: 'nicht-schwach',
            PA1: 'Partizip 1',
            PA2: 'Partizip 2',
            PER: 'personal',
            PLU: 'Plural',
            POS: 'possessiv',
            PRÄ: 'Präsens',
            PRD: 'prädikativ',
            PRI: 'proportional (desto, je, so, um)',
            PRT: 'Präteritum, Imperfekt',
            REF: 'reflexiv',
            //REL: 'relativ(*)',
            RIN: 'relativ oder interrogativ',
            SFT: 'schwach',
            SIN: 'Singular',
            SOL: 'alleinstehend',
            //STD: 'Stadt',
            STV: 'stellvertretend',
            SUP: 'Superlativ',
            //SZ: 'Satzzeichen(*)',
            //SZE: 'Satzendezeichen(*)',
            //SZK: 'Komma(*)',
            //SZT: 'Satztrennzeichen(*)',
            TMP: 'temporal',
            UNT: 'unterordnend',
            VGL: 'vergleichend (als, am, denn, wie)',
            //VOR: 'Vorname',
            //WAT: 'Gewässer',
            ZAL: 'Zahlwort',
            //ZAN: 'Zahl bzw. Ziffernfolge(*)',
            ZUS: 'Verbzusatz',
            1: '1. Person',
            2: '2. Person',
            3: '3. Person'
            //A: 'höflich',
            //B: 'vertraut'
          }
        }
      }

  };
});
