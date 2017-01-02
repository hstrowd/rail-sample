module DateTimeHelper
  def normalize_date_time(val)
    if val.kind_of?(DateTime)
      date_time = val
    else
      date_time = DateTime.parse(val.to_s)
    end
    date_time.utc.to_i
  end
end
