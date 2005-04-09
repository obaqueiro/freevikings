# :nodoc:
#
# Author:: Nathaniel Talbott.
# Copyright:: Copyright (c) 2000-2002 Nathaniel Talbott. All rights reserved.
# License:: Ruby license.

require 'gtk'
require 'test/unit/ui/testrunnermediator'
require 'test/unit/ui/testrunnerutilities'

module Test
  module Unit
    module UI
      module GTK # :nodoc:

        # Runs a Test::Unit::TestSuite in a Gtk UI. Obviously,
        # this one requires you to have Gtk
        # (http://www.gtk.org/) and the Ruby Gtk extension
        # (http://ruby-gnome.sourceforge.net/) installed.
        class TestRunner
          extend TestRunnerUtilities

          # Creates a new TestRunner and runs the suite.
          def self.run(suite)
            new(suite).start
            
          end

          # Creates a new TestRunner for running the passed
          # suite.
          def initialize(suite)
            if (suite.respond_to?(:suite))
              @suite = suite.suite
            else
              @suite = suite
            end
          end

          # Begins the test run.
          def start
            setup_mediator
            setup_ui
            attach_to_mediator
            start_ui
          end

          private
          def setup_mediator # :nodoc:
            @mediator = TestRunnerMediator.new(@suite)
            suite_name = @suite.to_s
            if ( @suite.kind_of?(Module) )
              suite_name = @suite.name
            end
            suite_name_entry.set_text(suite_name)
          end
          
          def attach_to_mediator # :nodoc:
            run_button.signal_connect("clicked", nil) { @mediator.run_suite }
            @mediator.add_listener(TestRunnerMediator::RESET, &method(:reset_ui))
            @mediator.add_listener(TestResult::FAULT, &method(:add_fault))
            @mediator.add_listener(TestResult::CHANGED, &method(:result_changed))
            @mediator.add_listener(TestRunnerMediator::STARTED, &method(:started))
            @mediator.add_listener(TestCase::STARTED, &method(:test_started))
            @mediator.add_listener(TestRunnerMediator::FINISHED, &method(:finished))
          end
          
          def start_ui # :nodoc:
            timer = Gtk::timeout_add(0) {
              Gtk::timeout_remove(timer)
              @mediator.run_suite
            }
            Gtk.main
          end
          
          def stop # :nodoc:
            Gtk.main_quit
          end
          
          def reset_ui(count) # :nodoc:
            test_progress_bar.set_style(green_style)
            test_progress_bar.configure(0, 0, count)
            @red = false
  
            run_count_label.set_text("0")
            assertion_count_label.set_text("0")
            failure_count_label.set_text("0")
            error_count_label.set_text("0")
  
            fault_list.remove_items(fault_list.children)
          end
          
          def add_fault(fault) # :nodoc:
            if ( ! @red )
              test_progress_bar.set_style(red_style)
              @red = true
            end
            item = FaultListItem.new(fault)
            item.show
            fault_list.append_items([item])
          end
          
          def show_fault(fault) # :nodoc:
            raw_show_fault(fault.longDisplay)
          end
          
          def raw_show_fault(string) # :nodoc:
            faultDetailLabel.set_text(string)
            outerDetailSubPanel.queue_resize
          end
          
          def clear_fault # :nodoc:
            raw_show_fault("")
          end
          
          def result_changed(result) # :nodoc:
            test_progress_bar.set_value(test_progress_bar.get_value + 1)
  
            run_count_label.set_text(result.run_count.to_s)
            assertion_count_label.set_text(result.assertion_count.to_s)
            failure_count_label.set_text(result.failure_count.to_s)
            error_count_label.set_text(result.error_count.to_s)
          end
          
          def started(result) # :nodoc:
            output_status("Started...")
          end
          
          def test_started(test_name)
            output_status("Running #{test_name}...")
          end
          
          def finished(elapsed_time)
            output_status("Finished in #{elapsed_time} seconds")
          end
          
          def output_status(string) # :nodoc:
            status_entry.set_text(string)
          end
  
          def setup_ui # :nodoc:
            main_window.signal_connect("destroy", nil) { stop }
            main_window.show_all
            fault_list.signal_connect("select-child", nil) {
              | list, item, data |
              show_fault(item.fault)
            }
            fault_list.signal_connect("unselect-child", nil) {
              clear_fault
            }
            @red = false
          end
          
          def main_window # :nodoc:
            lazy_initialize(:main_window) {
              @main_window = Gtk::Window.new(Gtk::WINDOW_TOPLEVEL)
              @main_window.set_title("Test::Unit TestRunner")
              @main_window.set_usize(800, 600)
              @main_window.set_uposition(20, 20)
              @main_window.set_policy(true, true, false)
              @main_window.add(main_panel)
            }
          end
          
          def main_panel # :nodoc:
            lazy_initialize(:main_panel) {
              @main_panel = Gtk::VBox.new(false, 0)
              @main_panel.pack_start(suite_panel, false, false, 0)
              @main_panel.pack_start(progress_panel, false, false, 0)
              @main_panel.pack_start(info_panel, false, false, 0)
              @main_panel.pack_start(list_panel, false, false, 0)
              @main_panel.pack_start(detail_panel, true, true, 0)
              @main_panel.pack_start(status_panel, false, false, 0)
            }
          end
          
          def suite_panel # :nodoc:
            lazy_initialize(:suite_panel) {
              @suite_panel = Gtk::HBox.new(false, 10)
              @suite_panel.border_width(10)
              @suite_panel.pack_start(Gtk::Label.new("Suite:"), false, false, 0)
              @suite_panel.pack_start(suite_name_entry, true, true, 0)
              @suite_panel.pack_start(run_button, false, false, 0)
            }
          end
          
          def suite_name_entry # :nodoc:
            lazy_initialize(:suite_name_entry) {
              @suite_name_entry = Gtk::Entry.new
              @suite_name_entry.set_editable(false)
            }
          end
          
          def run_button # :nodoc:
            lazy_initialize(:run_button) {
              @run_button = Gtk::Button.new("Run")
            }
          end
          
          def progress_panel # :nodoc:
            lazy_initialize(:progress_panel) {
              @progress_panel = Gtk::HBox.new(false, 10)
              @progress_panel.border_width(10)
              @progress_panel.pack_start(test_progress_bar, true, true, 0)
            }
          end
          
          def test_progress_bar # :nodoc:
            lazy_initialize(:test_progress_bar) {
              @test_progress_bar = EnhancedProgressBar.new
              @test_progress_bar.set_usize(@test_progress_bar.allocation.width, 50)
              @test_progress_bar.set_style(green_style)
            }
          end
          
          def green_style # :nodoc:
            lazy_initialize(:green_style) {
              @green_style = Gtk::Style.new
              @green_style.set_bg(Gtk::STATE_PRELIGHT, 0x0000, 0xFFFF, 0x0000)
            }
          end
          
          def red_style # :nodoc:
            lazy_initialize(:red_style) {
              @red_style = Gtk::Style.new
              @red_style.set_bg(Gtk::STATE_PRELIGHT, 0xFFFF, 0x0000, 0x0000)
            }
          end
          
          def info_panel # :nodoc:
            lazy_initialize(:info_panel) {
              @info_panel = Gtk::HBox.new(false, 0)
              @info_panel.border_width(10)
              @info_panel.pack_start(Gtk::Label.new("Runs:"), false, false, 0)
              @info_panel.pack_start(run_count_label, true, false, 0)
              @info_panel.pack_start(Gtk::Label.new("Assertions:"), false, false, 0)
              @info_panel.pack_start(assertion_count_label, true, false, 0)
              @info_panel.pack_start(Gtk::Label.new("Failures:"), false, false, 0)
              @info_panel.pack_start(failure_count_label, true, false, 0)
              @info_panel.pack_start(Gtk::Label.new("Errors:"), false, false, 0)
              @info_panel.pack_start(error_count_label, true, false, 0)
            }
          end
          
          def run_count_label # :nodoc:
            lazy_initialize(:run_count_label) {
              @run_count_label = Gtk::Label.new("0")
              @run_count_label.set_justify(Gtk::JUSTIFY_LEFT)
            }
          end
          
          def assertion_count_label # :nodoc:
            lazy_initialize(:assertion_count_label) {
              @assertion_count_label = Gtk::Label.new("0")
              @assertion_count_label.set_justify(Gtk::JUSTIFY_LEFT)
            }
          end
          
          def failure_count_label # :nodoc:
            lazy_initialize(:failure_count_label) {
              @failure_count_label = Gtk::Label.new("0")
              @failure_count_label.set_justify(Gtk::JUSTIFY_LEFT)
            }
          end
          
          def error_count_label # :nodoc:
            lazy_initialize(:error_count_label) {
              @error_count_label = Gtk::Label.new("0")
              @error_count_label.set_justify(Gtk::JUSTIFY_LEFT)
            }
          end
          
          def list_panel # :nodoc:
            lazy_initialize(:list_panel) {
              @list_panel = Gtk::HBox.new
              @list_panel.border_width(10)
              @list_panel.pack_start(list_scrolled_window, true, true, 0)
            }
          end
          
          def list_scrolled_window # :nodoc:
            lazy_initialize(:list_scrolled_window) {
              @list_scrolled_window = Gtk::ScrolledWindow.new
              @list_scrolled_window.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
              @list_scrolled_window.set_usize(@list_scrolled_window.allocation.width, 150)
              @list_scrolled_window.add_with_viewport(fault_list)
            }
          end
          
          def fault_list # :nodoc:
            lazy_initialize(:fault_list) {
              @fault_list = Gtk::List.new
            }
          end
          
          def detail_panel # :nodoc:
            lazy_initialize(:detail_panel) {
              @detail_panel = Gtk::HBox.new
              @detail_panel.border_width(10)
              @detail_panel.pack_start(detail_scrolled_window, true, true, 0)
            }
          end
          
          def detail_scrolled_window # :nodoc:
            lazy_initialize(:detail_scrolled_window) {
              @detail_scrolled_window = Gtk::ScrolledWindow.new
              @detail_scrolled_window.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
              @detail_scrolled_window.set_usize(400, @detail_scrolled_window.allocation.height)
              @detail_scrolled_window.add_with_viewport(outer_detail_sub_panel)
            }
          end
          
          def outer_detail_sub_panel # :nodoc:
            lazy_initialize(:outer_detail_sub_panel) {
              @outer_detail_sub_panel = Gtk::VBox.new
              @outer_detail_sub_panel.pack_start(inner_detail_sub_panel, false, false, 0)
            }
          end
          
          def inner_detail_sub_panel # :nodoc:
            lazy_initialize(:inner_detail_sub_panel) {
              @inner_detail_sub_panel = Gtk::HBox.new
              @inner_detail_sub_panel.pack_start(fault_detail_label, false, false, 0)
            }
          end
          
          def fault_detail_label # :nodoc:
            lazy_initialize(:fault_detail_label) {
              @fault_detail_label = EnhancedLabel.new("")
              style = Gtk::Style.new
              #font = Gdk::Font.font_load("-*-Courier New-medium-r-normal--*-120-*-*-*-*-*-*")
              #style.set_font(font)
              @fault_detail_label.set_style(style)
              @fault_detail_label.set_justify(Gtk::JUSTIFY_LEFT)
              @fault_detail_label.set_line_wrap(false)
            }
          end
          
          def status_panel # :nodoc:
            lazy_initialize(:status_panel) {
              @status_panel = Gtk::HBox.new
              @status_panel.border_width(10)
              @status_panel.pack_start(status_entry, true, true, 0)
            }
          end
          
          def status_entry # :nodoc:
            lazy_initialize(:status_entry) {
              @status_entry = Gtk::Entry.new
              @status_entry.set_editable(false)
            }
          end
  
          def lazy_initialize(symbol) # :nodoc:
            if (!instance_eval("defined?(@#{symbol.to_s})"))
              yield
            end
            return instance_eval("@" + symbol.to_s)
          end
        end
  
        class EnhancedProgressBar < Gtk::ProgressBar # :nodoc: all
          def set_style(style)
            super
            hide
            show
          end
        end
  
        class EnhancedLabel < Gtk::Label # :nodoc: all
          def set_text(text)
            super(text.gsub(/\n\t/, "\n" + (" " * 4)))
          end
        end
  
        class FaultListItem < Gtk::ListItem # :nodoc: all
          attr_reader(:fault)
          def initialize(fault)
            super(fault.short_display)
            @fault = fault
          end
        end
      end
    end
  end
end

if __FILE__ == $0
  Test::Unit::UI::GTK::TestRunner.start_command_line_test
end