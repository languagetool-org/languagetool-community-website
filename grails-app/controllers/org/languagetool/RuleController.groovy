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
      LanguageConfiguration langConfig = getLangConfigforUser(lang.shortName)
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

  def show = {
    String lang = "en"
    if (params.lang) lang = params.lang
    // TODO: create only once:
    JLanguageTool lt = new JLanguageTool(Language.getLanguageForShortName(lang))
    lt.activateDefaultPatternRules()
    List rules = lt.getAllRules()
    Rule selectedRule = null
    for (Rule rule in rules) {
      if (rule.id == params.id) {
        selectedRule = rule
        break
      }
    }
    if (!selectedRule) {
      flash.message = "No rule with id ${params.id.encodeAsHTML()}"
      redirect(action:list)
    }
    LanguageConfiguration langConfig = getLangConfigforUser(lang)
    boolean isDisabled = false
    int enableDisableID = -1
    if (langConfig) {
      Set disabledRules = langConfig.getDisabledRules()
      for (disabledRule in disabledRules) {
        if (disabledRule.ruleID == params.id) {
          enableDisableID = disabledRule.id
          isDisabled = true
          break
        }
      }
    }
    [ rule: selectedRule, isDisabled: isDisabled, enableDisableID: enableDisableID ]
  }
  
  def change = {
    if (!session.user) {
      throw new Exception("Not logged in")
    }
    String lang = "en"
      if (params.lang) lang = params.lang
    LanguageConfiguration langConfig = getLangConfigforUser(lang)
    if (!langConfig) {
      log.info("Creating language configuration for ${session.user}, language $lang")
      log.info("~~~~~~+ $lang")
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
        if (disabledRule.id == Integer.parseInt(params.enableDisableID)) {
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
    redirect(action:list)
  }
  
  private LanguageConfiguration getLangConfigforUser(String lang) {
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
