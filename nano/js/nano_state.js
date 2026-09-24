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
    if (oldChild.nodeType === 8) { // Comment node
      continue
    }
    if (oldChild.nodeType === 1) { // Element node
      if (oldChild.tagName !== newChild.tagName) {
        oldNode.replaceChild(newChild.cloneNode(true), oldChild)
        continue
      }
      // Skip <style> tags completely once rendered — CSS is static
      if (oldChild.tagName === 'STYLE') {
        continue
      }
      // If elements have distinct data-view / data-key (e.g. switching tabs or view panels),
      // replace the whole element cleanly instead of morphing mismatched trees
      var oldKey = oldChild.getAttribute ? (oldChild.getAttribute('data-view') || oldChild.getAttribute('data-key')) : null
      var newKey = newChild.getAttribute ? (newChild.getAttribute('data-view') || newChild.getAttribute('data-key')) : null
      if (oldKey || newKey) {
        if (oldKey !== newKey) {
          oldNode.replaceChild(newChild.cloneNode(true), oldChild)
          continue
        }
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
    if (newEl.hasAttribute ? !newEl.hasAttribute(attr.name) : (newEl.getAttribute(attr.name) === null)) {
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
// Saves/restores scrollTop for elements with data-scroll-id by key,
// so scroll survives even if the element is replaced during diffing.
function nanoPatchHtml(container, newHtml) {
  var el = container[0]
  if (!el) return
  var scrollSaves = {}
  var scrollEls = el.querySelectorAll('[data-scroll-id]')
  for (var si = 0; si < scrollEls.length; si++) {
    var sid = scrollEls[si].getAttribute('data-scroll-id')
    scrollSaves[sid] = scrollEls[si].scrollTop
  }
  if (el.getAttribute && el.getAttribute('data-scroll-id')) {
    scrollSaves[el.getAttribute('data-scroll-id')] = el.scrollTop
  }

  // Preserve container and window scroll positions
  var winScrollY = window.pageYOffset || (document.documentElement ? document.documentElement.scrollTop : 0) || (document.body ? document.body.scrollTop : 0)
  var winScrollX = window.pageXOffset || (document.documentElement ? document.documentElement.scrollLeft : 0) || (document.body ? document.body.scrollLeft : 0)
  var elScrollTop = el.scrollTop
  var elScrollLeft = el.scrollLeft

  var oldScreenEl = el.querySelector('[data-view-screen]')
  var oldScreen = oldScreenEl ? oldScreenEl.getAttribute('data-view-screen') : null

  if (!el.hasChildNodes()) {
    el.innerHTML = newHtml
  } else {
    var scratch = document.createElement('div')
    scratch.innerHTML = newHtml
    nanoDiffNodes(el, scratch)
  }

  var newScreenEl = el.querySelector('[data-view-screen]')
  var newScreen = newScreenEl ? newScreenEl.getAttribute('data-view-screen') : null
  var screenChanged = oldScreen && newScreen && (oldScreen !== newScreen)

  function restoreScrolls() {
    var els = el.querySelectorAll('[data-scroll-id]')
    for (var ri = 0; ri < els.length; ri++) {
      var rsid = els[ri].getAttribute('data-scroll-id')
      if (scrollSaves[rsid] !== undefined && scrollSaves[rsid] > 0)
        els[ri].scrollTop = scrollSaves[rsid]
    }
    if (el.getAttribute && el.getAttribute('data-scroll-id')) {
      var elSid = el.getAttribute('data-scroll-id')
      if (scrollSaves[elSid] !== undefined && scrollSaves[elSid] > 0)
        el.scrollTop = scrollSaves[elSid]
    } else if (elScrollTop > 0) {
      el.scrollTop = elScrollTop
    }
    if (elScrollLeft > 0) {
      el.scrollLeft = elScrollLeft
    }
    if (!screenChanged) {
      if (winScrollY > 0 || winScrollX > 0) {
        window.scrollTo(winScrollX, winScrollY)
      }
    } else {
      window.scrollTo(0, 0)
    }
  }
  restoreScrolls()
  if (typeof requestAnimationFrame !== 'undefined') {
    requestAnimationFrame(restoreScrolls)
  } else {
    setTimeout(restoreScrolls, 0)
  }
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
