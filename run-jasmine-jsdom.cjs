const fs = require('fs');
const path = require('path');
const timers = require('timers');
const vm = require('vm');

const { JSDOM } = require('jsdom');
const glob = require('glob');
const jasmineCore = require('jasmine-core');

const repoRoot = __dirname;

const resolveFromRoot = (...parts) => path.join(repoRoot, ...parts);

const loadScript = (filePath, context) => {
  const code = fs.readFileSync(filePath, 'utf8');
  vm.runInContext(code, context, { filename: filePath });
};

const installGlobals = window => {
  global.window = window;
  global.document = window.document;
  global.navigator = window.navigator;
  global.location = window.location;
  global.history = window.history;
  global.localStorage = window.localStorage;
  global.sessionStorage = window.sessionStorage;
  global.Node = window.Node;
  global.Element = window.Element;
  global.HTMLElement = window.HTMLElement;
  global.Event = window.Event;
  global.CustomEvent = window.CustomEvent;
  global.KeyboardEvent = window.KeyboardEvent;
  global.MouseEvent = window.MouseEvent;
  global.getComputedStyle = window.getComputedStyle.bind(window);
  global.requestAnimationFrame = window.requestAnimationFrame.bind(window);
  global.cancelAnimationFrame = window.cancelAnimationFrame.bind(window);
  global.setTimeout = timers.setTimeout;
  global.clearTimeout = timers.clearTimeout;
  global.setInterval = timers.setInterval;
  global.clearInterval = timers.clearInterval;
  global.alert = window.alert.bind(window);
  global.confirm = window.confirm.bind(window);
};

const installStubs = window => {
  const $ = window.jQuery;

  $.fn.layout = function() {
    return {
      state: {
        west: { isClosed: false },
        east: { isClosed: false },
        south: { isClosed: false },
      },
      initContent() {},
      resizeAll() {},
      hide() {},
      show() {},
    };
  };

  $.fn.draggable = function() {
    return this;
  };

  $.fn.resizable = function() {
    return this;
  };

  window.bootstrap = {
    Modal: class Modal {
      constructor(element) {
        this.element = element;
      }

      show() {
        $(this.element).trigger('shown.bs.modal');
      }

      hide() {
        $(this.element).trigger('hidden.bs.modal');
      }
    },
  };

  window.CodeMirror = {
    fromTextArea(textarea, options = {}) {
      let value = textarea.value || '';
      const instance = {
        options: { ...options },
        focus() {},
        refresh() {},
        setValue(nextValue) {
          value = nextValue;
          textarea.value = nextValue;
        },
        getValue() {
          return value;
        },
        setOption(name, nextValue) {
          this.options[name] = nextValue;
        },
        getOption(name) {
          return this.options[name];
        },
      };

      return instance;
    },
  };
};

const installJasmine = window => {
  const jasmine = jasmineCore.core(jasmineCore);
  const env = jasmine.getEnv();
  const jasmineInterface = jasmineCore.interface(jasmine, env);

  window.jasmine = jasmine;
  window.jasmineRequire = jasmineCore;
  Object.assign(window, jasmineInterface);
  Object.assign(global, jasmineInterface);

  env.configure({ random: false });

  return env;
};

const buildDom = () => {
  const dom = new JSDOM(
    `<!doctype html><html><body style="visibility:hidden"><div id="header"></div><div id="main-content"></div><div id="health-region" class="d-none"></div></body></html>`,
    {
      url: 'http://localhost/',
      pretendToBeVisual: true,
      runScripts: 'outside-only',
    },
  );

  const { window } = dom;
  window.console = console;
  window.global = window;
  window.self = window;
  window.alert = () => {};
  window.confirm = () => true;
  window.requestAnimationFrame = window.requestAnimationFrame || (callback => window.setTimeout(() => callback(Date.now()), 0));
  window.cancelAnimationFrame = window.cancelAnimationFrame || (id => window.clearTimeout(id));

  return dom;
};

const loadBrowserLibraries = context => {
  [
    'node_modules/jquery/dist/jquery.min.js',
    'node_modules/underscore/underscore-min.js',
    'node_modules/backbone/backbone-min.js',
    'node_modules/backbone.radio/build/backbone.radio.min.js',
    'node_modules/backbone.marionette/lib/backbone.marionette.min.js',
    'node_modules/handlebars/dist/handlebars.runtime.min.js',
    'web/vendor/js/plugins/jquery.hotkeys.js',
  ].forEach(file => loadScript(resolveFromRoot(file), context));
};

const loadCompiledSources = context => {
  const orderedFiles = [
    resolveFromRoot('build/debug/js/templates.js'),
    resolveFromRoot('build/debug/js/app/app.js'),
    ...glob.sync(resolveFromRoot('build/debug/js/app/*/**/*.js')).sort(),
  ];

  orderedFiles.forEach(file => loadScript(file, context));
};

const loadSpecs = context => {
  loadScript(resolveFromRoot('web/vendor/js/plugins/jasmine-jquery.js'), context);

  glob.sync(resolveFromRoot('build/spec/**/*helper.*')).sort().forEach(file => loadScript(file, context));
  glob.sync(resolveFromRoot('build/spec/**/*spec.*')).sort().forEach(file => loadScript(file, context));
};

const run = async () => {
  const dom = buildDom();
  const { window } = dom;
  const context = dom.getInternalVMContext();

  installGlobals(window);
  loadBrowserLibraries(context);

  global.$ = window.$;
  global.jQuery = window.jQuery;
  global._ = window._;
  global.Backbone = window.Backbone;
  global.Marionette = window.Marionette;
  global.Handlebars = window.Handlebars;

  installStubs(window);
  const env = installJasmine(window);

  loadCompiledSources(context);
  loadSpecs(context);

  const result = await new Promise(resolve => {
    let failed = false;
    const counts = { total: 0, passed: 0, failed: 0, pending: 0 };

    env.addReporter({
      specDone(specResult) {
        counts.total++;
        counts[specResult.status] = (counts[specResult.status] || 0) + 1;
        if (specResult.status === 'failed') {
          failed = true;
          console.error(`FAILED: ${specResult.fullName}`);
          specResult.failedExpectations.forEach(expectation => {
            console.error(expectation.message);
            if (expectation.stack) {
              console.error(expectation.stack);
            }
          });
        }
      },
      jasmineDone(suiteResult) {
        resolve({
          failed: failed || suiteResult.failedExpectations.length > 0,
          overallStatus: suiteResult.overallStatus,
          counts,
        });
      },
    });

    env.execute();
  });

  dom.window.close();

  const { counts } = result;
  console.log(`${counts.total} specs: ${counts.passed} passed, ${counts.failed} failed${counts.pending ? `, ${counts.pending} pending` : ''} (${result.overallStatus})`);

  // Zero specs means the compiled spec files were missing, not that everything passed
  if (result.failed || result.overallStatus === 'failed' || counts.total === 0) {
    if (counts.total === 0) {
      console.error('No specs were run — check that build/spec contains compiled spec files.');
    }
    process.exitCode = 1;
  }
};

run().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
