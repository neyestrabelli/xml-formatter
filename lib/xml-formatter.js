'use babel';

import XmlFormatterView from './xml-formatter-view';
import { CompositeDisposable } from 'atom';

export default {

    config: {
        "xmlUtf8Header": {
                type: 'boolean',
                default: true
        } ,
        "numberCharIndent": {
            type: 'integer',
            default: 2
        },
        "useTab": {
            type: 'string',
             default:'false',
             enum: ['false','true']
        },
        "numberCharIndent": {
            type: 'integer',
            default: 2
        },
        "indentCharacter": {
            type: 'string',
            default: " ",
        },
        "endLineCharacter": {
         type: 'string',
         default: 'CR+LF (\\r\\n)',
         enum:  ['CR+LF (\\r\\n)','LF (\\n)']
        }
    },
  xmlFormatterView: null,
  modalPanel: null,
  subscriptions: null,

  activate(state) {
    this.xmlFormatterView = new XmlFormatterView(state.xmlFormatterViewState);
    this.modalPanel = atom.workspace.addModalPanel({
      item: this.xmlFormatterView.getElement(),
      visible: false
    });

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(
        atom.commands.add('atom-workspace', { 'xml-formatter:indent': () => this.indent(),
      'xml-formatter:selected': () => this.indent(true),
      'xml-formatter:minify': () => this.minify()
    }));
  },

  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.xmlFormatterView.destroy();
  },

  serialize() {
    return {
      xmlFormatterViewState: this.xmlFormatterView.serialize()
    };
  },

 str_pad(input, pad_length, pad_string, pad_type) {
  var half, pad_to_go, str_pad_repeater;
  half = "";
  pad_to_go = void 0;
  str_pad_repeater = function(s, len) {
    var collect, i;
    collect = "";
    i = void 0;
    while (collect.length < len) {
      collect += s;
    }
    collect = collect.substr(0, len);
    return collect;
  };
  input += "";
  pad_string = (pad_string !== undefined ? pad_string : " ");
  if (pad_type !== "STR_PAD_LEFT" && pad_type !== "STR_PAD_RIGHT" && pad_type !== "STR_PAD_BOTH") {
    pad_type = "STR_PAD_RIGHT";
  }
  if ((pad_to_go = pad_length - input.length) > 0) {
    if (pad_type === "STR_PAD_LEFT") {
      input = str_pad_repeater(pad_string, pad_to_go) + input;
    } else if (pad_type === "STR_PAD_RIGHT") {
      input = input + str_pad_repeater(pad_string, pad_to_go);
    } else if (pad_type === "STR_PAD_BOTH") {
      half = str_pad_repeater(pad_string, Math.ceil(pad_to_go / 2));
      input = half + input + half;
      input = input.substr(0, pad_length);
    }
  }
  return input;
 },
 indent(sel) {
   var allComments, allText, editor, formatted, i, indent, j, len, node, opts, pad, padding, ref, reg, regComments, regXML, reg_cdata, replace_cdata_end, replace_cdata_ini, selected, xml;
   selected = sel ? true : false;
   opts = {};
   opts.xml_utf8_header = atom.config.get('xml-formatter.xmlUtf8Header');
   opts.use_tab = atom.config.get('xml-formatter.useTab');
   opts.number_char_indent = atom.config.get('xml-formatter.numberCharIndent');
   opts.indent_character = atom.config.get('xml-formatter.indentCharacter');
   if (opts.use_tab === "true") {
     opts.indent_character = "\t";
   }
   opts.crlf = atom.config.get('xml-formatter.endLineCharacter');
   if (opts.crlf === "CR+LF (\\r\\n)") {
     opts.crlf = "\r\n";
   } else {
     opts.crlf = "\n";
   }
   editor = atom.workspace.getActiveTextEditor();
   if (editor) {
     allText = selected ? editor.getSelectedText() : editor.getText();
     // regComments = /\n?<!--[\s\S]*?-->/g;
     // allComments = allText.match(regComments);
     // allText = allText.replace(regComments, '@comment_in');
     allText = allText.replace(/^\s+|\s+$/g, "");
     formatted = '';
     if (opts.xml_utf8_header) {
       regXML = /^<\?xml.+\?>/;
       allText = allText.replace(regXML, '');
       allText = '<?xml version="1.0" encoding="UTF-8"?>' + allText;
     }
     xml = allText.replace(/\r|\n/g, '');
     reg_cdata = /(<!\[)(.+?)(\]\]>)/g;
     xml = xml.replace(reg_cdata, '@cdata_ini@$2@cdata_end@');
     reg = /(>)\s*(<)(\/*)/g;
     xml = xml.replace(reg, '$1\r\n$2$3');
     pad = 0;
     ref = xml.split('\r\n');
     for (i = j = 0, len = ref.length; j < len; i = ++j) {
       node = ref[i];
       indent = 0;
       if (node.match(/.+<\/\w[^>]*>$/)) {
         indent = 0;
       } else if (node.match(/^<\/\w/)) {
         if (pad !== 0) {
           pad -= 1;
         }
       } else if (node.match(/^<\w/) && !node.match(/\/>/)) {
         indent = 1;
       } else {
         indent = 0;
       }
       padding = "";
       i = 0;
       while (i < pad) {
         padding += this.str_pad("", opts.number_char_indent, opts.indent_character);
         i++;
       }
       formatted += padding + node + opts.crlf;
       pad += indent;
     }
     replace_cdata_ini = /@cdata_ini@/g;
     replace_cdata_end = /@cdata_end@/g;
     formatted = formatted.replace(replace_cdata_ini, '<![');
     formatted = formatted.replace(replace_cdata_end, ']]>');
     // allComments.forEach(function(value,index){
     //        formatted = formatted.replace(/@comment_in/,value + opts.crlf);
     // });

     if (selected) {
       return editor.insertText(formatted);
     } else {
       return editor.setText(formatted);
     }
   }
},
    minify() {
    var allText, editor;
    editor = atom.workspace.getActiveTextEditor();
    allText = editor.getText();
    allText = allText.replace(/\r|\n/g, '');
    allText = allText.replace(/^\s+|\s+$/g, "");
    allText = allText.replace(/(>)(\s+[^<])/g, "$1");
    return editor.setText(allText);
    }


};
