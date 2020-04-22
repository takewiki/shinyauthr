library(digest)

user_base <- data.frame(
  user = c("user1", "user2"),
  password = sapply(c("pass1", "pass2"), digest, "md5"), 
  permissions = c("admin", "standard"),
  name = c("User One", "User Two"),
  stringsAsFactors = FALSE
)


View(user_base)