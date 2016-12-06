# Time Series Report

Since 2014, Yelp has been hosting a competition called the Yelp Dataset Challenge. Thus far, Yelp has offered 8 rounds of this competition to the general public. Since its inception, the Yelp Dataset Challenge has given the machine learning and data science communities a useful and thorough dataset in which to apply state of the art ML algorithms and advanced data analysis to. We chose this dataset because it offers highly relevant data that is granular enough to be useful in our analysis, but not too granular as to require computationally complex routines to pre-process the data.

The dataset consists of 2.7M reviews and 649K tips by 687K users for 86K businesses. Furthermore, there are a total of 566K attributes that can be applied to a business. In addition to data that is core to Yelp’s business, the dataset also includes associations between the users creating a graph network of approximately 4.2M edges. All of the data is represented in json form stored in text files and takes up about 2.5GB on disk.

The portion of the data we have chosen to focus on are the review data. We are using reviews as a proxy measure of Yelp’s popularity overtime. We are able to do this because each review contains a date in ‘yyyy-mm-dd’ format which enables us to measure popularity down to the granularity of a day. Because yelp has been in business since 2014, grouping reviews by day gives us 4,003 samples to build our predictive model with; however, to improve the  accuracy of our predictions, we have decided to limit the granularity of time to a month, providing us with 141 samples.

Review JSON Object
```
{
    'type': 'review',
    'business_id': (encrypted business id),
    'user_id': (encrypted user id),
    'stars': (star rating, rounded to half-stars),
    'text': (review text),
    'date': (date, formatted like '2012-03-14'),
    'votes': {(vote type): (count)},
}
```

The first step taken to normalize our data and make it easier to query was to build a an ETL program to put our data into a relational database: doing so supports us in making ad-hoc queries in reasonable time. Once the data was in relational form, we wrote a simple query that grouped reviews by month and year and counted the number of items in each group. 

Review Aggregation Query
```sql
SELECT
  rollUp.reviewDate
  , count(1) as reviews
FROM (
   SELECT date_format(review.date, '%Y-%m') as reviewDate
   FROM review
   ORDER BY review.date) AS rollUp
GROUP BY rollUp.reviewDate
```

After producing the dataset of review counts by month, we produced a visualization using Tableau software so that we could identify obvious trends, cycles, and seasonality.

![Alt text](/assets/yelp_checkins_over_time.png?raw=true "Review Counts over Time")


