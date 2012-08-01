fs     = require 'fs'
path   = require 'path'
{exec} = require 'child_process'
uglify = require "uglify-js"

# Make sure we have our dependencies
try
  colors     = require 'colors'
  wrench     = require 'wrench'
  coffeelint = require 'coffeelint'
catch error
  console.error 'Please run `npm install` first'
  process.exit 1

# Setup directory paths
paths =
  tmp: 'tmp'
  spec: 'spec'
  build: 'build'
  src: 'src'

paths.tmpSrc = path.join paths.tmp, 'src'
paths.tmpSpec = path.join paths.tmp, 'spec'
paths.srcScss = path.join paths.src, 'scss'

# Create directories if they do not already exist
for dir in [paths.build, paths.tmp]
  fs.mkdirSync dir, '0755' if not fs.existsSync dir

## = APP FILES = ##
appFiles  = [
  # omit src/ and .coffee to make the below lines a little shorter
  'namespace'
  'chronos'
  'picker'
  'dateFormatter'
  'panelMonth'
  'animator'
  'plugin'
]

coffeeLintConfig =
  no_tabs:
    level: 'error'
  no_trailing_whitespace:
    level: 'error'
  max_line_length:
    value: 80
    level: 'error'
  camel_case_classes:
    level: 'error'
  indentation:
    value: 2
    level: 'error'
  no_implicit_braces:
    level: 'ignore'
  no_trailing_semicolons:
    level: 'error'
  no_plusplus:
    level: 'ignore'
  no_throwing_strings:
    level: 'error'
  no_backticks:
    level: 'warn'
  line_endings:
    value: 'unix'
    level: 'warn'

option '-v', '--version [VERSION]', 'set the version for task:build or task:minify'
task 'build', 'Compiles JavaScript file for production use', (options) ->
  version = options.version ||= "full"
  outputFilename = "chronos-#{version}"
  fullSource = path.join(paths.tmpSrc, "#{outputFilename}.coffee")

  console.log "Combining CoffeeScript".yellow
  appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile path.join(paths.src, "#{file}.coffee"), 'utf8', (err, fileContents) ->
      if err
        console.error "Error encountered while reading file: #{file.coffee}".red
        console.error err
        process.exit 1
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
    fs.writeFile fullSource, appContents.join('\n\n'), 'utf8', (err) ->
      if err
        console.error "Error encountered while writing file: 'chronos-full.coffee'".red
        console.error err
        process.exit 1
      exec "coffee --compile --bare --output #{paths.build} #{fullSource}", (e, o, se) ->
        if e
          console.error "Error encountered while compiling CoffeeScript".red
          console.error se
          process.exit 1
        fs.unlink path.join(paths.tmpSrc, "chronos-full.coffee"), (err) ->
          if e
            console.error "Unable to unlink chronos-full.coffee".red
            console.error se
            process.exit 1
          else
            console.log "CoffeeScript Compiled".green

task 'minify', 'Minifies a compiled js file using Uglifier', (options) ->
  version = options.version ||= "full"
  sourceFilename = "chronos-#{version}"
  fullSource = path.join(paths.build, "#{sourceFilename}.js")
  outputFilename = "#{sourceFilename}.min"
  fullOutput = path.join(paths.build, "#{outputFilename}.js")

  if fs.existsSync(fullSource)
    console.log "Minifying with Uglifier".yellow
    exec "node_modules/uglify-js/bin/uglifyjs -nc --output #{fullOutput} #{fullSource}", (err, stdout, stderr) ->
      if err
        console.error "Error encountered during minification".red
        console.error stderr
        process.exit 1
      else
        console.log "Javascript Minified".green
  else
    console.error "Could not find #{fullSource}. Did you run the 'build' task yet?".red
    process.exit 1


task 'watch', 'Automatically recompile CoffeeScript files to JavaScript', ->
  console.log "Watching coffee files for changes, press Control-C to quit".yellow
  srcWatcher  = exec "coffee --compile --bare --watch --output #{paths.tmpSrc} #{paths.src}"
  srcWatcher.stderr.on 'data', (data) -> console.error stripEndline(data).red
  srcWatcher.stdout.on 'data', (data) ->
    # Hacky way to find if something compiled successfully
    if /compiled src/.test data
      process.stdout.write data.green
      # Re-calculate deps.js
      #updateDepsDebounced()
    else
      process.stderr.write data.red
      filenameMatch = data.match /^In src\/(.*)\.coffee/
      if filenameMatch and filenameMatch[1]
        filepath = path.join(paths.tmpSrc, "#{filenameMatch[1]}.js")
        # Add warning into code since watch window is in bg
        insertJsError filepath, "CoffeeScript compilation error: #{data}"

  testWatcher = exec "coffee --compile --bare --watch --output #{paths.tmpSpec} #{paths.spec}"
  testWatcher.stderr.on 'data', stdErrorStreamer()
  testWatcher.stdout.on 'data', (data) ->
    if /compiled/.test data
      process.stdout.write data.green
    else
      process.stderr.write data.red


# task 'lint', 'Check CoffeeScript for lint', ->
#   console.log "Checking *.coffee for lint".yellow
#   pass = "✔".green
#   warn = "⚠".yellow
#   fail = "✖".red
#   getSourceFilePaths().forEach (filepath) ->
#     fs.readFile filepath, (err, data) ->
#       shortPath = filepath.substr paths.srcDir.length + 1
#       result = coffeelint.lint data.toString(), coffeeLintConfig
#       if result.length
#         hasError = result.some (res) -> res.level is 'error'
#         level = if hasError then fail else warn
#         console.error "#{level}  #{shortPath}".red
#         for res in result
#           level = if res.level is 'error' then fail else warn
#           console.error "   #{level}  Line #{res.lineNumber}: #{res.message}"
#       else
#         console.log "#{pass}  #{shortPath}".green



# Helper for stripping trailing endline when outputting
stripEndline = (str) ->
  return str.slice(0, str.length - 1) if str[str.length - 1] is "\n"
  return str

# Helper for inserting error text into a given file
insertJsError = (filepath, js) ->
  jsFile = fs.openSync(filepath, 'w')
  fs.writeSync jsFile, """console.error(unescape("#{escape js}"))""" + "\n"
  fs.closeSync jsFile

stdOutStreamer = (filter) ->
  (str) ->
    str = filter str if filter
    process.stderr.write str

stdErrorStreamer = (filter) ->
  (str) ->
    str = filter str if filter
    process.stderr.write str.red
