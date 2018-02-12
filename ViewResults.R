options(repos = "https://mran.microsoft.com")
options(stringsAsFactors = FALSE)
Sys.setenv(TZ="Australia/Queensland")

if (!require('RODBC')) install.packages('RODBC')
if (!require('RJSONIO')) install.packages('RJSONIO')

library('RODBC')
library('RJSONIO')

creds <- fromJSON("credentials.json")

con.text <- paste("DRIVER=","SQL Server",
                  ";Database=","analytics",
                  ";Server=","adambarnes.database.windows.net",
                  ";Port=","1433",
                  ";PROTOCOL=TCPIP",
                  ";UID=", creds$database[1],
                  ";PWD=",creds$database[2],sep="")

con1 <- odbcDriverConnect(con.text)

exData <- sqlQuery(con1, 'select * from dbo.HourlyWeatherData')

write.csv(exData,"tempData.csv",row.names = FALSE)

odbcCloseAll()

