module SentMessagesHelper
  def confirmed_time_column(record)
    to_local_time(record.confirmed_time)
  end
end
