module.exports = function(config) {
  config.set({
    basePath : '../../',

    files : [
      'web-app/js/angular/lib/angular.js',
      'web-app/js/angular/lib/angular-*.js',
      'web-app/js/angular/*.js',
      'web-app/js/angular/modules/*.js',
      'web-app/js/jquery/jquery-1.7.1.js',
      'angular/test/unit/**/*.js'
    ],

    exclude : [
      'web-app/js/angular/lib/angular-*.min.js'
    ],

    autoWatch : true,

    frameworks: ['jasmine'],

    browsers : ['Chrome'],

    plugins : [
      'karma-junit-reporter',
      'karma-chrome-launcher',
      'karma-firefox-launcher',
      'karma-script-launcher',
      'karma-jasmine'
    ],

    junitReporter : {
      outputFile: 'test_out/unit.xml',
      suite: 'unit'
    }
  });
};
