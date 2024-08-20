**file : p_value&Sharpe.py**

**objective**: Validation of an Algo Trading strategy.

- Import of a CSV with monthly returns of an Algotrading strategy, called " rendimenti_Algo"
- Graph distribution of returns to get an idea
- perform T-TEST with P-Value with 5% confidence level (on the average of the returns)
    - H0 : returns = 0
    - HA : yields > 0

**objective** : evaluate the risk-adjusted performance of a portfolio or investment strategy compared to a risk-free asset, such as government bonds  

- Calculate SHARPE RATIO (algo trading vs Government Bonds)
  
It is possible that there are errors, available to receive advice and corrections 😊



**RESULTS**

- **p-value** is  < 0.05, you reject the null hypothesis and conclude that there is sufficient statistical evidence  to state that the returns are not random and differ significantly from zero.



- A **Sharpe Ratio** of 0.367 indicates that for every unit of risk assumed, the investment generated an additional return of approximately 0.367 units over the risk-free rate."

**Interpretation for Sharpe Ratio**:

A positive Sharpe Ratio indicates that the investment generated a return greater than the risk-free return for each unit of risk assumed.
Higher Sharpe Ratio values ​​are generally better, as they indicate greater return relative to risk. However, a Sharpe Ratio of 0.367 is relatively low, suggesting that the risk-adjusted return is not very high.

