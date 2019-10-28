Dir[File.join(Rails.root, "lib", "restriction_creator", "*.rb")].each { |f| require f }

DependentLoader.start(:restrictions) do |on|
  on.success do
    DependentLoader.start(:location_types_restrictions) do |and_on|
      and_on.success do
        restrictions = YAML::load_file(File.join(Rails.root, "app/data/restrictions.yaml"))
        RestrictionCreator.new(restrictions).run!
      end
    end
  end
end
