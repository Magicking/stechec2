#  -*- ruby -*-
# Stechec project is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# The complete GNU General Public Licence Notice can be found as the
# `NOTICE' file in the root directory.
#
# Copyright (C) 2005, 2006, 2007 Prologin
#

class GoFileGenerator < CxxProto
  def initialize
    super
    @lang = "Go"
  end

  def print_comment(str)
    @f.puts '// ' + str if str
  end

  def print_multiline_comment(str, prestr = '')
    return unless str
    @f.puts prestr + '/*'
    str.each_line {|s| @f.print prestr, s }
    @f.puts "", prestr + "*/"
  end

  def go_type(type)
    if type.is_array?
      "[]#{type.type.name}"
    elsif type.is_nil?
      ""
    else
      type.name
    end
  end

  def go_build_args(args, force_parenthis = true)
    buf = ""
    if args.length > 1
      force_parenthis = true
    end
    if force_parenthis
      buf += "("
    end
    # TODO factorize args when possible
    args = args.map { |arg| "#{arg.name} #{go_type(arg.type)}" }
    buf += args.join(", ")
    if force_parenthis
      buf += ")"
    end
    buf
  end

  def go_proto(fn)
    buf = "func " + fn.name
    buf += go_build_args(fn.args, true)
    if not fn.ret.is_nil?
      buf += " " + go_type(fn.ret)
    end
    buf += " {"
    buf
  end

  def camel_case(str)
    strs = str.split("_")
    strs.each { |s| s.capitalize! }
    strs.join
  end

  def build_structs
    build_structs_generic do |field, type|
      "#{camel_case(field)} #{go_type(@types[type])}"
    end
  end

  def build_structs_generic(&show_field)
    for_each_struct do |x|
      @f.puts "struct #{camel_case(x['str_name'])} {"
      x['str_field'].each do |f|
        @f.print "\t#{show_field.call(f[0], f[1])} // ", f[2], "\n"
      end
      @f.puts "}"
    end
  end

  def build_constants(prestr = '')
    $conf['constant'].delete_if {|x| x['doc_extra'] }
    @f.print "const (\n"
    $conf['constant'].each do |x|
      @f.print "\t", x['cst_type'], " ", x['cst_name'], " = ", x['cst_val'], " "
      print_comment(x['cst_comment'])
    end
    @f.puts ")\n"
  end

  def build_enums
    for_each_enum do |x|
      @f.puts "// Enum #{camel_case(x['enum_name'])}"
      @f.print "const (\n"
      modifier = " = iota"
      x['enum_field'].each do |f|
        @f.print "\t", camel_case(f[0]), modifier, ", "
        @f.print "// <- ", f[1], "\n"
        modifier = ""
      end
    end
    @f.puts ")\n"
  end

  def generate_header()
    @f = File.open(@path + @api_file, 'w')
    print_banner "generator_go.rb"
    @f.puts "package prologin",""
    build_constants
    build_enums
    build_structs
    for_each_user_fun do |fn|
      @f.print go_proto(fn)
    end
    @f.close
  end

  def generate_source()
    @f = File.open(@path + @source_file, 'w')
    print_banner "generator_go.rb"
    @f.print "package prologin\n"
    @f.puts
    for_each_user_fun do |fn|
      @f.print go_proto(fn)
      print_body "  // fonction a completer"
    end
    @f.close
  end

  def generate_makefile
    target = $conf['conf']['player_lib']
    @f = File.open(@path + "Makefile", 'w')
    @f.print <<-EOF
# -*- Makefile -*-

lib_TARGETS = #{target}

# Tu peux rajouter des fichiers sources, headers, ou changer
# des flags de compilation.
#{target}-srcs = #{@source_file}
#{target}-dists =
#{target}-goflags = -ggdb3 -Wall -std=c++11

# Evite de toucher a ce qui suit
#{target}-dists += #{@api_file}
STECHEC_LANG=go
include ../includes/rules.mk
    EOF
    @f.close
  end

  def build()
    @path = Pathname.new($install_path) + "go"
    @api_file = $conf['conf']['player_filename'] + '_api' + '.go'
    @source_file = $conf['conf']['player_filename'] + '.go'

    generate_header
    generate_source
    generate_makefile
  end

end
