# Description of the problem

The household's utility function is
$$
\mathbb{E}_0 \sum_{t=0}^{\infty} \beta^t \frac{C_t^{1-\gamma}}{1-\gamma}
$$

The labor income can be characterized by
$$
Y_t=\left\{\begin{array}{l}
\tilde{Y}_t, \text { if employed } \\
b, \text { if unemployed }
\end{array}\right.
$$
where
$$
\log \tilde{Y_t}=(1-\rho)\log\mu+\rho\log\tilde{Y_{t-1}}+\epsilon_t
$$
and
$$
\epsilon_t\in \mathcal{N}(0,\sigma^2)
$$
When a household is employed, its probability of becoming unemployed next period is $p$. When a household is unemployed, its probability of becoming employed again next period is $q$.

The budget constraint is given through
$$
C_t+\frac{A_{t+1}}{1+r}=Y_t+A_t
$$
and the borrowing constraint is
$$
A_t\geq0.
$$

The parameter values are
$$
\gamma=2,\beta=0.98,\mu=1,b=0.4,\rho=0.9,\sigma^2=0.05,p=0.05,1=0.25,r=0.01.
$$
The notation of the parameters is consistent with that used in literature.
