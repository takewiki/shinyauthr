library(tsda)

conn <- conn_rds('nsic')
user_base <- data_frame(
  Fuser = c("admin", "demo"),
  Fpassword = sapply(c("admin", "demo"), digest, "md5"), 
  Fpermissions = c("admin", "standard"),
  Fname = c("管理员", "普通用户")
)
upload_data(conn = conn,table_name ='t_md_userRight',data = user_base )