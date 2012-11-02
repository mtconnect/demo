CURRENT_YEAR = Proc.new { Time.now.strftime("%Y").to_i }
CURRENT_MONTH = Proc.new { Time.now.strftime("%m").to_i }
CURRENT_DATE = Proc.new { Time.now.strftime("%d").to_i }
CURRENT_HOUR = Proc.new { Time.now.strftime("%H").to_i }
