function NanoStateClass() {
}

NanoStateClass.prototype.key = null
NanoStateClass.prototype.layoutRendered = false
NanoStateClass.prototype.contentRendered = false
NanoStateClass.prototype.mapInitialised = false

NanoStateClass.prototype.isCurrent = function () {
  return NanoStateManager.getCurrentState() === this
}

NanoStateClass.prototype.onAdd = function (previousState) {
  NanoBaseCallbacks.addCallbacks()
  NanoBaseHelpers.addHelpers()
}

NanoStateClass.prototype.onRemove = function (nextState) {
  NanoBaseCallbacks.removeCallbacks()
  NanoBaseHelpers.removeHelpers()
}

NanoStateClass.prototype.onBeforeUpdate = function (data) {
  data = NanoStateManager.executeBeforeUpdateCallbacks(data)
  return data
}
//[SIERRA-ADD]
// Reconciles oldNode's children to match newNode's children without replacing the whole subtree.
// Only nodes that actually changed are touched, preventing browser repaints on unchanged content.
function nanoDiffNodes(oldNode, newNode) {
  var oldChildren = oldNode.childNodes
  var newChildren = newNode.childNodes
  var i

  // Update / add nodes
  for (i = 0; i < newChildren.length; i++) {
    var newChild = newChildren[i]
    if (i >= oldChildren.length) {
      oldNode.appendChild(newChild.cloneNode(true))
      continue
    }
    var oldChild = oldChildren[i]
    if (oldChild.nodeType !== newChild.nodeType) {
      oldNode.replaceChild(newChild.cloneNode(true), oldChild)
      continue
    }
    if (oldChild.nodeType === 3) { // Text node
      if (oldChild.nodeValue !== newChild.nodeValue)
        oldChild.nodeValue = newChild.nodeValue
      continue
    }
    if (oldChild.nodeType === 1) { // Element node
      if (oldChild.tagName !== newChild.tagName) {
        oldNode.replaceChild(newChild.cloneNode(true), oldChild)
        continue
      }
      nanoDiffAttrs(oldChild, newChild)
      nanoDiffNodes(oldChild, newChild)
    }
  }

  // Remove surplus old nodes (iterate backwards to avoid index shifting)
  for (i = oldChildren.length - 1; i >= newChildren.length; i--)
    oldNode.removeChild(oldChildren[i])
}

// Syncs attributes of oldEl to match newEl without touching unchanged ones.
function nanoDiffAttrs(oldEl, newEl) {
  var i, attr
  var $old = $(oldEl)
  for (i = oldEl.attributes.length - 1; i >= 0; i--) {
    attr = oldEl.attributes[i]
    if (!newEl.hasAttribute(attr.name)) {
      oldEl.removeAttribute(attr.name)
      if (attr.name.indexOf('data-') === 0)
        $old.removeData(attr.name.slice(5))
    }
  }
  for (i = 0; i < newEl.attributes.length; i++) {
    attr = newEl.attributes[i]
    if (oldEl.getAttribute(attr.name) !== attr.value) {
      oldEl.setAttribute(attr.name, attr.value)
      if (attr.name.indexOf('data-') === 0)
        $old.removeData(attr.name.slice(5))
    }
  }
}

// Renders newHtml into container using DOM diffing.
// Falls back to innerHTML on first render (when container is empty).
// newHtml is pre-rendered by NanoTemplate.parse() (jsrender) which HTML-escapes data by default.
function nanoPatchHtml(container, newHtml) {
  var el = container[0]
  if (!el) return
  if (!el.hasChildNodes()) {
    el.innerHTML = newHtml
    return
  }
  var scratch = document.createElement('div')
  scratch.innerHTML = newHtml
  nanoDiffNodes(el, scratch)
}
//[/SIERRA-ADD]

//[SIERRA-EDIT] "nanoPatchHtml($("#uiLayout"), " теперь везде вместо  $("#uiHeaderContent").html(
NanoStateClass.prototype.onUpdate = function (data) {
  try {
    if (!this.layoutRendered || (data['config'].hasOwnProperty('autoUpdateLayout') && data['config']['autoUpdateLayout'])){
      nanoPatchHtml($("#uiLayout"), NanoTemplate.parse('layout', data))
      this.layoutRendered = true
    }
    if (!this.contentRendered || (data['config'].hasOwnProperty('autoUpdateContent') && data['config']['autoUpdateContent'])) {
      nanoPatchHtml($("#uiContent"), NanoTemplate.parse('main', data))
      if (NanoTemplate.templateExists('layoutHeader'))
        nanoPatchHtml($("#uiHeaderContent"), NanoTemplate.parse('layoutHeader', data))
      this.contentRendered = true
    }
    if (NanoTemplate.templateExists('mapContent')) {
      if (!this.mapInitialised) {
        $('#uiMap').draggable()
        $('#uiMapTooltip')
          .off('click')
          .on('click', function (event) {
            event.preventDefault()
            $(this).fadeOut(400)
          })
        this.mapInitialised = true
      }
      nanoPatchHtml($("#uiMapContent"), NanoTemplate.parse('mapContent', data))
      if (data['config'].hasOwnProperty('showMap') && data['config']['showMap']) {
        $('#uiContent').addClass('hidden')
        $('#uiMapWrapper').removeClass('hidden')
      }
      else {
        $('#uiMapWrapper').addClass('hidden')
        $('#uiContent').removeClass('hidden')
      }
    }
    if (NanoTemplate.templateExists('mapHeader'))
      nanoPatchHtml($("#uiMapHeader"), NanoTemplate.parse('mapHeader', data))
    if (NanoTemplate.templateExists('mapFooter'))
      nanoPatchHtml($("#uiMapFooter"), NanoTemplate.parse('mapFooter', data))
  }
  catch(error) {
    alert('ERROR: An error occurred while rendering the UI: ' + error.message)
    return
  }
}
//[/SIERRA-EDIT]

NanoStateClass.prototype.onAfterUpdate = function (data) {
  NanoStateManager.executeAfterUpdateCallbacks(data)
}

NanoStateClass.prototype.alertText = function (text) {
  alert(text)
}
