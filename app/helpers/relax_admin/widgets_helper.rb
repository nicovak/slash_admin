# frozen_string_literal: true
module RelaxAdmin::WidgetsHelper
  # number, title, icon, progress_label, percent, status
  def statistic_progress_tile(options = {})
    render 'relax_admin/dashboard/widgets/statistic_progress_tile', options: options
  end
end
