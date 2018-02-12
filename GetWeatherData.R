options(repos = "https://mran.microsoft.com")
options(stringsAsFactors = FALSE)
Sys.setenv(TZ="Australia/Queensland")

if (!require('httr')) install.packages('httr')
#if (!require('dplyr')) install.packages('dplyr')
#if (!require('lubridate')) install.packages('lubridate')
if (!require('RODBC')) install.packages('RODBC')
if (!require('RJSONIO')) install.packages('RJSONIO')

library('httr')
#library('lubridate')
#library('dplyr')
library('RODBC')
library('RJSONIO')

parseWeather <- function(weatherList) {
  return(data.frame(StationID = weatherList$sys$id,
                    StationName = weatherList$name,
                    MsgId = weatherList$id,
                    RecordDateTime = weatherList$dt,
                    Temperature = weatherList$main$temp,
                    Pressure = weatherList$main$pressure,
                    Humidity = weatherList$main$humidity,
                    WindSpeed = weatherList$wind$speed,
                    WindDirection = weatherList$wind$deg,
                    Weather = weatherList$weather[[1]]$main))
}

creds <- fromJSON("credentials.json")
locationGroups <- "7839580,2152192,7839389,2162005,2165095,2168306,2168806,5903423,2167426,2157565,2151201,2172418"

wData <- content(GET(paste("http://api.openweathermap.org/data/2.5/group?id=",locationGroups,"&APPID=",creds$openweathermap[1],"&units=metric",sep = "")))$list

for (i in 1:length(wData)) {
  if (i == 1) {
    outDf <-parseWeather(wData[[i]])
  } else {
    outDf <- dplyr::bind_rows(outDf,parseWeather(wData[[i]]))
  }
}

#cast is failing ont he way into SQL
#outDf$RecordDateTime <- as.POSIXct(as.numeric(outDf$RecordDateTime), origin = '1970-01-01', tz = 'GMT')

con.text <- paste("DRIVER=","SQL Server",
                  ";Database=","analytics",
                  ";Server=","adambarnes.database.windows.net",
                  ";Port=","1433",
                  ";PROTOCOL=TCPIP",
                  ";UID=", creds$database[1],
                  ";PWD=",creds$database[2],sep="")

con1 <- odbcDriverConnect(con.text)

columnTypes <- list(StationID = "integer",
                    StationName = "varchar(30)",
                    MsgId = "integer",
                    RecordDateTime = "integer",
                    Temperature = "decimal",
                    Pressure = "decimal",
                    Humidity = "integer",
                    WindSpeed = "decimal",
                    WindDirection = "decimal",
                    Weather = "varchar(30)")

sqlSave(con1,outDf,tablename = "dbo.HourlyWeatherData",append = TRUE, varTypes = columnTypes)

sqlQuery(con1, 'select top (10) * from dbo.HourlyWeatherData order by RecordDateTime desc')

odbcCloseAll()

