install.packages("wordcloud")
install.packages("ggmap")
install.packages("tm")
install.packages("tidytext")
install.packages("mapsapi")
install.packages("mapview")
install.packages("sf")
install.packages("crossplot")
install.packages("mice")
install.packages("VIM")
install.packages("ggpubr")

# Load libraries

library(readxl)
library(ggplot2)
library(tidyverse)
library(stringr)
library(tidyr)
library(dplyr)
library(wordcloud)
library(ggmap)
library(tm)
library(tidytext)
library(mapsapi)
library(mapview)
library(sf)
library(leaflet)
library(corrplot)
library(car)
library(mice)
library(VIM)
library(caret)
library(ggpubr)
library(scales)

# Import data and assign to data frames

Montreal <- read.csv(file.choose())
New_Brunswick <- read.csv(file.choose())
Ottawa <- read.csv(file.choose())
Quebec_City <- read.csv(file.choose())
Toronto <- read.csv(file.choose())
Vancouver <- read.csv(file.choose())
Victoria <- read.csv(file.choose())

# Add city name to data frames

Montreal$City <- "Montreal"
New_Brunswick$City <- "New Brunswick"
Ottawa$City <- "Ottawa"
Quebec_City$City <- "Quebec City"
Toronto$City <- "Toronto"
Vancouver$City <- "Vancouver"
Victoria$City <- "Victoria"

# Combine data sets

All_Cities <- rbind(Montreal, New_Brunswick, Ottawa, 
                    Quebec_City, Toronto, Vancouver, Victoria)

All_Cities <- read.csv(file.choose())

reviews_Montreal <- read.csv(file.choose())
reviews_New_Brunswick <- read.csv(file.choose())
reviews_Ottawa <- read.csv(file.choose())
reviews_Quebec_City <- read.csv(file.choose())
reviews_Toronto <- read.csv(file.choose())
reviews_Vancouver <- read.csv(file.choose())
reviews_Victoria <- read.csv(file.choose())

all_reviews <- rbind(reviews_Montreal,
                     reviews_New_Brunswick, 
                     reviews_Ottawa,
                     reviews_Quebec_City,
                     reviews_Toronto,
                     reviews_Vancouver,
                     reviews_Victoria)

write.csv(all_reviews, "C:\\hS\\LearnR\\airbnbteamproject\\all_reviews.csv")


# Filter required variables.

Filtered_All_Cities <- All_Cities %>% 
  select(id, name, neighborhood_overview, host_id, host_name, host_since,
         host_response_time, host_response_rate, host_acceptance_rate,
         host_is_superhost, host_neighbourhood, host_listings_count, host_has_profile_pic,
         host_identity_verified, neighbourhood_cleansed, latitude, longitude, 
         property_type, room_type, accommodates, bathrooms_text, bedrooms, beds,
         price, minimum_nights, maximum_nights, minimum_nights_avg_ntm, maximum_nights_avg_ntm,
         has_availability, availability_30, number_of_reviews, number_of_reviews_ltm, number_of_reviews_l30d,
         first_review, last_review, review_scores_rating, instant_bookable, reviews_per_month, City)

str(Filtered_All_Cities)


############################################################################################################

# Section 1: CLEAN DATA

# Convert City to factor 

Filtered_All_Cities$City <- as.factor(Filtered_All_Cities$City)
Filtered_All_Cities$City

#Convert room type to factor

Filtered_All_Cities$room_type <- as.factor(Filtered_All_Cities$room_type)

# Convert strings to numeric

Filtered_All_Cities$host_response_rate <- 
  as.numeric(str_remove(Filtered_All_Cities$host_response_rate, "%")) 
Filtered_All_Cities$host_response_rate

Filtered_All_Cities$host_acceptance_rate <- 
  as.numeric(str_remove(Filtered_All_Cities$host_acceptance_rate, "%"))
Filtered_All_Cities$host_acceptance_rate

Filtered_All_Cities$price <- as.numeric(str_remove(Filtered_All_Cities$price, "\\$")) 
Filtered_All_Cities$price

Filtered_All_Cities$bathrooms <- 
  as.numeric(gsub(".*?([0-9]+).*", "\\1", Filtered_All_Cities$bathrooms_text))
Filtered_All_Cities$bathrooms

# Convert "t" and "f" observations as True or False

Filtered_All_Cities$host_is_superhost[Filtered_All_Cities$host_is_superhost == "t"] <- "True"
Filtered_All_Cities$host_is_superhost[Filtered_All_Cities$host_is_superhost == "f"] <- "False"
Filtered_All_Cities$host_is_superhost <- as.factor(Filtered_All_Cities$host_is_superhost)


Filtered_All_Cities$host_has_profile_pic[Filtered_All_Cities$host_has_profile_pic == "t"] <- "True"
Filtered_All_Cities$host_has_profile_pic[Filtered_All_Cities$host_has_profile_pic == "f"] <- "False"
Filtered_All_Cities$host_has_profile_pic <- as.factor(Filtered_All_Cities$host_has_profile_pic)


Filtered_All_Cities$host_identity_verified[Filtered_All_Cities$host_identity_verified == "t"] <- "True"
Filtered_All_Cities$host_identity_verified[Filtered_All_Cities$host_identity_verified == "f"] <- "False"
Filtered_All_Cities$host_identity_verified <- as.factor(Filtered_All_Cities$host_identity_verified) 


Filtered_All_Cities$has_availability[Filtered_All_Cities$has_availability == "t"] <- "True"
Filtered_All_Cities$has_availability[Filtered_All_Cities$has_availability == "f"] <- "False"
Filtered_All_Cities$has_availability <- as.factor(Filtered_All_Cities$has_availability)


Filtered_All_Cities$instant_bookable[Filtered_All_Cities$instant_bookable == "t"] <- "True"
Filtered_All_Cities$instant_bookable[Filtered_All_Cities$instant_bookable == "f"] <- "False"
Filtered_All_Cities$instant_bookable <- as.factor(Filtered_All_Cities$instant_bookable)

# Clean text <br>

#Filtered_All_Cities$description <- gsub("br", "", Filtered_All_Cities$description)
Filtered_All_Cities$name <- gsub("br", "", Filtered_All_Cities$name)

## host_about column not present in filtered df.
#Filtered_All_Cities$host_about <- gsub("br", "", Filtered_All_Cities$host_about)

Filtered_All_Cities$neighborhood_overview <- 
  gsub("br", "", Filtered_All_Cities$neighborhood_overview)

str(Filtered_All_Cities)

#################################################################################################################

# SECTION 2: MISSING DATA

#MISSING DATA:

md.pattern(Filtered_All_Cities, rotate.names = TRUE)

sum(is.na(Filtered_All_Cities$host_id))

head(Filtered_All_Cities)
summary(Filtered_All_Cities)
str(Filtered_All_Cities)
dim(Filtered_All_Cities)   

Missing <- data.frame(is.na(Filtered_All_Cities)) 

# Now taking out all the blanks (missing values) in numeric columns:
All_Cities_nonmissing <- na.omit(Filtered_All_Cities)
md.pattern(All_Cities_nonmissing,rotate.names = TRUE)

#Now changing N/A values to missing for character columns and then omitting them:

All_Cities_nonmissingNA <- All_Cities_nonmissing%>%
  replace_with_na(replace = list(host_response_rate="N/A")) 
Filtered_All_Cities1 <- na.omit(All_Cities_nonmissingNA) 

#################################################################################################################
# SECTION 3: EXPLORATORY DATA ANALYSIS (EDA)

str(all_reviews)
all_reviews <- na.omit(all_reviews)
all_reviews$date <- as.Date(all_reviews$date)


num_reviews <- all_reviews %>%
  group_by(date = all_reviews$date) %>%
  summarise(number = n())
num_reviews

ggplot(num_reviews, aes(x = date, y = number)) + 
  geom_point(na.rm = TRUE, alpha = 0.5, color = "steelblue") + 
  geom_smooth(color = "black") + 
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")

# Listing name

airbnb_words <- Filtered_All_Cities %>%
  select(name) %>%
  unnest_tokens(word, name) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "^[a-z']+$"))

common_words <- airbnb_words %>%
  group_by(word) %>%
  summarise(count = n()) %>%
  top_n(n = 20, wt = count) %>%
  ggplot() +
  geom_bar(mapping = aes(x=reorder(word, count),
                         y=count),
           stat="identity", fill = "brown") +
  labs(title="Top 20 words described in listing name",
       y="Word count", x="Most common Words") +
  coord_flip() +
  theme_minimal()

print(common_words)

# Listing description

airbnb_words2 <- Filtered_All_Cities %>%
  select(description) %>%
  unnest_tokens(word, description) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "^[a-z']+$"))

common_words2 <- airbnb_words2 %>%
  group_by(word) %>%
  summarise(count = n()) %>%
  top_n(n = 20, wt = count) %>%
  ggplot() +
  geom_bar(mapping = aes(x=reorder(word, count),
                         y=count),
           stat="identity", fill = "brown") +
  labs(title="Top 20 words described in listing description",
       y="Word count", x="Most common Words") +
  coord_flip() +
  theme_minimal()

print(common_words2)

# Neighborhood overview

airbnb_words3 <- Filtered_All_Cities %>%
  select(neighborhood_overview) %>%
  unnest_tokens(word, neighborhood_overview) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "^[a-z']+$"))

common_words3 <- airbnb_words3 %>%
  group_by(word) %>%
  summarise(count = n()) %>%
  top_n(n = 20, wt = count) %>%
  ggplot() +
  geom_bar(mapping = aes(x=reorder(word, count),
                         y=count),
           stat="identity", fill = "brown") +
  labs(title="Top 20 words described in neighborhood overview",
       y="Word count", x="Most common Words") +
  coord_flip() +
  theme_minimal()

print(common_words3)

# Price visualization by region

leaflet(data = Filtered_All_Cities) %>%  addProviderTiles("Stamen.Watercolor") %>%
  addProviderTiles("Stamen.TonerHybrid") %>%
  addCircleMarkers(~longitude, ~latitude, 
                   radius = ifelse(Filtered_All_Cities$price > 100, 2, 0.2),
                   color = ifelse(Filtered_All_Cities$price > 100, "red", "green"),
                   fillOpacity = 0.4)

# Univariate analysis


# Price
summary(Filtered_All_Cities$price) 
hist(Filtered_All_Cities$price, xlab="Price ($)", 
     ylab="Number of listings", main = "Histogram of Price", na.rm = TRUE)

# Response rate
summary(Filtered_All_Cities$host_response_rate)
hist(Filtered_All_Cities$host_response_rate,
     xlab="Host Response Rate, %", 
     ylab="Number of listings", 
     main = "Histogram of Host Response Rate", na.rom = TRUE)

# Acceptance rate
summary(Filtered_All_Cities$host_acceptance_rate)
hist(Filtered_All_Cities$host_acceptance_rate, 
     xlab="Host Acceptance Rate, %", 
     ylab="Number of listings", 
     main = "Histogram of Host Acceptance Rate", na.rm = TRUE)

# Super host
summary(Filtered_All_Cities$host_is_superhost)

# Listings count
summary(Filtered_All_Cities$host_listings_count)
hist(Filtered_All_Cities$host_listings_count,
     xlab="Host Listings Count", 
     ylab="Number of listings", 
     main = "Histogram of Host Listings Count", na.RM = TRUE)

# Profile pic
summary(Filtered_All_Cities$host_has_profile_pic)

# Identity verified
summary(Filtered_All_Cities$host_identity_verified)

# Accommodates
summary(Filtered_All_Cities$accommodates)
hist(Filtered_All_Cities$accommodates,  
     xlab="Number of People Accommodated", 
     ylab="Number of listings", 
     main = "Histogram of Number of People Accommodated", na.rm = TRUE)

# Bathrooms
summary(Filtered_All_Cities$bathrooms)
hist(Filtered_All_Cities$bathrooms,
     xlab="Number of Bathrooms", 
     ylab="Number of listings", 
     main = "Histogram of Number of Bathrooms")

# Bedrooms
summary(Filtered_All_Cities$bedrooms)
hist(Filtered_All_Cities$bedrooms,
     xlab="Number of Bedrooms", 
     ylab="Number of listings", 
     main = "Histogram of Number of Bedrooms", na.rm = TRUE)

# Beds
summary(Filtered_All_Cities$beds)
hist(Filtered_All_Cities$beds, 
     xlab="Number of Beds", 
     ylab="Number of listings", 
     main = "Histogram of Number of Beds", na.rm = TRUE)

# Minimum nights
summary(Filtered_All_Cities$minimum_nights)
hist(Filtered_All_Cities$minimum_nights,
     xlab="Minimum Number of Nights", 
     ylab="Number of listings", 
     main = "Histogram of Minimum Number of Nights")


# Maximum nights
summary(Filtered_All_Cities$maximum_nights)
hist(Filtered_All_Cities$maximum_nights,
     xlab="Maximum Number of Nights", 
     ylab="Number of listings", 
     main = "Histogram of Maximum Number of Nights", na.rm = TRUE)

# Has availability
summary(Filtered_All_Cities$has_availability)

# Availability within 30 days
summary(Filtered_All_Cities$availability_30)
hist(Filtered_All_Cities$availability_30,
     xlab="Number of Nights Available in Next 30 Days", 
     ylab="Number of listings", 
     main = "Histogram of Nights Available in Next 30 Days")

# Number of reviews
summary(Filtered_All_Cities$number_of_reviews)
hist(Filtered_All_Cities$number_of_reviews,
     xlab="Number of Reviews", 
     ylab="Number of listings", 
     main = "Histogram of Number of Reviews")

# Number of reviews last month
summary(Filtered_All_Cities$number_of_reviews_ltm)
hist(Filtered_All_Cities$number_of_reviews_ltm,
     xlab="Number of Reviews Last Month", 
     ylab="Number of listings", 
     main = "Histogram of Number of Reviews Last Month")

# Number of reviews last 130 days
summary(Filtered_All_Cities$number_of_reviews_l30d)
hist(Filtered_All_Cities$number_of_reviews_l30d,
     xlab="Number of Reviews Last 130 Days", 
     ylab="Number of listings", 
     main = "Histogram of Number of Reviews Last 130 Days")

# Review scores rating
summary(Filtered_All_Cities$review_scores_rating)
hist(Filtered_All_Cities$review_scores_rating,
     xlab="Rating", 
     ylab="Number of listings", 
     main = "Histogram of Reviews Rating")

# Instant bookable 
summary(Filtered_All_Cities$instant_bookable)

# Reviews per month
summary(Filtered_All_Cities$reviews_per_month)
hist(Filtered_All_Cities$reviews_per_month,
     xlab="Reviews Per Month", 
     ylab="Number of listings", 
     main = "Histogram of Reviews Per Month")

# City 
summary(Filtered_All_Cities$City)

head(Filtered_All_Cities)

# Price by city

summary(Filtered_All_Cities$price)

city_price_graph <- ggplot(Filtered_All_Cities, aes(x= City, y= price)) + 
  stat_summary(fun = "mean", geom = "bar") +
  labs(x="City Name", y = "Average Price, $", 
       title = "Average price comparison by city")

city_price_graph

# Price by accommodates

accommodates_graph <- ggplot(Filtered_All_Cities, aes(x= accommodates, y= price)) + 
  stat_summary(fun = "mean", geom = "bar") + labs(x="Number of People Accommodated", 
                                                  y = "Average Price, $", 
       title = "Average price comparison by number of people accommodated in listing")
accommodates_graph

# Price by bedrooms

price_bedrooms_graph <- ggplot(Filtered_All_Cities, aes(x= bedrooms, y= price)) + 
  stat_summary(fun = "mean", geom = "bar") + 
  labs(x="Number of Bedrooms", y = "Average Price, $",
       title = "Average price comparison by number bedrooms")
price_bedrooms_graph

# Price by beds

price_beds_graph <- ggplot(Filtered_All_Cities, aes(x= beds, y= price)) + 
  stat_summary(fun = "mean", geom = "bar") + 
  labs(x="Number of Beds", y = "Average Price, $",
       title = "Average price comparison by number beds")
price_beds_graph

# Price by bathrooms

price_bathrooms_graph <- ggplot(Filtered_All_Cities, aes(x= bathrooms, y= price)) + 
  stat_summary(fun = "mean", geom = "bar") + 
  labs(x="Number of Bathrooms", y = "Average Price, $",
       title = "Average price comparison by number bathrooms")
price_bathrooms_graph

# Correlation analysis 
corr_data <- Filtered_All_Cities %>% 
  select(host_response_rate, host_accaptance_rate, host_is_superhost,
         host_listings_count, host_has_profile_pic, host_identity_verified,
         accommodates, bedrooms, beds, price, minimum_nights, maximum_nights,
         has_availability, availability_30, number_of_reviews, 
         number_of_reviews_ltm, number_of_reviews_l30d, review_scores_rating,
         instant_bookable, reviews_per_month, bathrooms, Montreal,
         New_Brunswick, Ottawa, Quebec_City, Toronto, Vancouver, Victoria)

corr_data2 <- cor(corr_data, use =  "complete.obs")
corr_data2 <- round(corr_data2, 2)

corr_data2

pairs(corr_data2)

corrplot(corr_data2)

summary(corr_data2)


################################################################################################

# SECTION 4: LINEAR REGRESSION AND HYPOTHESIS TESTING

# Initial filter for variables to include in the model

corr_data <- Filtered_All_Cities  %>% 
  select(accommodates, bedrooms, 
         price, number_of_reviews_ltm, review_scores_rating, instant_bookable,
         bathrooms, City, room_type)

str(corr_data)
# Create dummy variables

corr_data$Montreal <- ifelse(corr_data$City == "Montreal",1,0)
corr_data$New_Brunswick <- ifelse(corr_data$City == "New Brunswick",1,0)
corr_data$Ottawa <- ifelse(corr_data$City == "Ottawa",1,0)
corr_data$Quebec_City <- ifelse(corr_data$City == "Quebec City",1,0)
corr_data$Toronto <- ifelse(corr_data$City == "Toronto",1,0)
corr_data$Vancouver <- ifelse(corr_data$City == "Vancouver",1,0)
corr_data$Victoria <- ifelse(corr_data$City == "Victoria",1,0)
corr_data$hotel_room <- ifelse(corr_data$room_type == "Hotel room",1,0)
corr_data$private_room <- ifelse(corr_data$room_type == "Private room",1,0)
corr_data$shared_room <- ifelse(corr_data$room_type == "Shared room",1,0)
corr_data$instant_book_true <- ifelse(corr_data$instant_bookable == "True", 1, 0)
corr_data$instant_book_false <- ifelse(corr_data$instant_bookable == "False", 1, 0)

#Inspect and omit NAs for the model
md.pattern(corr_data, )
corr_data2 <- na.omit(corr_data)
md.pattern(corr_data2, rotate.names = TRUE)

#After TTT approach on corr_data df, select final variables that belong in the model
# If we need to include any new variables, add it to corr_data, remove NAs using corr_data2, then select it 
# in the "model" df. 

model <- corr_data2  %>% 
  select(accommodates, bedrooms, price, 
         number_of_reviews_ltm, review_scores_rating, 
         bathrooms, private_room, shared_room,
         Victoria, Vancouver, Toronto)

# Split 70-30 test and train

sample <- sample.int(n=nrow(model), size = floor(.7*nrow(model)), replace = F)
train <- model[sample,]
test <- model[-sample,]

#linear model and summary plots

reg <- lm(price ~ ., train)
pred <- predict(reg, test)

summary(reg)

#Regression plots don't look ideal
plot(reg)

#Density plot looks normal
plot(density(resid(reg)))

#Data is homoskedastic
ncvTest(reg)

#Compare R2 and RMSE. They are about the same which tells that the model is good and not over fitted
data.frame(R2 = R2(pred, test$price),
           RMSE = RMSE(pred, test$price),
           MAE = MAE(pred, test$price))

#Create variables to capture potential nonlinear relationships

corr_data2$bedrooms_squared <- corr_data2$bedrooms^2
corr_data2$bathrooms_squared <- corr_data2$bathrooms^2
corr_data2$bedrooms_ln <- log(corr_data2$bedrooms)
corr_data2$bathrooms_ln<- log(corr_data2$bathrooms)
str(corr_data2)

# Model2

model2 <- corr_data2  %>% 
  select(accommodates, bedrooms, price, 
         number_of_reviews_ltm, review_scores_rating, 
         bathrooms, private_room, shared_room,
         Victoria, Vancouver, Toronto, bedrooms_squared, bathrooms_squared)

# Split 70-30 test and train

sample2 <- sample.int(n=nrow(model2), size = floor(.7*nrow(model2)), replace = F)
train2 <- model2[sample,]
test2 <- model2[-sample,]

#linear model and summary plots

reg2 <- lm(price ~ ., train2)
pred2 <- predict(reg, test2)

summary(reg2)

#check if "number_of_reviews_ltm" and "review_scores_rating" only are jointly 0, and that there's no collinearity problem
linearHypothesis(reg2, c("bedrooms_squared=0", "bathrooms_squared=0"))

#Regression plots don't look ideal
plot(reg2)

#Density plot looks normal
plot(density(resid(reg2)))

#Data is homoskedastic
ncvTest(reg2)

#Compare R2 and RMSE. They are about the same which tells that the model is good and not over fitted
data.frame(R2 = R2(pred2, test$price),
           RMSE = RMSE(pred2, test$price),
           MAE = MAE(pred2, test$price))

################################################################################################################

# SECTION 5: OCCUPANCY RATES


#Create a df for occupancy

occupancy <- Filtered_All_Cities  %>% 
  select(accommodates, bedrooms, neighbourhood_cleansed,host_is_superhost,
         price, minimum_nights, City, room_type, number_of_reviews, reviews_per_month,
         review_scores_rating, host_response_rate)

#Omit NAs
occupancy$host_is_superhost[occupancy$host_is_superhost == ""] <-NA

occupancy <- na.omit(occupancy)

# Create an occupancy days column. Using minimum nights and a conservative estimate of 50% review reporting
# Occupancy days capped at 30 nights per month
occupancy$occupancy_days <- occupancy$reviews_per_month*2*occupancy$minimum_nights
occupancy$occupancy_days <- ifelse(occupancy$occupancy_days < 30, 
                                               occupancy$occupancy_days, 30)
occupancy$occupancy_rate <- (occupancy$occupancy_days)/30


#Calculate revenue = price per night x occupancy rate
occupancy$revenue <- occupancy$occupancy_days*occupancy$price

plot1 <- ggplot(occupancy, aes(x = occupancy_rate, y = revenue)) + 
  geom_point(alpha = 0.5, color = "steel blue") +
  geom_smooth(color = "black") + 
  labs(x = "Occupancy Rate", y = "Monthly Revenue, $", title = "Monthly revenue versus Occupancy Rate Correlation",
       subtitle = "Good correlation") + 
  scale_y_continuous(limits = c(0,5000,500))
plot1

plot2 <- ggplot(occupancy, aes(x = price, y = revenue)) + 
  geom_point(alpha = 0.5, color = "steel blue") +
  geom_smooth(color = "black") + 
  labs(x = "Price, $", y = "Monthly Revenue, $", title = "Monthly revenue versus Price Correlation", 
       subtitle = "Not a strong correlation" ) + 
  scale_y_continuous(limits = c(0,5000,500))
plot2


# Monthly revenue by city 
revenue <- ggplot(occupancy, aes(x = City, y = revenue)) + 
  geom_bar(stat = 'summary', fun = 'mean') +
  labs(x = "City", y = "Monthly Revenue, $", title = "Average monthly revenue by city" )
revenue

# Occupancy Rates by city
occupancy_rates <- ggplot(occupancy, aes(x = City, y = occupancy_rate)) + 
  geom_bar(stat = 'summary', fun = 'mean') + 
  scale_y_continuous(labels = scales ::percent) + 
  labs(x = "City", y = "Monthly Occupancy Rate", title = "Monthly occupancy rate by city" )
occupancy_rates


figure1 <- ggarrange(revenue, occupancy_rates, nrow = 2)
figure1

#Occupancy rates for superhost
occupancy_superhost <- ggplot(occupancy, 
                 aes(x = City, y = occupancy_rate, fill = host_is_superhost)) + 
  geom_bar(stat = 'summary', fun = 'mean', position = "dodge") + 
  labs(x = "City", y = "Occupancy Rate, %" , title = "Occupancy Rates for Superhosts" )
occupancy_superhost

#Average Price for listing
price_superhost <- ggplot(occupancy, 
                            aes(x = City, y = price, fill = host_is_superhost)) + 
  geom_bar(stat = 'summary', fun = 'mean', position = "dodge") + 
  labs(x = "City", y = "Listing Price, $", title = "Average Listing price by City")
price_superhost

# Average Monthly revenue
revenue_superhost <- ggplot(occupancy, 
                              aes(x = City, y = revenue, fill = host_is_superhost)) + 
  geom_bar(stat = 'summary', fun = 'mean', position = "dodge") + 
  labs(x = "City", y = "Monthly Revenue, $", title = "Average Monthly revenue by city")
revenue_superhost

figure2 <- ggarrange(occupancy_superhost,
                     price_superhost,
                     revenue_superhost,
                     nrow = 3)
figure2


#Who is a superhost
superhost <- ggplot(occupancy, aes(x = host_response_rate, y = review_scores_rating,
                                          color = host_is_superhost)) + 
  geom_point() + 
  labs(x = "Host response rate", y = "Review scores rating", title = "Who is a Superhost")
superhost

#Calculate mean revenue per city

Rev_Toronto <- mean(occupancy$revenue[occupancy$City == "Toronto"])
Rev_Vancouver <- mean(occupancy$revenue[occupancy$City == "Vancouver"])
Rev_Victoria <- mean(occupancy$revenue[occupancy$City == "Victoria"])
Rev_Quebec_City <- mean(occupancy$revenue[occupancy$City == "Quebec City"])
Rev_Ottawa <- mean(occupancy$revenue[occupancy$City == "Ottawa"])
Rev_New_Brunswick <- mean(occupancy$revenue[occupancy$City == "New Brunswick"])
Rev_Montreal <- mean(occupancy$revenue[occupancy$City == "Montreal"])

Rev_Toronto 
Rev_Vancouver
Rev_Victoria
Rev_Quebec_City
Rev_Ottawa
Rev_New_Brunswick
Rev_Montreal

#Import rentals data into a dataframe

compare <- read_excel(file.choose())

rent_or_list <- ggplot(compare, 
                       aes(x = City, y = Price, fill = Type)) + 
  geom_bar(stat = 'summary', fun = 'mean', position = "dodge") + 
  labs(x = "City", y = "Expected Monthly Revenue, $", title = "Monthly revenue by Rent versus Airbnb")
rent_or_list


