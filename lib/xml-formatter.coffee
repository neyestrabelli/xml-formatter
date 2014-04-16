module.exports =
  configDefaults:
    utf8_encoding_header:true

  activate: ->
    atom.workspaceView.command "xml-formatter:indent", => @indent()

  indent: ->
    opts = {}
    for configKey, defaultValue of @configDefaults
      opts[configKey] = atom.config.get('xml-formatter.'+configKey) ? defaultValue

    xmldef =  xmldec: {}
    if opts.utf8_encoding_header
         xmldef = xmldec: {'version': '1.0','encoding': 'UTF-8'}

    # This assumes the active pane item is an editor
    editor = atom.workspace.getActiveEditor()
    # get all text
    if editor
      allText = editor.getText()
      xml2js = require 'xml2js'
      parser = new xml2js.Parser()
      builder = new xml2js.Builder(xmldef)
      #parse and builder new
      parser.parseString allText, (err, result) ->
       if err
         alert('This file is not a xml')
        else
          editor.setText(builder.buildObject(result))
