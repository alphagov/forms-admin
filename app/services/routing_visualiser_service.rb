# frozen_string_literal: true

require_relative "../helpers/application_helper"
require "open3"

class QuestionGraph
  attr_accessor :root

  def initialize(root)
    @root = root
  end
end

class Node
  include ApplicationHelper

  attr_accessor :id, :text, :children, :page

  def initialize(page)
    @children = []
    @id = page.id
    @text = question_text_with_optional_suffix(page)
    @page = page
  end
end

class Edge
  attr_accessor :reason, :node

  def initialize(node, reason)
    @node = node
    @reason = reason
  end
end

class RoutingVisualiserService
  class << self
    def generate(form)
      graph = build_graph(form)

      [
        ["mermaid", render_as_mermaid(graph)],
        ["ascii", render_as_ascii(graph)],
      ].to_h
    end

  private

    def render_as_ascii(graph)
      # traverse_infix(graph.root, "", true, [])
      io = StringIO.new
      infix(graph.root, "", io)
      io.rewind
      io.read
    end

    def traverse_infix(node, prefix, is_last, result)
      return result if node.nil?

      # Print the current node
      result << "#{prefix}#{is_last ? '└── ' : '├── '}#{node.text}"

      prefix += is_last ? "    " : "│   "

      # Traverse children
      node.children.each_with_index do |child, index|
        result.push(traverse_infix(child.node, prefix, index == node.children.size - 1, result))
      end
    end

    def infix(node, prefix, result)
      space = "&nbsp"

      text = is_exit_page_node(node) ? "Exit page" : node.text

      result << "#{prefix}#{text}\n"

      prefix = prefix.empty? ? "|#{space * 4}" : "#{prefix}|#{space * 4}"

      node.children.each do |child|
        descendant_prefix = prefix
        unless child.reason.nil?
          result << "#{prefix}└ #{child.reason}\n"

          descendant_prefix = "#{descendant_prefix}#{space * 5}"
        end

        infix(child.node, descendant_prefix, result)
      end
    end

    def render_as_mermaid(graph)
      to_visit = [graph.root]

      diagram_lines = [
        "flowchart TD",
      ]
      visited_node_ids = []

      while to_visit.any?
        node = to_visit.shift

        next if visited_node_ids.include?(node.id)

        visited_node_ids << node.id

        diagram_lines << "page_#{node.id}[\"#{node.text}\"]"

        node.children.each do |edge|
          to_visit << edge.node

          # rubocop:disable Style/ConditionalAssignment cleaner with a simple if
          if edge.reason.nil?
            diagram_lines << "page_#{node.id} --> page_#{edge.node.id}"
          else
            diagram_lines << "page_#{node.id} -- #{edge.reason} --> page_#{edge.node.id}"
          end
          # rubocop:enable Style/ConditionalAssignment
        end
      end

      diagram_lines.join("\n")
    end

    def build_graph(form)
      # Page ids and indices in the array are different
      # but the convention is that barring any routing rules
      # the next page in the array is the next question
      #
      # Build up a map of id -> id to make it easy to look
      # up what the next question id WOULD be.
      next_page_ids = []
      form.pages.each_index do |idx|
        page = form.pages[idx]
        if idx < form.pages.count - 1
          next_page = form.pages[idx + 1]
          next_page_ids[page.id] = next_page.id
        end
      end

      nodes = form.pages.to_h do |page|
        [page.id, Node.new(page)]
      end

      check_your_answers_page = OpenStruct.new(
        id: 9999,
        show_optional_suffix: false,
        question_text: "Check your answers",
        routing_conditions: [],
      )

      check_your_answers_node = Node.new(check_your_answers_page)

      root_node = nil

      ## Go through all nodes and attach their children
      nodes.each_pair do |id, node|
        if root_node.nil?
          root_node = node
        end

        if !has_routing(node.page)
          next_q = nodes[next_page_ids[node.id]]
          if next_q
            node.children << Edge.new(next_q, nil)
          end
        else
          node.page.routing_conditions.each do |condition|
            if is_exit_page(condition)
              exit_page_node = exit_page_node(id, condition.exit_page_markdown)
              node.children << Edge.new(exit_page_node, branch_label(condition))

              next_q = nodes[next_page_ids[node.id]]
              if next_q
                node.children << Edge.new(next_q, default_label)
              end
            elsif is_end_of_branch(condition)
              end_of_branch_node = nodes[condition.goto_page_id]
              node.children << Edge.new(end_of_branch_node, nil)
            else
              # Start of a branch
              branch_question = condition.skip_to_end ? check_your_answers_node : nodes[condition.goto_page_id]
              node.children << Edge.new(branch_question, branch_label(condition))

              next_q = nodes[next_page_ids[node.id]]
              if next_q
                node.children << Edge.new(next_q, default_label)
              end
            end
          end
        end
      end

      # Go through all nodes and attach any non-exit-page leaf nodes to the check your answers node
      nodes.each_value do |node|
        next if is_exit_page_node(node)
        next unless node.children.empty?

        node.children << Edge.new(check_your_answers_node, nil)
      end

      QuestionGraph.new(root_node)
    end

    def has_routing(page)
      !page.routing_conditions.empty?
    end

    def is_exit_page(condition)
      condition.goto_page_id.nil? && !condition.exit_page_markdown.nil?
    end

    def is_end_of_branch(condition)
      condition.answer_value.nil?
    end

    def is_exit_page_node(node)
      if node.id.is_a? String
        return node.id.start_with? "exit_page_id"
      end

      false
    end

    def branch_label(condition)
      "If the answer is '#{condition.answer_value}'"
    end

    def default_label
      "Any other answer"
    end

    def exit_page_node(page_id, exit_page_markdown)
      page = OpenStruct.new(
        id: "exit_page_id_#{page_id}",
        question_text: exit_page_markdown,
        show_optional_suffix: false,
        routing_conditions: [],
      )
      Node.new(page)
    end
  end
end
