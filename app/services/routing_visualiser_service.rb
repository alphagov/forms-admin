# frozen_string_literal: true
require_relative "../helpers/application_helper"
require 'open3'

class RoutingVisualiserService
  class << self
    include ApplicationHelper
    def generate(form)
      dot_file_lines = [
        "digraph g {",
        "splines=ortho",
        "node [shape=box, rankjustify=min]",
        "start[label=Start]",
        "end[label=\"Check your answers before submitting\"]",
      ]

      next_page_ids = {}
      form.pages.each_index do |idx|
        page = form.pages[idx]
        dot_file_lines << "page_#{page.id}[label=\"#{question_text_with_optional_suffix(page)}\"]"

        if idx.zero?
          dot_file_lines << "start -> page_#{page.id}"
        end


        if idx < form.pages.count - 1
          next_page = form.pages[idx + 1]
          next_page_ids[page.id] = next_page.id
        end
      end

      # rubocop:disable Style/CombinableLoops
      # subsequent loops are important because all the nodes need defining upfront
      form.pages.each do |page|
        # This is not part of a route
        # and goes straight to the next question
        if page.routing_conditions.empty?
          next_page_id = next_page_ids[page.id]

          # This is the end of the form
          # rubocop:disable Style/ConditionalAssignment
          if next_page_id.nil?
            dot_file_lines << "page_#{page.id} -> end"
          else
            dot_file_lines << "page_#{page.id} -> page_#{next_page_ids[page.id]}"
          end
          # rubocop:enable Style/ConditionalAssignment
        else
          page.routing_conditions.each do |condition|
            # Go straight to the end
            if condition.goto_page_id.nil? && !condition.exit_page_markdown.nil? # This is an exit page
              dot_file_lines << "exit_page_from_page_#{page.id}[label=\"#{condition.exit_page_markdown}\"]"
              dot_file_lines << "page_#{page.id} -> exit_page_from_page_#{page.id}[xlabel=\"If the answer is '#{condition.answer_value}\'\"]"

              next_page_id = next_page_ids[page.id]
              dot_file_lines << "page_#{page.id} -> page_#{next_page_id}[xlabel=\"Any other answer\"]"
            elsif condition.answer_value.nil? # This is the end of the branch
              dot_file_lines << "page_#{condition.routing_page_id} -> page_#{condition.goto_page_id}"
            else
              # This is the start of the branch
              branch_label = "If the answer is '#{condition.answer_value}\'"

              branch_target_node_id = condition.skip_to_end ? "end" : "page_#{condition.goto_page_id}"

              dot_file_lines << "page_#{condition.routing_page_id} -> #{branch_target_node_id}[xlabel=\"#{branch_label}\"]"
              dot_file_lines << "page_#{condition.routing_page_id} -> page_#{next_page_ids[page.id]}[xlabel=\"Any other answer\"]"

              dot_file_lines << "{rank=same; #{branch_target_node_id}; page_#{next_page_ids[page.id]}}"
            end
          end
        end
      end
      # rubocop:enable Style/CombinableLoops

      dot_file_lines << "}"
      dot_file = dot_file_lines.join("\n")
      stdout, status = Open3.capture2("dot -Tdot", stdin_data: dot_file)
      stdout
    end
  end
end
