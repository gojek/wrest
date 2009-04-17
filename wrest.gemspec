# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{wrest}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sidu Ponnappa"]
  s.date = %q{2009-04-18}
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
    "bin/wrest",
    "lib/wrest.rb",
    "lib/wrest/core_ext/string.rb",
    "lib/wrest/core_ext/string/conversions.rb",
    "lib/wrest/exceptions.rb",
    "lib/wrest/exceptions/unsupported_content_type_exception.rb",
    "lib/wrest/mappers.rb",
    "lib/wrest/mappers/attributes_container.rb",
    "lib/wrest/mappers/resource.rb",
    "lib/wrest/mappers/resource/base.rb",
    "lib/wrest/mappers/resource/collection.rb",
    "lib/wrest/mappers/simple_resource.rb",
    "lib/wrest/response.rb",
    "lib/wrest/translators.rb",
    "lib/wrest/translators/content_types.rb",
    "lib/wrest/translators/json.rb",
    "lib/wrest/translators/typed_hash.rb",
    "lib/wrest/translators/xml.rb",
    "lib/wrest/uri.rb",
    "lib/wrest/uri_template.rb",
    "lib/wrest/version.rb",
    "spec/custom_matchers/custom_matchers.rb",
    "spec/rcov.opts",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "spec/wrest/mappers/attributes_container_spec.rb",
    "spec/wrest/mappers/resource/base_spec.rb",
    "spec/wrest/mappers/simple_resource_spec.rb",
    "spec/wrest/response_spec.rb",
    "spec/wrest/translators/typed_hash_spec.rb",
    "spec/wrest/translators/xml_spec.rb",
    "spec/wrest/translators_spec.rb",
    "spec/wrest/uri_spec.rb",
    "spec/wrest/uri_template_spec.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/kaiwren/wrest}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{REST client library for Ruby.}
  s.test_files = [
    "spec/custom_matchers/custom_matchers.rb",
    "spec/spec_helper.rb",
    "spec/wrest/mappers/attributes_container_spec.rb",
    "spec/wrest/mappers/resource/base_spec.rb",
    "spec/wrest/mappers/simple_resource_spec.rb",
    "spec/wrest/response_spec.rb",
    "spec/wrest/translators/typed_hash_spec.rb",
    "spec/wrest/translators/xml_spec.rb",
    "spec/wrest/translators_spec.rb",
    "spec/wrest/uri_spec.rb",
    "spec/wrest/uri_template_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.1.0"])
      s.add_runtime_dependency(%q<json>, [">= 1.1.3"])
      s.add_runtime_dependency(%q<xml-simple>, [">= 1.0.11"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.1.0"])
      s.add_dependency(%q<json>, [">= 1.1.3"])
      s.add_dependency(%q<xml-simple>, [">= 1.0.11"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.1.0"])
    s.add_dependency(%q<json>, [">= 1.1.3"])
    s.add_dependency(%q<xml-simple>, [">= 1.0.11"])
  end
end
