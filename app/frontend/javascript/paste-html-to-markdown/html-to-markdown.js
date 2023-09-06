// Adapted from the [Paste HTML to govspeak](https://github.com/alphagov/paste-html-to-govspeak) package

import TurndownService from 'turndown'
import replaceBulletCharacters from './replace-bullet-characters'

const service = new TurndownService({
  bulletListMarker: '*',
  listIndent: '   ' // 3 spaces
})

// define all the elements we want stripped from output
const elementsToRemove = [
  'title',
  'script',
  'noscript',
  'style',
  'video',
  'audio',
  'object',
  'iframe'
]

for (const element of elementsToRemove) {
  service.remove(element)
}

// As a user may have pasted markdown we rather crudley
// stop all escaping
service.escape = string => string

// turndown keeps title attribute attributes of links by default which isn't
// what is expected in Forms Markdown
service.addRule('link', {
  filter: node => {
    return node.nodeName.toLowerCase() === 'a' && node.getAttribute('href')
  },
  replacement: (content, node) => {
    if (content.trim() === '') {
      return ''
    } else {
      return `[${content}](${node.getAttribute('href')})`
    }
  }
})

service.addRule('abbr', {
  filter: node => {
    return node.nodeName.toLowerCase() === 'abbr' && node.getAttribute('title')
  },
  replacement: function (content, node) {
    this.references[content] = node.getAttribute('title')
    return content
  },
  references: {},
  append: function () {
    if (Object.keys(this.references).length === 0) {
      return ''
    }

    let references = '\n\n'
    for (const abbr in this.references) {
      references += `*[${abbr}]: ${this.references[abbr]}\n`
    }
    this.references = {} // reset after appending
    return references
  }
})

// GOV.UK content authors are encouraged to only use h2 and h3 headers, this
// converts other headers to be one of these (except h6 which is converted
// to a paragraph
service.addRule('heading', {
  filter: ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
  replacement: (content, node) => {
    let headingLevel = parseInt(node.nodeName.charAt(1))
    headingLevel = headingLevel === 1 ? 2 : headingLevel
    const prefix = Array(headingLevel + 1).join('#')

    return `\n\n${prefix} ${content}\n\n`
  }
})

// remove images
// this needs to be set as a rule rather than remove as it's part of turndown
// commonmark rules that needs overriding
service.addRule('img', {
  filter: ['img'],
  replacement: () => ''
})

// remove bold
service.addRule('bold', {
  filter: ['b', 'strong'],
  replacement: content => content
})

// remove italic
service.addRule('italic', {
  filter: ['i', 'em'],
  replacement: content => content
})

service.addRule('removeEmptyParagraphs', {
  filter: node => {
    return node.nodeName.toLowerCase() === 'p' && node.textContent.trim() === ''
  },
  replacement: () => ''
})

// strip paragraph elements within list items
service.addRule('stripParagraphsInListItems', {
  filter: node => {
    return (
      node.nodeName.toLowerCase() === 'p' &&
      node.parentNode.nodeName.toLowerCase() === 'li'
    )
  },
  replacement: content => content
})

service.addRule('cleanUpNestedLinks', {
  filter: node => {
    if (node.nodeName.toLowerCase() === 'a' && node.previousSibling) {
      return node.previousSibling.textContent.match(/\]\($/)
    }
  },
  replacement: (content, node) => {
    return node.getAttribute('href')
  }
})

// Google docs has a habit of producing nested lists that are not nested
// with valid HTML. Rather than embedding sub lists inside an <li> element they
// are nested in the <ul> or <ol> element.
service.addRule('invalidNestedLists', {
  filter: node => {
    const nodeName = node.nodeName.toLowerCase()
    if (
      (nodeName === 'ul' || nodeName === 'ol') &&
      node.previousElementSibling
    ) {
      const previousNodeName =
        node.previousElementSibling.nodeName.toLowerCase()
      return previousNodeName === 'li'
    }
  },
  replacement: (content, node, options) => {
    content = content
      .replace(/^\n+/, '') // remove leading newlines
      .replace(/\n+$/, '') // replace trailing newlines
      .replace(/\n/gm, `\n${options.listIndent}`) // indent all nested content in the list

    // indent this list to match sibling
    return options.listIndent + content + '\n'
  }
})

// This is ported from https://github.com/domchristie/turndown/blob/80297cebeae4b35c8d299b1741b383c74eddc7c1/src/commonmark-rules.js#L61-L80
// It is modified in the following ways:
// - Only determines ol ordering based on li elements
// - Removes handling of ol start attribute as this doesn't affect Forms output
// - Makes spacing consistent with gov.uk markdown guidance
service.addRule('listItems', {
  filter: 'li',
  replacement: function (content, node, options) {
    content = content
      .replace(/^\n+/, '') // remove leading newlines
      .replace(/\n+$/, '\n') // replace trailing newlines with just a single one
      .replace(/\n/gm, `\n${options.listIndent}`) // indent all nested content in the list

    let prefix = options.bulletListMarker + ' '
    const parent = node.parentNode
    if (parent.nodeName.toLowerCase() === 'ol') {
      const listItems = Array.prototype.filter.call(
        parent.children,
        element => element.nodeName.toLowerCase() === 'li'
      )
      const index = Array.prototype.indexOf.call(listItems, node)
      prefix = (index + 1).toString() + '. '
    }
    return (
      prefix +
      content +
      (node.nextSibling && !content.endsWith('\n') ? '\n' : '')
    )
  }
})

service.addRule('removeMsWordCommentElements', {
  filter: node => {
    const nodeName = node.nodeName.toLowerCase()
    const classList = node.classList

    if (nodeName === 'hr' && classList.contains('msocomoff')) {
      return true
    }
    if (nodeName === 'span' && classList.contains('MsoCommentReference')) {
      return true
    }
    if (nodeName === 'div' && classList.contains('msocomtxt')) {
      return true
    }
  },
  replacement: (content, node) => {
    // comments can get caught with a non-breaking space trailing, so we'll
    // manually remove it
    if (node.flankingWhitespace) {
      if (node.flankingWhitespace.leading === '\xA0') {
        node.flankingWhitespace.leading = ''
      }
      if (node.flankingWhitespace.trailing === '\xA0') {
        node.flankingWhitespace.trailing = ''
      }
    }
    return ''
  }
})

service.addRule('removeMsWordListBullets', {
  filter: node => {
    if (node.nodeName.toLowerCase() === 'span') {
      const style = node.getAttribute('style')
      return style ? style.match(/mso-list:ignore/i) : false
    }
  },
  replacement: () => ''
})

// Given a node it returns the Microsoft Word list level, returning undefined
// for an item that isn't a MS Word list node
const getMsWordListLevel = node => {
  if (node.nodeName.toLowerCase() !== 'p') {
    return
  }

  const style = node.getAttribute('style')
  const levelMatch = style?.match(/mso-list/i)
    ? style.match(/level(\d+)/)
    : null
  return levelMatch ? parseInt(levelMatch[1], 10) : undefined
}

const isMsWordListItem = node => {
  return !!getMsWordListLevel(node)
}

// Based on a node that is a list item in a MS Word document, this returns
// the marker for the list.
const msWordListMarker = (node, bulletListMarker) => {
  const markerElement = node.querySelector('span[style="mso-list:Ignore"]')

  // assume the presence of a period in a marker is an indicator of an
  // ordered list
  if (!markerElement?.textContent.match(/\./)) {
    return bulletListMarker
  }

  const nodeLevel = getMsWordListLevel(node)

  let item = 1
  let potentialListItem = node.previousElementSibling

  // loop through previous siblings to count list items
  while (potentialListItem) {
    const itemLevel = getMsWordListLevel(potentialListItem)

    // if there are no more list items or we encounter the lists parent
    // we don't need to count further
    if (!itemLevel || itemLevel < nodeLevel) {
      break
    }

    // if on same level increment the list items
    if (nodeLevel === itemLevel) {
      item += 1
    }

    potentialListItem = potentialListItem.previousElementSibling
  }

  return `${item}.`
}

service.addRule('addMsWordListItem', {
  filter: node => isMsWordListItem(node),
  replacement: (content, node, options) => {
    const firstListItem =
      !node.previousElementSibling ||
      !isMsWordListItem(node.previousElementSibling)
    let prefix = firstListItem ? '\n\n' : ''

    // we can determine the nesting of a list by a mso-list style attribute
    // with a level
    const nodeLevel = getMsWordListLevel(node)
    for (let i = 1; i < nodeLevel; i++) {
      prefix += options.listIndent
    }

    const lastListItem =
      !node.nextElementSibling || !isMsWordListItem(node.nextElementSibling)
    const suffix = lastListItem ? '\n\n' : '\n'
    const listMarker = msWordListMarker(node, options.bulletListMarker)

    return `${prefix}${listMarker} ${content.trim()}${suffix}`
  }
})

// Remove links that have same href as link text and are the only content
// in a pasted document. This is because we assume here that they're trying
// to paste just a plain text URL.
service.addRule('removeAddressBarLinks', {
  filter: (node, options) => {
    if (node.nodeName.toLowerCase() !== 'a' || !node.getAttribute('href')) {
      return
    }

    const href = node.getAttribute('href').trim()

    return (
      href === node.textContent.trim() &&
      href === node.ownerDocument.body.textContent.trim()
    )
  },
  replacement: content => content
})

const removeBrParagraphs = markdown => {
  // This finds places where we have a br in a paragraph on it's own and
  // removes it.
  //
  // E.g. if we have HTML of <b><p>Text</p><br><p>More text</p></b> (as google
  // docs can easily produce) which produces markdown of
  // "Text\n\n  \n\nMore Text". This regexp can strip this back to be
  // Text\n\nMore Text
  const regExp = new RegExp(`\n(${service.options.br}\n)+\n?`, 'g')
  return markdown.replace(regExp, '\n')
}

const extractHeadingsFromLists = markdown => {
  // This finds instances of headings within ordered lists and replaces them
  // with the headings only. This only applies to H2 and H3.
  const headingsInListsRegExp = /\d\.\s(#{2,3})/g
  return markdown.replace(headingsInListsRegExp, '$1')
}

const postProcess = markdown => {
  const markdownWithExtractedHeadings = extractHeadingsFromLists(markdown)
  const bulletsReplaced = replaceBulletCharacters(markdownWithExtractedHeadings)
  const brsRemoved = removeBrParagraphs(bulletsReplaced)
  const whitespaceStripped = brsRemoved.trim()
  return whitespaceStripped
}

const htmlToMarkdown = html => {
  const markdown = service.turndown(html)
  return postProcess(markdown)
}

export default htmlToMarkdown
