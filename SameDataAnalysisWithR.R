library(tidyverse)
library(readxl)
install.packages("writexl")
library(writexl)
library(ggplot2)
library(dplyr)

##DATA ALREADY CLEANDED IN SQL

##reading sheet 2016-2018 in my excel file
H1B2016 <- read_excel("C:/Users/Momore/Downloads/H1B2016.xlsx", 
                      sheet = "2016")
H1B2017 <- read_excel("C:/Users/Momore/Downloads/H1B2016.xlsx", 
                      sheet = "2017")
H1B2018 <- read_excel("C:/Users/Momore/Downloads/H1B2016.xlsx", 
                      sheet = "2018")

H1B <- rbind(H1B2016, H1B2017, H1B2018)

##the count of the number of applications per year
df_count <- H1B %>% 
  filter(YEAR >= 2015 & YEAR <= 2018) %>% 
  group_by(YEAR) %>% 
  summarise(count = n())

#Create a bar chart-- Analysis 1
ggplot(df_count, aes(x = YEAR, y = count, fill = YEAR)) +
  geom_bar(stat = "identity") +
  xlab("Year") +
  ylab("Count") +
  ggtitle("Applications per year")

##the number of applications filed per state
df_count2 <- H1B %>% 
  filter(!is.na(EMPLOYER_STATE)) %>% 
  group_by(EMPLOYER_STATE) %>% 
  summarise(count = n()) %>%
  arrange(desc(count))

#Create a bar chart-- Analysis 2
# Generate a vector of random colors with the same length as the number of states
color_vector <- sample(colors(), nrow(df_count2))

# Plot the data with the random colors
ggplot(df_count2, aes(x = reorder(EMPLOYER_STATE, -count) , y = count, fill = EMPLOYER_STATE)) +
  geom_bar(stat = "identity") +
  xlab("State") +
  ylab("Count") +
  ggtitle("Applications per State") +
  
  scale_x_discrete(breaks = seq(from = 1, to = nrow(df_count2), by = 2), 
                   labels = df_count2$EMPLOYER_STATE[seq(from = 1, to = nrow(df_count2), by = 2)]) +
  scale_fill_manual(values = color_vector) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1.2))


##the number of certified, withdrawn, denied and certified withdrawn cases
df_count3 <- H1B %>% 
  filter(YEAR >= 2015 & YEAR <= 2018) %>% 
  group_by(CASE_STATUS) %>% 
  summarise(count = n())

#Create a bar chart-- Analysis 3
ggplot(df_count3, aes(x = CASE_STATUS, y = count, fill = CASE_STATUS)) +
  geom_bar(stat = "identity") +
  xlab("Case Status") +
  ylab("Count") +
  ggtitle("Applications per Case Status") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1.2))


##the top 10 companies that sponsor VISA's
df_count4 <- H1B %>% 
  filter(!is.na(EMPLOYER_NAME)) %>% 
  group_by(EMPLOYER_NAME) %>% 
  summarise(count = n()) %>%
  arrange(desc(count))

#Create a bar chart-- Analysis 4
df_count4_top10 <- df_count4 %>%
  top_n(10, count)

# Create the plot with the top 10 companies
ggplot(df_count4_top10, aes(x = reorder(EMPLOYER_NAME, -count), y = count, fill = EMPLOYER_NAME)) +
  geom_bar(stat = "identity") +
  xlab("Company Name") +
  ylab("Count") +
  ggtitle("Applications per Company (Top 10)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1.2))



##the top 10 jobs with the most certified applications
df_count5 <- H1B %>% 
  filter(!is.na(CASE_STATUS == 'CERTIFIED')) %>% 
  group_by(JOB_TITLE) %>% 
  summarise(count = n()) %>%
  arrange(desc(count))

#Create a bar chart-- Analysis 5
df_count5_top10 <- df_count5 %>%
  top_n(10, count)

# Create the plot with the top 10 jobs
ggplot(df_count5_top10, aes(x = reorder(JOB_TITLE, -count), y = count, fill = JOB_TITLE)) +
  geom_bar(stat = "identity") +
  xlab("Job Title") +
  ylab("Count") +
  ggtitle("Certified Applications per Job(Top 10)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1.2))
