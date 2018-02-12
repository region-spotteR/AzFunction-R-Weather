## Hourly scheduled function to retrieve observations from OpenWeatherData
Makes a call to the OpenWeatherData API to retrieve current observations for given list of station codes, then persists into Azure SQL database table.

Components are:
- **GetWeatherData.R** - R (3.3.2) script. Requires httr, RJSONIO and RODBC.
- **credentials.json** - contains API key for weather and Azure db creds.
- **run.ps1** - powershell to execute R script.
- **function.json** - cron schedule for job execution.

## Output (R dataframe)
- StationID     : int  8164 8164
- StationName   : chr  "East Brisbane" "South Brisbane"
- MsgId         : int  2207258 2207259
- RecordDateTime: POSIXct, format: "2017-07-31 22:50:09" "2017-07-31 22:50:09"
- Temperature   : num  14.4 14.4
- Pressure      : int  1023 1023
- Humidity      : int  45 45
- WindSpeed     : num  4.6 4.6
- WindDirection : int  210 210
- Weather       : chr  "Clear" "Clear"
 
