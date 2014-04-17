module.exports =
  configDefaults:
      xml_utf8_header: true

  activate: ->
    atom.workspaceView.command "xml-formatter:indent", => @indent()

  indent: ->
    opts = {}
    for configKey, defaultValue of @configDefaults
       opts[configKey] = atom.config.get('xml-formatter.'+configKey) ? defaultValue
    editor = atom.workspace.getActiveEditor()
    if editor
      allText = editor.getText()
      formatted = ''
      if opts.xml_utf8_header
        regXML = /^<\?xml.+\?>/
        allText = allText.replace(regXML,'')
        allText = '<?xml version="1.0" encoding="UTF-8"?>' +  allText 

      reg = /(>)\s*(<)(\/*)/g
      xml = allText.replace(/\r|\n/g, '')
      xml = xml.replace(reg, '$1\r\n$2$3')
      pad = 0;
      for node, i in xml.split('\r\n')
          indent = 0
          if node.match(/.+<\/\w[^>]*>$/)
            indent = 0
          else if node.match(/^<\/\w/)
            pad -= 1  unless pad is 0
          else if node.match(/^<\w[^>]*[^\/]>.*$/)
            indent = 1
          else
            indent = 0
          padding = ""
          i = 0

          while i < pad
            padding += "  "
            i++
          formatted += padding + node + "\r\n"
          pad += indent

      editor.setText(formatted)
