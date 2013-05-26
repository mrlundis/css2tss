process.env.DEBUG = "*"
logger = require "debug"
info = logger "info"

csstss = require "./compiler"

fs = require "fs"
pkg = JSON.parse fs.readFileSync "#{__dirname}/../package.json", encoding: "utf8"

program = require "commander"
program.version pkg.version
program.usage "<in> [out]"
program.parse process.argv

file_in = program.args[0]
file_out = program.args[1] || (file_in.replace(/\.css$/, "") + ".tss")

info "Input file: #{file_in}"
info "Output file: #{file_out}"

info "Reading..."
css = fs.readFileSync file_in, encoding: "utf8"

info "Compiling..."
tss = csstss css

info "Writing..."
fs.writeFileSync file_out, tss

info "Done."
