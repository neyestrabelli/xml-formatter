module.exports =
config:
    xmlUtf8Header:
      type: 'boolean'
      default: true
    useTab:
      type: 'string'
      default:'false'
      enum: ['false','true']
    numberCharIndent:
      type: 'integer'
      default: 2
    indentCharacter:
      type: 'string'
      default: " "
    endLineCharacter:
      type: 'string'
      default: 'CR+LF (\\r\\n)'
      enum:  ['CR+LF (\\r\\n)','LF (\\n)']

  activate: ->
    atom.commands.add 'atom-workspace', "xml-formatter:indent", => @indent()
    atom.config.observe 'xml-formatter.xmlUtf8Header', (value) =>
          @xmlUtf8Header = value
    atom.config.observe 'xml-formatter.useTab', (value) =>
          @useTab = value
    atom.config.observe 'xml-formatter.numberCharIndent', (value) =>
          @numberCharIndent = value
    atom.config.observe 'xml-formatter.indentCharacter', (value) =>
          @indentCharacter = value
      atom.config.observe 'xml-formatter.endLineCharacter', (value) =>
            @endLineCharacter = value

  indent: ->
    opts = {}
    opts.xml_utf8_header = atom.config.get('xml-formatter.xmlUtf8Header')
    opts.use_tab = atom.config.get('xml-formatter.useTab')
    opts.number_char_indent = atom.config.get('xml-formatter.numberCharIndent')
    opts.indent_character = atom.config.get('xml-formatter.indentCharacter')
    opts.indent_character = "\t"  if opts.use_tab is "true"
    opts.crlf = atom.config.get('xml-formatter.endLineCharacter')
    if opts.crlf == "CR+LF (\\r\\n)"
      opts.crlf = "\r\n";
    else
      opts.crlf = "\n";
    editor = atom.workspace.getActiveTextEditor()
    if editor
      allText = editor.getText()
      formatted = ''
      if opts.xml_utf8_header
        regXML = /^<\?xml.+\?>/
        allText = allText.replace(regXML,'')
        allText = '<?xml version="1.0" encoding="UTF-8"?>' +  allText

      xml = allText.replace(/\r|\n/g, '')
      reg_cdata = /(<!\[)(.+?)(\]\]>)/g
      xml = xml.replace(reg_cdata,'@cdata_ini@$2@cdata_end@')
      reg = /(>)\s*(<)(\/*)/g
      xml = xml.replace(reg, '$1\r\n$2$3')
      pad = 0;
      for node, i in xml.split('\r\n')
          indent = 0
          if node.match(/.+<\/\w[^>]*>$/)
            indent = 0
          else if node.match(/^<\/\w/)
            pad -= 1  unless pad is 0
          else if node.match(/^<\w/) and !node.match(/\/>/)
            indent = 1
          else
            indent = 0
          padding = ""
          i = 0

          while i < pad
            padding += str_pad "", opts.number_char_indent, opts.indent_character
            i++
          formatted += padding + node + opts.crlf
          pad += indent
      replace_cdata_ini = /@cdata_ini@/g
      replace_cdata_end = /@cdata_end@/g
      formatted = formatted.replace(replace_cdata_ini,'<![')
      formatted = formatted.replace(replace_cdata_end,']]>')
      editor.setText(formatted)

str_pad = (input, pad_length, pad_string, pad_type) ->

  # Returns input string padded on the left or right to specified length with pad_string
  #
  # version: 1009.2513
  # discuss at: http://phpjs.org/functions/str_pad
  # +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  # + namespaced by: Michael White (http://getsprink.com)
  # +      input by: Marco van Oort
  # +   bugfixed by: Brett Zamir (http://brett-zamir.me)
  # *     example 1: str_pad('Kevin van Zonneveld', 30, '-=', 'STR_PAD_LEFT');
  # *     returns 1: '-=-=-=-=-=-Kevin van Zonneveld'
  # *     example 2: str_pad('Kevin van Zonneveld', 30, '-', 'STR_PAD_BOTH');
  # *     returns 2: '------Kevin van Zonneveld-----'
  half = ""
  pad_to_go = undefined
  str_pad_repeater = (s, len) ->
    collect = ""
    i = undefined
    collect += s  while collect.length < len
    collect = collect.substr(0, len)
    collect

  input += ""
  pad_string = (if pad_string isnt `undefined` then pad_string else " ")
  pad_type = "STR_PAD_RIGHT"  if pad_type isnt "STR_PAD_LEFT" and pad_type isnt "STR_PAD_RIGHT" and pad_type isnt "STR_PAD_BOTH"
  if (pad_to_go = pad_length - input.length) > 0
    if pad_type is "STR_PAD_LEFT"
      input = str_pad_repeater(pad_string, pad_to_go) + input
    else if pad_type is "STR_PAD_RIGHT"
      input = input + str_pad_repeater(pad_string, pad_to_go)
    else if pad_type is "STR_PAD_BOTH"
      half = str_pad_repeater(pad_string, Math.ceil(pad_to_go / 2))
      input = half + input + half
      input = input.substr(0, pad_length)
  input
