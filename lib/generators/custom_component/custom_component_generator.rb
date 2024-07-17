class CustomComponentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
  class_option :css, type: :boolean, default: false
  class_option :javascript, type: :boolean, default: false

  def copy_view_files
    template "view.rb", "app/components/#{file_name}_component/view.rb"
    copy_file "view.html.erb", "app/components/#{file_name}_component/view.html.erb"
    template "view_spec.rb", "spec/components/#{file_name}_component/view_spec.rb"
    template "preview.rb", "spec/components/#{file_name}_component/#{file_name}_component_preview.rb"

    if options[:css]
      copy_file "_index.scss", "app/components/#{file_name}_component/_index.scss"
    end

    if options[:javascript]
      copy_file "index.js", "app/components/#{file_name}_component/index.js"
      copy_file "index.test.js", "app/components/#{file_name}_component/index.test.js"
    end
  end
end
