var NanoTemplate = function () {
var _templateData = {}
var _templates = {}
var _compiledTemplates = {}
var _helpers = {}

    var init = function () {
      _templateData = $('body').data('templateData')
      if (_templateData == null) {
        alert('Error: Template data did not load correctly.')
        return
      }
      loadAllTemplates()
    }

    var loadAllTemplates = function () {
      var keys = []
      for (var key in _templateData) {
        if (_templateData.hasOwnProperty(key))
          keys.push(key)
      }

      if (!keys.length) {
        $(document).trigger('templatesLoaded')
        return
      }

      var remaining = keys.length
      var failed = []
      var finishOne = function () {
        remaining--
        if (remaining > 0)
          return
        if (failed.length) {
          var layout = $('#uiLayout')
          if (layout.length)
            layout.html('<div class="notice" style="padding:12px;">Failed to load interface templates (' + failed.join(', ') + '). Please reopen this window.</div>')
          return
        }
        $(document).trigger('templatesLoaded')
      }

      var loadTemplate = function (key, attempt) {
        var url = _templateData[key]
        $.ajax({
          url: url,
          cache: false,
          dataType: 'text'
        })
        .done(function (templateMarkup) {
          templateMarkup += '<div class="clearBoth"></div>'
          try {
            NanoTemplate.addTemplate(key, templateMarkup)
          }
          catch (error) {
            alert('ERROR: An error occurred while loading the UI: ' + error.message)
            failed.push(key)
            finishOne()
            return
          }
          delete _templateData[key]
          finishOne()
        })
        .fail(function () {
          if (attempt < 2) {
            setTimeout(function () {
              loadTemplate(key, attempt + 1)
            }, 150)
            return
          }
          alert('ERROR: Loading template ' + key + '(' + url + ') failed!')
          failed.push(key)
          finishOne()
        })
      }

      for (var i = 0; i < keys.length; i++)
        loadTemplate(keys[i], 0)
    }

    var compileTemplates = function () {
      for (var key in _templates) {
        try {
          _compiledTemplates[key] = doT.template(_templates[key], null, _templates)
        }
        catch (error) {
          alert(error.message)
        }
      }
    }

  return {
    init: function () {
      init()
    },

    addTemplate: function (key, templateString) {
      _templates[key] = templateString
    },

    templateExists: function (key) {
      return _templates.hasOwnProperty(key)
    },

    parse: function (templateKey, data) {
      if (!_compiledTemplates.hasOwnProperty(templateKey) || !_compiledTemplates[templateKey]) {
        if (!_templates.hasOwnProperty(templateKey)) {
          alert('ERROR: Template "' + templateKey + '" does not exist in _compiledTemplates!')
          return '<h2>Template error (does not exist)</h2>'
        }
        compileTemplates()
      }
      if (typeof _compiledTemplates[templateKey] !== 'function') {
        alert(_compiledTemplates[templateKey])
        alert('ERROR: Template "' + templateKey + '" failed to compile!')
        return '<h2>Template error (failed to compile)</h2>'
      }
      return _compiledTemplates[templateKey].call(this, data['data'], data['config'], _helpers)
    },

    addHelper: function (helperName, helperFunction) {
      if (!jQuery.isFunction(helperFunction)) {
        alert('NanoTemplate.addHelper failed to add ' + helperName + ' as it is not a function.')
        return
      }
      _helpers[helperName] = helperFunction
    },

    addHelpers: function (helpers) {
      for (var helperName in helpers)
        if (helpers.hasOwnProperty(helperName))
          NanoTemplate.addHelper(helperName, helpers[helperName])
    },

    removeHelper: function (helperName) {
      if (_helpers.hasOwnProperty(helperName))
        delete _helpers[helperName]
    }
  }
}()
