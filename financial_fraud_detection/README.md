# Financial Fraud Detection

> Analyzing a dataset of credit card crimes with transactions flagged as fraud.
> I used the interquartile range and 3-sigma methods to see which method was more effective in detecting outliers in transaction amounts.

## Table of Contents
* [General Info](#general-information)
* [Technologies Used](#technologies-used)
* [custom queries](#SQL-script)
* [screenshots](#screenshots)


## General Information

In SQL, I added the measures of mean, standard deviation, 25th and 75th percentile, interquartile range and 3-sigma, z-score and grouped 
them by merchant.
The z-score is the distance between the mean of the distribution and the analyzed value expressed in standard deviation.
Based on the z-score, 3-sigma method was applied. Transactions that were further than 3 sigma (that mean 3-z) were flagged as likely fraud.
I grouped transactions by merchant because I thought different merchants might have a higher probability of fraud.

When analyzing the correlations in the scatter plot, it turned out that almost all the merchants (650) have the same chance of 
committing fraud. Which ultimately leads to the conclusion that the analyzed dataset is created from synthetic data. To make it more realistic, 
we should add noise to the data.
Therefore, to visualize the remaining graphs of the sums of legitimate and fraudulent transactions, I used grouping by transaction categories 
(such as grocery, travel, entertainment), which resulted in more diverse data.

It also turned out that the IQR method detects frauds much less often than the 3 sigma method. 
I prepared a confusion matrix to observe the behavior of the classifier.
The result for 3 sigma is TPR = 0.69 number of positive (fraudulent) transactions found, PPV = 0.23 - if the classifier can find something, 
then it is there. 
I assumed that only high z-scores are taken into account, not very low ones.

## Technologies used

- SQL (PostgreSQL)
- MS Power BI
