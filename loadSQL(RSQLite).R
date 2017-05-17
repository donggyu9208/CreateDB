library(RSQLite)
library(ggplot2)

#myDB <- "C:\\Users\\DongGyu\\Desktop\\Programming\\Python\\Research\\DataFile\\TEST(OneEventID).db"
#myDB <- "C:\\Users\\DongGyu\\Desktop\\Programming\\Python\\Research\\DataFile\\TEST(TwoEventID).db"
#myDB <- "C:\\Users\\DongGyu\\Desktop\\Programming\\Python\\Research\\DataFile\\TEST(MoreEventID).db"
myDB <- "C:\\Users\\DongGyu\\Desktop\\Programming\\Python\\Research\\DataFile\\OUTPUT_shift_D1 V3.db"

conn <- dbConnect(drv = SQLite(), dbname= myDB)

alltables = dbListTables(conn)

tableAll = dbGetQuery(conn, "
           SELECT 
           Event_Properties.event_number, 
           Driver.driver_number,
           Age.age_group,
           Gender.gender_type,
           Turn.turn_direction, 
           Traffic_Control_Device.sign, 
           Speed.speed_limit_before,
           Speed.speed_limit_after,
           Move.moving_type,
           Event.distance,
           Event.velocity
           
           FROM 
           Event_Properties JOIN 
           Driver JOIN 
           Age JOIN 
           Gender JOIN 
           Turn JOIN 
           Traffic_Control_Device JOIN 
           Speed JOIN 
           Move JOIN 
           Event 
           
           ON 
           Event.event_id = Event_Properties.id AND
           Event_Properties.driver_id = Driver.id AND
           Driver.age_id = Age.id AND
           Driver.gender_id = Gender.id AND
           Event_Properties.speed_id = Speed.id AND
           Event_Properties.move_id = Move.id AND
           Event_Properties.turn_id = Turn.id AND
           Event_Properties.tcd_id = Traffic_Control_Device.id;")

tableDV = dbGetQuery(conn, "
          SELECT
          Event.distance, Event.velocity

          FROM
          Event")

# This is for travelling through
tableThrough = dbGetQuery(conn, "
                       SELECT 
					              Event.distance, Event.velocity
                       FROM 
                        Event_Properties JOIN Event
                       ON 
                        Event.event_id = Event_Properties.id
                       WHERE
                        move_id
                       LIKE
                        '%1%'
                       ")

tableRolling = dbGetQuery(conn, "
                       SELECT 
					              Event.distance, Event.velocity
                       FROM 
                        Event_Properties JOIN Event
                       ON 
                        Event.event_id = Event_Properties.id
                       WHERE
                        move_id
                       LIKE
                        '%2%'
                       ")

tableCompleteStop = dbGetQuery(conn, "
                       SELECT 
					              Event.distance, Event.velocity
                       FROM 
                        Event_Properties JOIN Event
                       ON 
                        Event.event_id = Event_Properties.id
                       WHERE
                        move_id
                       LIKE
                        '%3%'
                       ")

## aes(x, y), x and y must be one of columns in the data.frame
#ggplot(tableCompleteStop, aes(distance, velocity)) + geom_point() + geom_boxplot(tableCompleteStop, aes(distance, velocity))
#ggplot(tableCompleteStop) + geom_point(aes(distance, velocity))

#qplot(x = tableCompleteStop[1], y = tableCompleteStop[2], data = tableCompleteStop)
#qplot(data = tableCompleteStop, x = tableCompleteStop[1],y = tableCompleteStop[2], geom = "boxplot")


# plot(tableDV, type = "p")
# plot(tableThrough, type = "p")
# plot(tableRolling, type = "p")
# plot(tableCompleteStop, type = "p")


## Complete Stop

pComplete <- ggplot(data = tableCompleteStop, ## Specifies which data set we are making a plot with  
       mapping = aes(x=distance, y=velocity)) + ## Specifies that x variable is distance and y variable is velocity from tableCompleteStop data.frame
geom_boxplot(mapping = aes(x = distance,
                           lower = 0.25, ## lower hinge, 25% quantile
                           middle = 0.50, ## median, 50% quantile
                           upper = 0.75, ## upper hinge, 75% quantile
                           group = cut_width(distance, 5)), 
             ## aes(...) has many parameters you can apply (look up in the manual or in notes)
             ## group = cut_width specifies that distance is divided by 5 distance length
             data = tableCompleteStop, ## from which data.frame you are retrieving from
             position = "dodge", ## position
             color = "black", ## color of the box plot only (You can add more arguments such as size = 3)
             size = 0.01, ## size changes the thickness of the boxplot line and a point line
             outlier.color = "black",  ## changes only the color of outliers(the ones that are in points shape) (There are more options you can change for the aesthetics of outliers)
             outlier.size = 0.001,
             notch = FALSE, ## Creates Notches for a box plot if notch = TRUE, (Since I am not sure what exactly notch is just leave it) (Notch = displays the confidence interval around the median)
             varwidth = TRUE, ## if FALSE just default if TRUE boxes are drawn with widths proportional to the square roots of the number of observations in the groups 
             na.rm = TRUE, # if FALSE missing values are removed with a warning, if TRUE missing values are silently removed (Since we do not have missing values for our data set, we do not need to worry about such cases)
             show.legend = NA ## NA (default) includes if any aesthetics are mapped, FALSE never includes, TRUE always includes
             ) + labs(title = "Complete Stop", x = "distance (m)", y = "velocity (m/s)");
pgComplete <- ggplot_build(pComplete)$data;
dfComplete <- data.frame(pgComplete[[1]]["x"],
                 pgComplete[[1]]["ymin"],
                 pgComplete[[1]]["lower"],
                 pgComplete[[1]]["middle"],
                 pgComplete[[1]]["upper"],
                 pgComplete[[1]]["ymax"],
                 pgComplete[[1]]["ymin_final"],
                 pgComplete[[1]]["ymax_final"])
## Rolling
pRolling <- ggplot(data = tableRolling, ## Specifies which data set we are making a plot with  
       mapping = aes(x=distance, y=velocity)) + ## Specifies that x variable is distance and y variable is velocity from tableCompleteStop data.frame
  geom_boxplot(mapping = aes(x = distance,
                             lower = 0.25, ## lower hinge, 25% quantile
                             middle = 0.50, ## median, 50% quantile
                             upper = 0.75, ## upper hinge, 75% quantile
                             group = cut_width(distance, 5)), 
               ## aes(...) has many parameters you can apply (look up in the manual or in notes)
               ## group = cut_width specifies that distance is divided by 5 distance length
               data = tableRolling, ## from which data.frame you are retrieving from
               position = "dodge", ## position
               color = "black", ## color of the box plot only (You can add more arguments such as size = 3)
               size = 0.01, ## size changes the thickness of the boxplot line and a point line
               outlier.color = "black",  ## changes only the color of outliers(the ones that are in points shape) (There are more options you can change for the aesthetics of outliers)
               outlier.size = 0.001,
               notch = FALSE, ## Creates Notches for a box plot if notch = TRUE, (Since I am not sure what exactly notch is just leave it) (Notch = displays the confidence interval around the median)
               varwidth = TRUE, ## if FALSE just default if TRUE boxes are drawn with widths proportional to the square roots of the number of observations in the groups 
               na.rm = TRUE, # if FALSE missing values are removed with a warning, if TRUE missing values are silently removed (Since we do not have missing values for our data set, we do not need to worry about such cases)
               show.legend = NA ## NA (default) includes if any aesthetics are mapped, FALSE never includes, TRUE always includes
  ) + labs(title = "Rolling", x = "distance (m)", y = "velocity (m/s)");
pgRolling <- ggplot_build(pRolling)$data;
dfRolling <- data.frame(pgRolling[[1]]["x"],
                        pgRolling[[1]]["ymin"],
                        pgRolling[[1]]["lower"],
                        pgRolling[[1]]["middle"],
                        pgRolling[[1]]["upper"],
                        pgRolling[[1]]["ymax"],
                        pgRolling[[1]]["ymin_final"],
                        pgRolling[[1]]["ymax_final"])
## Travel Through
pThrough <- ggplot(data = tableThrough, ## Specifies which data set we are making a plot with  
       mapping = aes(x=distance, y=velocity)) + ## Specifies that x variable is distance and y variable is velocity from tableCompleteStop data.frame
  geom_boxplot(mapping = aes(x = distance,
                             lower = 0.25, ## lower hinge, 25% quantile
                             middle = 0.50, ## median, 50% quantile
                             upper = 0.75, ## upper hinge, 75% quantile
                             group = cut_width(distance, 5)), 
               ## aes(...) has many parameters you can apply (look up in the manual or in notes)
               ## group = cut_width specifies that distance is divided by 5 distance length
               data = tableThrough, ## from which data.frame you are retrieving from
               position = "dodge", ## position
               color = "black", ## color of the box plot only (You can add more arguments such as size = 3)
               size = 0.01, ## size changes the thickness of the boxplot line and a point line
               outlier.color = "black",  ## changes only the color of outliers(the ones that are in points shape) (There are more options you can change for the aesthetics of outliers)
               outlier.size = 0.001,
               notch = FALSE, ## Creates Notches for a box plot if notch = TRUE, (Since I am not sure what exactly notch is just leave it) (Notch = displays the confidence interval around the median)
               varwidth = TRUE, ## if FALSE just default if TRUE boxes are drawn with widths proportional to the square roots of the number of observations in the groups 
               na.rm = TRUE, # if FALSE missing values are removed with a warning, if TRUE missing values are silently removed (Since we do not have missing values for our data set, we do not need to worry about such cases)
               show.legend = NA ## NA (default) includes if any aesthetics are mapped, FALSE never includes, TRUE always includes
  ) + labs(title = "Travel Through", x = "distance (m)", y = "velocity (m/s)");
pgThrough <- ggplot_build(pThrough)$data;
dfThrough <- data.frame(pgThrough[[1]]["x"],
                        pgThrough[[1]]["ymin"],
                        pgThrough[[1]]["lower"],
                        pgThrough[[1]]["middle"],
                        pgThrough[[1]]["upper"],
                        pgThrough[[1]]["ymax"],
                        pgThrough[[1]]["ymin_final"],
                        pgThrough[[1]]["ymax_final"])
dbDisconnect(conn)