module.exports =
  activate: ->
    atom.workspaceView.command "xml-formatter:indent", => @indent()

  indent: ->
    # This assumes the active pane item is an editor
    editor = atom.workspace.getActiveEditor()
    # get all text
    if editor
      formatted = ''
      allText = editor.getText()
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
