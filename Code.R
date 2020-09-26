df1 = read.csv("C:/Users/baner/OneDrive/Desktop/SEM 1/R/Project/dataset_with_text_features.csv",na.strings = c(""))
test_x = read.csv("C:/Users/baner/OneDrive/Desktop/SEM 1/R/Project/Test_data_final.csv",na.strings = c(""))

set.seed(46747)
index <- sample(1:nrow(df1), 99978)
df1 = df1[index, ]
library(randomForest)
library(gbm)
library(ISLR)

df1 = subset(df1, select = c(longitude,latitude,accommodates, amenities_count, availability_30,availability_60,availability_90,availability_365,
                             bathrooms , bed_type , bedrooms,
                             beds , cancellation_policy ,cleaning_fee, security_deposit , extra_people , host_has_profile_pic, 
                             host_identity_verified , city_name, host_response_time , instant_bookable, 
                             is_location_exact , maximum_nights , minimum_nights , price, 
                             require_guest_phone_verification , require_guest_profile_picture, 
                             requires_license , room_type , host_is_superhost , host_verifications_count,high_booking_rate, guests_included, host_total_listings_count, zipcode))

test_x = subset(test_x, select = c(longitude,latitude,accommodates, amenities_count, availability_30,availability_60,availability_90,availability_365,
                             bathrooms , bed_type , bedrooms,
                             beds , cancellation_policy ,cleaning_fee, security_deposit , extra_people , host_has_profile_pic, 
                             host_identity_verified , city_name, host_response_time , instant_bookable, 
                             is_location_exact , maximum_nights , minimum_nights , price, 
                             require_guest_phone_verification , require_guest_profile_picture, 
                             requires_license , room_type , host_is_superhost , host_verifications_count, guests_included, host_total_listings_count, zipcode ))


test_x <- test_x[order(test_x$latitude),]
test_x$zipcode <- as.character(test_x$zipcode)
which(test_x$zipcode == 'NA')
for (cell in test_x) 
{
  cell <-which(test_x$zipcode == 'NA')
  test_x[cell,'zipcode'] <-  test_x[(cell-1),'zipcode']
}
test_x$zipcode <- as.numeric(test_x$zipcode)
summary(test_x$zipcode)


test_x$index <- as.numeric(row.names(test_x))
test_x=test_x[order(test_x$index), ]

#df1$high_booking_rate = as.factor(df1$high_booking_rate)
df1 <- df1[order(df1$latitude),]
df1$zipcode <- as.character(df1$zipcode)
which(df1$zipcode == 'NA')
for (cell in df1) 
{
  cell <-which(df1$zipcode == 'NA')
  df1[cell,35] <- df1[(cell-1),35]
}
df1$zipcode <- as.numeric(df1$zipcode)
which(is.na(df1$zipcode))
for (cell in df1) 
{
  cell <-which(is.na(df1$zipcode))
  df1[cell,35] <- df1[(cell-1),35]
}


df1$index <- as.numeric(row.names(df1))
df1=df1[order(df1$index), ]
summary(df1$zipcode)

train <- sample(nrow(df1), .99999999*nrow(df1))
test_size <- nrow(df1)-length(train)


#summary(df1$zipcode)

boost.mod <- gbm(high_booking_rate~.,data=df1[train,],distribution="bernoulli",n.trees=1500,interaction.depth=7)
boost_preds <- predict(boost.mod,newdata=test_x,type='response',n.trees=1500)
#classify with a cutoff and compute accuracy
boost_class <- ifelse(boost_preds >.49,1,0)
boost_class
boost_acc <- sum(ifelse(boost_class==df1$high_booking_rate[-train],1,0))/test_size
boost_acc


write.csv(boost_class,"C:/Users/baner/OneDrive/Desktop/SEM 1/R/Project/rf5.csv")
