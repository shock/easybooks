# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-prof}
  s.version = "0.8.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shugo Maeda, Charlie Savage, Roger Pack"]
  s.date = %q{2010-07-09}
  s.default_executable = %q{ruby-prof}
  s.description = %q{ruby-prof is a fast code profiler for Ruby. It is a C extension and
therefore is many times faster than the standard Ruby profiler. It
supports both flat and graph profiles.  For each method, graph profiles
show how long the method ran, which methods called it and which 
methods it called. RubyProf generate both text and html and can output
it to standard out or to a file.
}
  s.email = %q{shugo@ruby-lang.org, cfis@savagexi.com, rogerdpack@gmail.com}
  s.executables = ["ruby-prof"]
  s.extensions = ["ext/ruby_prof/extconf.rb"]
  s.files = ["Rakefile", "README", "LICENSE", "CHANGES", "bin/ruby-prof", "examples/flat.txt", "examples/graph.html", "examples/graph.txt", "ext/ruby_prof/ruby_prof.c", "ext/ruby_prof/measure_allocations.h", "ext/ruby_prof/measure_cpu_time.h", "ext/ruby_prof/measure_gc_runs.h", "ext/ruby_prof/measure_gc_time.h", "ext/ruby_prof/measure_memory.h", "ext/ruby_prof/measure_process_time.h", "ext/ruby_prof/measure_wall_time.h", "ext/ruby_prof/ruby_prof.h", "ext/ruby_prof/version.h", "ext/ruby_prof/mingw/Rakefile", "ext/ruby_prof/mingw/build.rake", "lib/ruby-prof/abstract_printer.rb", "lib/ruby-prof/aggregate_call_info.rb", "lib/ruby-prof/call_info.rb", "lib/ruby-prof/call_tree_printer.rb", "lib/ruby-prof/flat_printer.rb", "lib/ruby-prof/flat_printer_with_line_numbers.rb", "lib/ruby-prof/graph_html_printer.rb", "lib/ruby-prof/graph_printer.rb", "lib/ruby-prof/method_info.rb", "lib/ruby-prof/symbol_to_proc.rb", "lib/ruby-prof/task.rb", "lib/ruby-prof/test.rb", "lib/ruby-prof.rb", "lib/ruby_prof.so", "lib/unprof.rb", "rails/environment/profile.rb", "rails/example/example_test.rb", "rails/profile_test_helper.rb", "test/aggregate_test.rb", "test/basic_test.rb", "test/current_failures_windows", "test/do_nothing.rb", "test/duplicate_names_test.rb", "test/enumerable_test.rb", "test/exceptions_test.rb", "test/exclude_threads_test.rb", "test/exec_test.rb", "test/line_number_test.rb", "test/measurement_test.rb", "test/module_test.rb", "test/no_method_class_test.rb", "test/prime.rb", "test/prime_test.rb", "test/printers_test.rb", "test/recursive_test.rb", "test/ruby-prof-bin", "test/singleton_test.rb", "test/stack_test.rb", "test/start_stop_test.rb", "test/test_suite.rb", "test/thread_test.rb", "test/unique_call_path_test.rb", "ext/ruby_prof/extconf.rb"]
  s.homepage = %q{http://rubyforge.org/projects/ruby-prof/}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.4")
  s.rubyforge_project = %q{ruby-prof}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Fast Ruby profiler}
  s.test_files = ["test/test_suite.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<os>, [">= 0"])
      s.add_development_dependency(%q<rake-compiler>, [">= 0"])
    else
      s.add_dependency(%q<os>, [">= 0"])
      s.add_dependency(%q<rake-compiler>, [">= 0"])
    end
  else
    s.add_dependency(%q<os>, [">= 0"])
    s.add_dependency(%q<rake-compiler>, [">= 0"])
  end
end
