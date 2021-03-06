require 'delegate'

module Generator
  class Implementation
    include Files::TrackFiles
    include Files::MetadataFiles
    include TemplateValuesFactory

    def initialize(paths:, slug:)
      @paths = paths
      @slug = slug
    end

    attr_reader :paths, :slug

    def version
      tests_version.to_i
    end

    def update_tests_version
      tests_version.increment
    end

    def update_example_solution
      example_solution.update_version(version)
    end

    def create_tests_file
      minitest_tests.generate(
        template: tests_template.to_s,
        values: template_values
      )
    end

    def exercise_name
      @exercise_name ||= slug.tr('-', '_')
    end
  end

  # This exists to give us a clue as to what we are delegating to.
  class ImplementationDelegator < SimpleDelegator
  end

  # A implementation that also logs its progress.
  class LoggingImplementation < ImplementationDelegator
    def initialize(implementation:, logger:)
      __setobj__ @implementation = implementation
      @logger = logger
    end

    def update_tests_version
      @implementation.update_tests_version
      @logger.debug "Incremented tests version to #{version}"
    end

    def update_example_solution
      @implementation.update_example_solution
      @logger.debug "Updated version in example solution to #{version}"
    end

    def create_tests_file
      @implementation.create_tests_file
      @logger.info "Generated #{slug} tests version #{version}"
    end
  end
end
