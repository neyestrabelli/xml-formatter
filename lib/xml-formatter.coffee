module.exports =
  activate: ->
    atom.workspaceView.command "xml-formatter:indent", => @indent()

  indent: ->
    # This assumes the active pane item is an editor
    editor = atom.workspace.getActiveEditor()
    # get all text
    if editor
      allText = editor.getText()
      xml2js = require 'xml2js'
      parser = new xml2js.Parser()
      builder = new xml2js.Builder()
      #parse and builder new
      parser.parseString allText, (err, result) ->
       if err
         alert('This file is not a xml')
        else
          editor.setText(builder.buildObject(result))
