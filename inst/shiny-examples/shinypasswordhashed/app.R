library(shiny)
library(shinydashboard)
library(dplyr)
library(shinyjs)
library(glue)
library(shinyauthr)
library(digest)
library(tsda)

conn <- conn_rds('nsic')
sql <-"select * from t_md_userRight"
user_base <- sql_select(conn,sql)



user_test <- user_base
names(user_test) <- c('用户名','密码','角色','昵称')

ui <- dashboardPage(
  
  dashboardHeader(title = "用户权限设置",
                  tags$li(class = "dropdown", style = "padding: 8px;",
                          shinyauthr::logoutUI("logout",label = '注销')),
                  tags$li(class = "dropdown", 
                          tags$a(icon("github"), 
                                 href = "https://github.com/paulc91/shinyauthr",
                                 title = "See the code on github"))
  ),
  
  dashboardSidebar(collapsed = TRUE, 
                   div(textOutput("welcome"), style = "padding: 20px")
  ),
  
  dashboardBody(
    shinyjs::useShinyjs(),
    tags$head(tags$style(".table{margin: 0 auto;}"),
              tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js",
                          type="text/javascript"),
              includeScript("returnClick.js")
    ),
    shinyauthr::loginUI("login",title = '登录界面',user_title = '用户名',pass_title = '密码',login_title = '登录',error_message = '用户名或密码错误,请重试！'),
    uiOutput("user_table"),
    uiOutput("testUI"),
    HTML('<div data-iframe-height></div>')
  )
)

server <- function(input, output, session) {
  
  credentials <- callModule(shinyauthr::login, "login", 
                            data = user_base,
                            user_col = Fuser,
                            pwd_col = Fpassword,
                            hashed = TRUE,
                            algo = "md5",
                            log_out = reactive(logout_init()))
  
  logout_init <- callModule(shinyauthr::logout, "logout", reactive(credentials()$user_auth))
  
  observe({
    if(credentials()$user_auth) {
      shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    } else {
      shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    }
  })
  
  output$user_table <- renderUI({
    # only show pre-login
    if(credentials()$user_auth) return(NULL)
    
    tagList(
      tags$p("测试账号信息如下", class = "text-center"),
      
      renderTable({user_test})
    )
  })
  
  user_info <- reactive({credentials()$info})
  
  user_data <- reactive({
    req(credentials()$user_auth)
    
    if (user_info()$Fpermissions == "admin") {
      dplyr::starwars[,1:10]
    } else if (user_info()$Fpermissions == "standard") {
      dplyr::storms[,1:11]
    }
    
  })
  
  output$welcome <- renderText({
    req(credentials()$user_auth)
    
    glue("Welcome {user_info()$Fname}")
  })
  
  output$testUI <- renderUI({
    req(credentials()$user_auth)
    
    print(user_info())
    
    fluidRow(
      column(
        width = 12,
        tags$h2(glue("Your permission level is: {user_info()$permissions}. 
                     Your data is: {ifelse(user_info()$permissions == 'admin', 'Starwars', 'Storms')}.")),
        box(width = NULL, status = "primary",
            title = ifelse(user_info()$Fpermissions == 'admin', "Starwars Data", "Storms Data"),
            DT::renderDT(user_data(), options = list(scrollX = TRUE))
        )
      )
    )
  })
  
}

shiny::shinyApp(ui, server)
