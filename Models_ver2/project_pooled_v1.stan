data {
  int<lower=0> N;  // number of data points
  vector[N] x;// Magnitude of a tornado
  vector<lower=0>[N] y;// Injuries caused by a tornado
  vector[5] xpred;
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
  alpha ~ uniform(0, 100); //prior of alpha
  beta ~ uniform(0, 100); //prior of beta
  sigma ~ normal(5, 100);
  y ~ normal(mu, sigma);
}

generated quantities {
  vector[N] log_lik;
  vector[5] ypred;

  for(i in 1:5) {
    ypred[i] = normal_rng(alpha*xpred[i]+beta, sigma);
  }
  
  for (n in 1:N) {
      log_lik[n] = normal_lpdf(y[n] | mu[n], sigma);
  }
}
