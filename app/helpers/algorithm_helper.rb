module AlgorithmHelper

  ALGO_COLORS = {
    :success => 'success',
    :ok => 'ok',
    :fail => 'fail'
  }

  def situation_analysis_algo(indicator_data, reported_value)
    num_green = 0
    num_amber = 0

    indicator_data.each do |datum|
      next unless datum[reported_value]

      if datum[reported_value] >= datum.threshold_green
        num_green += 1
      elsif datum[reported_value] >= datum.threshold_red
        num_amber += 1
      end
    end

    count = indicator_data.count.to_f
    result = (num_green / count) + (0.5 * (num_amber / count))

    if result >= 0.66
      return ALGO_COLORS[:success]
    elsif result >= 0.33
      return ALGO_COLORS[:ok]
    else
      return ALGO_COLORS[:fail]
    end
  end

end
