REGEX_COMMENT_MULTILINE = new RegExp "\\/\\*([^*]|[\\r\\n]|(\\*+([^*/]|[\\r\\n])))*\\*+\\/", "g"

beautify_json = require("js-beautify").js_beautify
camel_case = (string) -> string.replace /-([a-z])/g, (matches) -> matches[1].toUpperCase()
merge = (base, objects...) ->
    for object in objects
        for own property, value of object
            if typeof base[property] is "object" && typeof value is "object"
                merge base[property], value
            else
                base[property] = value

class CssCompiler
    constructor: (@lexer, @parser) ->
    compile: (css) =>
        ast = @lexer.lex css
        tss = @parser.parseTree ast

class CssLexer
    lex: (css) =>
        css = css.replace REGEX_COMMENT_MULTILINE, ""

        parse = require "css-parse"
        ast = parse css

        return ast

class TssCssTreeParser
    parseTree: (ast) =>
        tss_object = {}

        for rule in ast.stylesheet.rules
            selectors = for selector in rule.selectors
                selector.replace "][", " "

            declarations = {}
            for declaration in rule.declarations
                property = @normaliseProperty declaration.property
                value = @normaliseValue declaration.value

                if /^font[A-Z]/.test property
                    original_value = value
                    value = {}
                    value[property] = original_value
                    property = "font"

                declaration = {}
                declaration[property] = value
                
                merge declarations, declaration

            for selector in selectors
                tss_object[selector] = {} unless tss_object[selector]?
                merge tss_object[selector], declarations

        tss_text = JSON.stringify tss_object
        tss = beautify_json tss_text,
            indent_size: 4
            indent_char = " "

        # Remove {}'s around JSON
        tss = tss.replace /^.*\{|\}.*$/g, ""
        # Remove first indentation
        tss = tss.replace /^    /mg, ""

        return tss

    normaliseProperty: camel_case
    normaliseValue: (value) -> value.replace /"|'/g, ""

parse = (css) ->
    compiler = new CssCompiler new CssLexer, new TssCssTreeParser
    tss = compiler.compile css

    return tss

# Export
parse.CssCompiler = CssCompiler
parse.CssLexer = CssLexer
parse.TssCssTreeParser = TssCssTreeParser

module.exports = parse