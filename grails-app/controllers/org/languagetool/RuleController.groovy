package org.languagetool

import de.danielnaber.languagetool.*
import de.danielnaber.languagetool.rules.*
import de.danielnaber.languagetool.rules.patterns.*

class RuleController extends BaseController {

  def index = { redirect(action:list,params:params) }
  
  def list = {
    int max = 10
    int offset = 0
    if (!params.lang) params.lang = "en"
    if (params.offset) offset = Integer.parseInt(params.offset)
    if (params.max) max = Integer.parseInt(params.max)
    Language lang = Language.getLanguageForShortName(params.lang)
    if (!lang) {
      throw new Exception("Unknown language ${params.lang.encodeAsHTML()}")
    }
    JLanguageTool lt = new JLanguageTool(lang)
    lt.activateDefaultPatternRules()
    List rules = lt.getAllRules()
    if (params.filter) {
      rules = filterRules(rules, params.filter)
    }
    if (params.sort) {
      def sortF = SortField.pattern
      if (params.sort == 'description') sortF = SortField.description
      if (params.sort == 'category') sortF = SortField.category
      Collections.sort(rules, new RuleComparator(sortF,
          params.order == 'desc' ? SortDirection.desc : SortDirection.asc));
    }
    int ruleCount = rules.size()
    if (ruleCount == 0) {
      rules = []
    } else {
      rules = rules[offset..Math.min(rules.size()-1, offset+max)]
    }
    Set disabledRuleIDs = new HashSet()      // empty = all rules activated
    if (session.user) {
      LanguageConfiguration langConfig = getLangConfigforUser(lang.shortName, session)
      if (langConfig) {
        Set disabledRules = langConfig.getDisabledRules()
        for (rule in disabledRules) {
          disabledRuleIDs.add(rule.ruleID)
        }
      }
    }
    [ ruleList: rules, ruleCount: ruleCount, languages: Language.REAL_LANGUAGES,
      disabledRuleIDs: disabledRuleIDs ]
  }

  private filterRules(List rules, String filter) {
    filter = filter.toLowerCase()
    List filtered = []
    for (rule in rules) {
      if (rule instanceof PatternRule) {
        PatternRule pRule = (PatternRule)rule
        if (pRule.toPatternString().toLowerCase().contains(filter)) {
          filtered.add(rule)
          continue
        }
      }
      if (rule.description.toLowerCase().contains(filter)) {
        filtered.add(rule)
      }
    }
    return filtered
  }

  /**
   * Check a given text with a single rule.
   */
  def checkTextWithRule = {
    // get all information needed to display "show" page:
    String lang = "en"
    if (params.lang) lang = params.lang
    JLanguageTool lt = new JLanguageTool(Language.getLanguageForShortName(lang))
    lt.activateDefaultPatternRules()
    Rule selectedRule = getRuleById(params.id, lt)
    if (!selectedRule) {
      flash.message = "No rule with id ${params.id.encodeAsHTML()}"
      redirect(action:list)
    }
    int internalId = getInternalRuleId(selectedRule, params.id, lt)
    // disable all rules except one:
    List rules = lt.getAllRules()
    for (Rule rule in rules) {
      if (rule.id == params.id) {
        lt.enableRule(rule.id)
      } else {
        lt.disableRule(rule.id)
      }
    }
    // now actually check the text:
    String text = params.text
    final int maxTextLen = grailsApplication.config.max.text.length
    if (text.size() > maxTextLen) {
      text = text.substring(0, maxTextLen)
      flash.message = "The text is too long, only the first $maxTextLen characters have been checked"
    }
    List ruleMatches = lt.check(text)
    render(view:'show', model: [ rule: selectedRule, isDisabled: internalId != -1, internalId: internalId,
                                 textToCheck: params.text, matches: ruleMatches],
                                 contentType: "text/html", encoding: "utf-8")
  }
  
  def show = {
    String lang = "en"
    if (params.lang) lang = params.lang
    JLanguageTool lt = new JLanguageTool(Language.getLanguageForShortName(lang))
    lt.activateDefaultPatternRules()
    Rule selectedRule = getRuleById(params.id, lt)
    if (!selectedRule) {
      flash.message = "No rule with id ${params.id.encodeAsHTML()}"
      redirect(action:list)
    }
    int internalId = getInternalRuleId(selectedRule, params.id, lt)
    [ rule: selectedRule, isDisabled: internalId != -1, internalId: internalId ]
  }

  private int getInternalRuleId(Rule selectedRule, String id, JLanguageTool lt) {
    LanguageConfiguration langConfig = getLangConfigforUser(lt.getLanguage().getShortName(), session)
    int enableDisableID = -1
    if (langConfig) {
      Set disabledRules = langConfig.getDisabledRules()
      for (disabledRule in disabledRules) {
        if (disabledRule.ruleID == params.id) {
          enableDisableID = disabledRule.id
          break
        }
      }
    }
    return enableDisableID
  }
  
  private Rule getRuleById(String id, JLanguageTool lt) {
    Rule selectedRule = null
    List rules = lt.getAllRules()
    for (Rule rule in rules) {
      if (rule.id == params.id) {
        selectedRule = rule
        break
      }
    }
    return selectedRule
  }
    
  def change = {
    if (!session.user) {
      throw new Exception("Not logged in")
    }
    String lang = "en"
    if (params.lang) lang = params.lang
    LanguageConfiguration langConfig = getLangConfigforUser(lang, session)
    if (!langConfig) {
      log.info("Creating language configuration for ${session.user}, language $lang")
      langConfig = new LanguageConfiguration(language:lang)
      session.user.addToLanguagesConfigurations(langConfig)
      def saved = session.user.save()
      if (!saved) {
        throw new Exception("Could not save LanguageConfiguration: ${langConfig.errors}")
      }
    }
    Set disabledRules = langConfig.getDisabledRules()
    Set disabledRuleIDs = []
    for (disabledRule in disabledRules) {
      disabledRuleIDs.add(disabledRule.ruleID)
    }
    if (!params.active) {
      // de-activate rule
      langConfig.addToDisabledRules(new DisabledRule(ruleID:params.id))
    } else {
      // activate rule
      for (disabledRule in disabledRules) {
        if (disabledRule.id == Integer.parseInt(params.internalId)) {
          langConfig.removeFromDisabledRules(disabledRule)
          break
        }
      }
    }
    def saved = session.user.save()
    if (!saved) {
      throw new Exception("Could not save user: ${session.user.errors}")
    }
    flash.message = "Rule has been modified"
    redirect(action:list, params: [lang: params.lang])
  }
  
  private static LanguageConfiguration getLangConfigforUser(String lang, def session) {
    if (session.user) {
      Set langConfigs = session.user.languagesConfigurations
      if (langConfigs) {
        for (langConfig in langConfigs) {
          if (langConfig.language == lang) {
            return langConfig
          }
        }
      }
    }
    return null
  }
  
}
