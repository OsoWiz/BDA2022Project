data {
  int<lower=0> N;  // number of data points
  vector[N] x;// Magnitude of a tornado
  vector<lower=0>[N] y;// Injuries caused by a tornado
  real pmualpha;//prior mean of alpha
  real<lower=0> psalpha;//prior sd of alpha
  real pmubeta;//prior mean of beta
  real<lower=0> psbeta;//prior sd of beta
  vector[6] xpred;
}

parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
}

transformed parameters {
  vector[N] mu = alpha*x + beta;
}

model {
  alpha ~ normal(pmualpha, psalpha); //prior of alpha
  beta ~ normal(pmubeta, psbeta); //prior of beta
  sigma ~ normal(5, 100);
  y ~ normal(mu, sigma);
}

generated quantities {
  vector[N] log_lik;
  
  for (n in 1:N) {
      log_lik[n] = normal_lpdf(y[n] | mu[n], sigma);
  }
}
