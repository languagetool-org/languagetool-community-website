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
      throw new Exception("Unknown language ${params.lang}")
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
    List activeRules = []
    if (session.user) {
      List langConfigs = session.user.config?.languagesConfigurations
    }
    [ ruleList: rules, ruleCount: ruleCount, languages: Language.REAL_LANGUAGES,
      activeRules: activeRules ]
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
    LanguageConfiguration langConfig = getLangConfig(lang)
    // TODO: get list of disabled rules
    [ rule : selectedRule ]
  }
  
  def change = {
    String lang = "en"
      if (params.lang) lang = params.lang
    LanguageConfiguration langConfig = getLangConfig(lang)
    if (!session.user) {
      throw new Exception("Not logged in")
    }
    if (!langConfig) {
      UserConfiguration config = new UserConfiguration()
      config.addLanguagesConfiguration(new LanguageConfiguration(lang))
      //FIXME
      log.info("###params.active = ${params.active}")
      session.user.setConfig(config)
    }
    flash.message = "Rule has been modified"
    redirect(action:list)
  }
  
  private LanguageConfiguration getLangConfig(String lang) {
    if (session.user) {
      List langConfigs = session.user.config?.languagesConfigurations
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
