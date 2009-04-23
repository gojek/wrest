# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{wrest}
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sidu Ponnappa"]
  s.date = %q{2009-04-24}
  s.default_executable = %q{wrest}
  s.description = %q{Wrest is a REST client library which allows you to quickly build object oriented wrappers around any web service. It has two main components - Wrest Core and Wrest::Resource.}
  s.email = %q{ckponnappa@gmail.com}
  s.executables = ["wrest"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "bin/jwrest",
    "bin/wrest",
    "bin/wrest_shell.rb",
    "lib/wrest.rb",
    "lib/wrest/components.rb",
    "lib/wrest/components/attributes_container.rb",
    "lib/wrest/components/mutators.rb",
    "lib/wrest/components/mutators/base.rb",
    "lib/wrest/components/mutators/camel_to_snake_case.rb",
    "lib/wrest/components/mutators/xml_simple_type_caster.rb",
    "lib/wrest/components/translators.rb",
    "lib/wrest/components/translators/content_types.rb",
    "lib/wrest/components/translators/json.rb",
    "lib/wrest/components/translators/xml.rb",
    "lib/wrest/components/typecast_helpers.rb",
    "lib/wrest/core_ext/hash.rb",
    "lib/wrest/core_ext/hash/conversions.rb",
    "lib/wrest/core_ext/string.rb",
    "lib/wrest/core_ext/string/conversions.rb",
    "lib/wrest/exceptions.rb",
    "lib/wrest/exceptions/method_not_overridden_exception.rb",
    "lib/wrest/exceptions/unsupported_content_type_exception.rb",
    "lib/wrest/resource.rb",
    "lib/wrest/resource/base.rb",
    "lib/wrest/resource/collection.rb",
    "lib/wrest/response.rb",
    "lib/wrest/uri.rb",
    "lib/wrest/uri_template.rb",
    "lib/wrest/version.rb",
    "spec/custom_matchers/custom_matchers.rb",
    "spec/rcov.opts",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "spec/wrest/components/attributes_container_spec.rb",
    "spec/wrest/components/mutators/base_spec.rb",
    "spec/wrest/components/mutators/camel_to_snake_spec.rb",
    "spec/wrest/components/mutators/xml_simple_type_caster_spec.rb",
    "spec/wrest/components/translators/xml_spec.rb",
    "spec/wrest/components/translators_spec.rb",
    "spec/wrest/core_ext/hash/conversions_spec.rb",
    "spec/wrest/core_ext/string/conversions_spec.rb",
    "spec/wrest/resource/base_spec.rb",
    "spec/wrest/response_spec.rb",
    "spec/wrest/uri_spec.rb",
    "spec/wrest/uri_template_spec.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/kaiwren/wrest}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{wrest}
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{REST client library for Ruby.}
  s.test_files = [
    "spec/custom_matchers/custom_matchers.rb",
    "spec/spec_helper.rb",
    "spec/wrest/components/attributes_container_spec.rb",
    "spec/wrest/components/mutators/base_spec.rb",
    "spec/wrest/components/mutators/camel_to_snake_spec.rb",
    "spec/wrest/components/mutators/xml_simple_type_caster_spec.rb",
    "spec/wrest/components/translators/xml_spec.rb",
    "spec/wrest/components/translators_spec.rb",
    "spec/wrest/core_ext/hash/conversions_spec.rb",
    "spec/wrest/core_ext/string/conversions_spec.rb",
    "spec/wrest/resource/base_spec.rb",
    "spec/wrest/response_spec.rb",
    "spec/wrest/uri_spec.rb",
    "spec/wrest/uri_template_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.1.0"])
      s.add_runtime_dependency(%q<xml-simple>, [">= 1.0.11"])
      s.add_runtime_dependency(%q<json>, [">= 1.1.3"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.1.0"])
      s.add_dependency(%q<xml-simple>, [">= 1.0.11"])
      s.add_dependency(%q<json>, [">= 1.1.3"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.1.0"])
    s.add_dependency(%q<xml-simple>, [">= 1.0.11"])
    s.add_dependency(%q<json>, [">= 1.1.3"])
  end
end
