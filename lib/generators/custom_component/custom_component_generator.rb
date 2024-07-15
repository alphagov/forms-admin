class CustomComponentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_view_files
    template "view.rb", "app/components/#{file_name}_component/view.rb"
    copy_file "view.html.erb", "app/components/#{file_name}_component/view.html.erb"
    template "view_spec.rb", "spec/components/#{file_name}_component/view_spec.rb"
    template "preview.rb", "spec/components/#{file_name}_component/#{file_name}_component_preview.rb"
  end
end
